"""Offline isolated Lua states with queued messages, not real PZ/Steam networking."""
from collections import deque
from copy import deepcopy
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path[:0] = [str(ROOT / 'scripts'), str(ROOT / '.venv-test')]
from lua_runtime import runtime

MODULE = 'B47ANCEDMedicalChecks'


def plain(value):
    """Copy protocol data out of one VM before reconstructing it in another."""
    if not hasattr(value, 'items'):
        return value
    values = {key: plain(item) for key, item in value.items()}
    if values and set(values) == set(range(1, len(values) + 1)):
        return [values[index] for index in range(1, len(values) + 1)]
    return values


class Workflow:
    def __init__(self, options=None, mods=None):
        self.options = options or {}
        self.mods = mods or []
        self.names = {1: 'examiner', 2: 'patient', 3: 'third'}
        self.clock = 100
        self.queue = deque()
        self.transcript = []
        self.clients = {}
        self.server_start()
        for account in self.names:
            self.client_start(account)

    def server_start(self, files=None):
        self.server = runtime()
        self.s = self.server.eval('(require("server_fixture"))')(self.server.table_from({'mods': self.mods}, recursive=True))
        self.s.files = self.server.table_from(files or {})
        self.s.time = self.clock
        for key, value in self.options.items():
            self.server.globals().SandboxVars.B47ANCEDMedicalChecks[key] = value
        for account, name in self.names.items():
            self.s.addPlayer(self.s, account, name)
        self.s.start(self.s)

    def client_start(self, account):
        vm = runtime()
        fixture = vm.eval('(require("client_fixture"))')(True, vm.table_from({'id': account, 'mods': self.mods}, recursive=True))
        fixture.time = self.clock * 1000
        self.clients[account] = (vm, fixture)

    def collect(self):
        for account, (vm, fixture) in self.clients.items():
            for index in range(1, len(fixture.sent) + 1):
                message = fixture.sent[index]
                self.queue.append({'side': 'server', 'sender': account, 'module': MODULE,
                                   'command': message.command, 'args': plain(message.args)})
            fixture.sent = vm.table()
        for index in range(1, len(self.s.sent) + 1):
            message = self.s.sent[index]
            self.queue.append({'side': 'client', **plain(message)})
        self.s.sent = self.server.table()

    def step(self):
        self.collect()
        if not self.queue:
            return None
        message = self.queue.popleft()
        self.transcript.append(deepcopy(message))
        if message['side'] == 'server':
            self.s.command(self.s, message['sender'], message['module'], message['command'],
                           self.server.table_from(message['args'], recursive=True))
        elif message['recipient'] in self.clients:
            vm, fixture = self.clients[message['recipient']]
            fixture.server(fixture, message['command'], vm.table_from(message['args'], recursive=True))
        return message

    def pump(self):
        for _ in range(500):
            if self.step() is None:
                return
        raise AssertionError('Unbounded protocol exchange in offline fixture')

    def advance(self, seconds=1):
        self.clock += seconds
        self.s.time = self.clock
        self.s.tick(self.s)
        for vm, fixture in self.clients.values():
            fixture.time = self.clock * 1000
            vm.globals().Events.OnTick.fire()
        self.pump()

    def send(self, account, command, args=None, pump=True):
        vm, fixture = self.clients[account]
        vm.globals().B47MC.Client.send(fixture.player, command, vm.table_from(args or {}, recursive=True))
        if pump:
            self.pump()

    def request(self, examiner=1, patient=2, pump=True):
        self.advance()
        vm, fixture = self.clients[examiner]
        fixture.patient.id = patient
        vm.globals().ISWorldObjectContextMenu.onMedicalCheck(vm.table(), fixture.player, fixture.patient)
        if pump:
            self.pump()

    def answer(self, patient=2, accept=True, pump=True):
        vm, fixture = self.clients[patient]
        for index in range(len(fixture.modals), 0, -1):
            modal = fixture.modals[index]
            if modal.yesno and modal.visible:
                # Vanilla modal onClick closes the window and invokes this callback.
                modal.destroy(modal)
                modal.onclick(None, vm.table_from({'internal': 'YES' if accept else 'NO'}))
                if pump:
                    self.pump()
                return
        raise AssertionError('No visible approval prompt')

    def actions(self, account=1):
        return self.clients[account][1].vanillaActions

    def prompts(self, account=2):
        fixture = self.clients[account][1]
        return sum(bool(fixture.modals[i].yesno and fixture.modals[i].visible) for i in range(1, len(fixture.modals) + 1))

    def snapshot(self, account=2):
        self.advance()
        self.send(account, 'Snapshot')
        return plain(self.clients[account][0].globals().B47MC.Client.snapshots[account])

    def disconnect(self, account):
        vm, _ = self.clients.pop(account)
        vm.globals().Events.OnDisconnect.fire()
        self.s.players[account] = None
        self.advance()

    def reconnect(self, account):
        self.s.addPlayer(self.s, account, self.names[account])
        self.client_start(account)

    def restart(self):
        files = plain(self.s.files)
        for vm, _ in self.clients.values():
            vm.globals().Events.OnDisconnect.fire()
        self.queue.clear()
        self.server_start(files)
        for account in self.clients:
            self.client_start(account)


