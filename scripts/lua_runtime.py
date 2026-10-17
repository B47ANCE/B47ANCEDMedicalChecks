"""Offline Lua hosts. These are not PZ/Kahlua or multiplayer runtime evidence."""
import importlib
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LUA = ROOT / 'src/B47ANCEDMedicalChecks/42/media/lua'


def runtime():
    host = os.environ.get('B47MC_TEST_LUA', 'lua54')
    if host not in ('lua51', 'lua54'):
        raise ValueError('B47MC_TEST_LUA must be lua51 or lua54')
    vm = importlib.import_module('lupa.' + host).LuaRuntime(unpack_returned_tuples=True)
    paths = [LUA / side / '?.lua' for side in ('shared', 'server', 'client')]
    paths.append(ROOT / 'tests/support/?.lua')
    vm.globals().package.path = ';'.join(p.as_posix() for p in paths) + ';' + vm.globals().package.path
    return vm