class IsolatedWorkflow(unittest.TestCase):
    def test_directional_approval_with_three_clients(self):
        h = Workflow()
        h.send(2, 'Preference', {'preference': 2})
        h.request()
        self.assertEqual(h.actions(), 0)
        h.answer()
        self.assertEqual(h.actions(), 1)
        h.request()
        self.assertEqual(h.actions(), 2)
        self.assertEqual(h.prompts(), 0)
        h.request(3, 2)
        self.assertEqual(h.prompts(), 1)
        h.answer(accept=False)
        self.assertEqual(h.actions(3), 0)
        grants = h.snapshot()['grants']
        self.assertEqual([grant['key'] for grant in grants], ['examiner'])
        h.request(2, 1)
        self.assertEqual(h.prompts(1), 1)
        self.assertEqual(h.actions(2), 0)
        # Private settings/approval snapshots are delivered only to their owner.
        self.assertTrue(all(m['recipient'] == 2 for m in h.transcript
                            if m['side'] == 'client' and m['command'] == 'Snapshot'))

    def test_always_ask_never_remembers(self):
        h = Workflow()
        for expected in (1, 2):
            h.request()
            self.assertEqual(h.prompts(), 1)
            h.answer()
            self.assertEqual(h.actions(), expected)
        self.assertFalse(h.snapshot()['grants'])

    def test_denial_and_timeout_do_not_authorize(self):
        h = Workflow({'RequestTimeout': 5})
        h.send(2, 'Preference', {'preference': 2})
        h.request()
        h.answer(accept=False)
        h.request()
        h.advance(6)
        self.assertEqual(h.actions(), 0)
        self.assertEqual(h.prompts(), 0)
        self.assertFalse(h.snapshot()['grants'])
        h.request()
        self.assertEqual(h.prompts(), 1)

    def test_all_four_server_policies(self):
        for policy in (1, 2, 3, 4):
            with self.subTest(policy=policy):
                h = Workflow({'Policy': policy})
                h.request()
                if policy == 4:
                    self.assertEqual(h.prompts(), 0)
                    self.assertEqual(h.actions(), 0)
                    continue
                h.answer()
                h.request()
                self.assertEqual(h.prompts(), 0 if policy == 3 else 1)
                self.assertEqual(h.actions(), 2 if policy == 3 else 1)

    def test_individual_revoke_keeps_other_examiner(self):
        h = Workflow({'Policy': 3})
        for examiner in (1, 3):
            h.request(examiner)
            h.answer()
        h.send(2, 'RevokeApproval', {'key': 'examiner'})
        self.assertEqual([g['key'] for g in h.snapshot()['grants']], ['third'])
        h.request(3)
        self.assertEqual(h.actions(3), 2)
        h.request()
        self.assertEqual(h.prompts(), 1)

    def test_revocation_between_offer_and_confirmation(self):
        h = Workflow({'Policy': 3})
        h.request()
        h.answer(pump=False)
        # Deliver the offer, leaving the client's confirmation queued locally.
        for _ in range(20):
            message = h.step()
            if message and message['command'] == 'CoopOffer':
                break
        else:
            self.fail('Expected offer')
        h.collect()
        h.send(2, 'RevokeApproval', {'key': 'examiner'}, pump=False)
        h.collect()
        revoke = next(m for m in h.queue if m['command'] == 'RevokeApproval')
        h.queue.remove(revoke)
        h.queue.appendleft(revoke)
        h.pump()
        self.assertEqual(h.actions(), 0)
        self.assertFalse(h.snapshot()['grants'])

    def test_duplicate_offers_confirmations_and_proceed_are_consumed_once(self):
        h = Workflow()
        h.request()
        h.answer(pump=False)
        for _ in range(80):
            h.collect()
            if not h.queue:
                break
            first = h.queue[0]
            if first['command'] in ('CoopOffer', 'CoopConfirm', 'CoopProceed') and not first.get('duplicated'):
                first['duplicated'] = True
                h.queue.insert(1, deepcopy(first))
            h.step()
        else:
            self.fail('Exchange did not settle')
        self.assertEqual(h.actions(), 1)

    def test_persistent_approval_reconnect_and_server_restart(self):
        h = Workflow({'Policy': 3})
        h.request()
        h.answer()
        h.disconnect(1)
        h.reconnect(1)
        h.request()
        self.assertEqual(h.prompts(), 0)
        self.assertEqual(h.actions(), 1)
        h.restart()
        h.request()
        self.assertEqual(h.prompts(), 0)
        self.assertEqual(h.actions(), 1)

    def test_session_approval_clears_for_either_disconnect_and_restart(self):
        for role in (1, 2, 'restart'):
            with self.subTest(role=role):
                h = Workflow({'Policy': 3, 'Retention': 2})
                files = plain(h.s.files)
                h.request()
                h.answer()
                self.assertEqual(plain(h.s.files), files)
                if role == 'restart':
                    h.restart()
                else:
                    h.disconnect(role)
                    h.reconnect(role)
                h.request()
                self.assertEqual(h.prompts(), 1)

    def test_lost_confirmation_expires_without_action(self):
        h = Workflow({'RequestTimeout': 5})
        h.request()
        h.answer(pump=False)
        for _ in range(20):
            message = h.step()
            if message and message['command'] == 'CoopOffer':
                break
        h.collect()
        h.queue = deque(m for m in h.queue if m['command'] != 'CoopConfirm')
        h.pump()
        h.advance(6)
        self.assertEqual(h.actions(), 0)

    def test_movement_after_prompt_cancels_both_clients(self):
        h = Workflow()
        h.request()
        h.s.players[2].x = 10
        h.advance()
        self.assertEqual(h.prompts(), 0)
        self.assertEqual(h.actions(), 0)

    def test_failed_grant_write_returns_failure_without_action(self):
        h = Workflow({'Policy': 3})
        h.request()
        h.s.failWrites = True
        h.answer()
        self.assertEqual(h.actions(), 0)
        self.assertFalse(h.snapshot()['grants'])
        self.assertTrue(any(m['command'] == 'CoopResult' and m['args']['reason'] == 'StorageFailed'
                            for m in h.transcript))

    def test_damaged_or_missing_revocation_slot_never_restores_old_approval(self):
        for damage in ('corrupt', 'missing'):
            with self.subTest(damage=damage):
                h = Workflow({'Policy': 3})
                h.request()
                h.answer()
                h.send(2, 'RevokeApproval', {'key': 'examiner'})
                slots = [(key, value) for key, value in h.s.files.items() if key.startswith('B47MCCoop_')]
                newest, _ = max(slots, key=lambda item: int(item[1].split('\n')[0].split('\t')[2]))
                h.s.files[newest] = 'corrupt\n' if damage == 'corrupt' else None
                h.restart()
                h.request()
                self.assertEqual(h.prompts(), 0)
                self.assertEqual(h.actions(), 0)
                self.assertFalse(h.snapshot()['approvalStorageReady'])

    def test_health_care_disables_all_endpoints_for_both_mod_orders(self):
        for mods in ([MODULE, 'B47ANCEDHealthCare'], ['B47ANCEDHealthCare', MODULE]):
            with self.subTest(mods=mods):
                h = Workflow(mods=mods)
                self.assertFalse(plain(h.s.files))
                self.assertFalse(h.server.globals().B47MC.AuthorityRegistered)
                for vm, fixture in h.clients.values():
                    self.assertFalse(vm.globals().B47MC.UIEventsRegistered)
                    self.assertEqual(len(vm.globals().Events.OnServerCommand.callbacks), 0)
                    vm.globals().ISWorldObjectContextMenu.onMedicalCheck(vm.table(), fixture.player, fixture.patient)
                    self.assertTrue(fixture.originalCalled)


if __name__ == '__main__':
    unittest.main(verbosity=2)
