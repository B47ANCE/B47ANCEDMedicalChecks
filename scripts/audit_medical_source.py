"""Read-only vanilla evidence extraction. Optional development dependency: jawa==2.2.0.

Writes disassembly and numbered Lua ONLY to a new output directory. Never executes
Java/game code, constructs network packets, or changes the installed game.
Bytecode offsets are authoritative coordinates; output line numbers aid navigation.
"""
import argparse
import hashlib
import io
import json
import struct
from pathlib import Path
import zipfile

NATIVE = {
    'zombie/core/Core': ['<clinit>'],
    'zombie/network/packets/RequestMedicalCheckPacket': None,
    'zombie/network/packets/BodyDamageUpdatePacket': None,
    'zombie/network/packets/BodyPartSyncPacket': None,
    'zombie/network/packets/NetTimedActionPacket': None,
    'zombie/network/packets/GeneralActionPacket': None,
    'zombie/network/packets/character/PlayerDamagePacket': None,
    'zombie/network/packets/character/PlayerInjuriesPacket': None,
    'zombie/network/packets/INetworkPacket': None,
    'zombie/network/fields/INetworkPacketField': None,
    'zombie/network/fields/character/PlayerID': None,
    'zombie/network/PacketTypes$PacketType': ['onServerPacket'],
    'zombie/network/PacketTypes$PacketAuthorization': None,
    'zombie/network/BodyDamageSync': None,
    'zombie/network/BodyDamageSync$Updater': None,
    'zombie/core/Action': None,
    'zombie/core/ActionManager': None,
    'zombie/core/NetTimedAction': None,
    'zombie/core/Transaction': None,
    'zombie/core/TransactionManager': None,
    'zombie/network/PZNetKahluaTableImpl': None,
    'zombie/characters/CharacterTimedActions/LuaTimedActionNew': None,
    'zombie/characters/IsoPlayer': ['startReceivingBodyDamageUpdates', 'stopReceivingBodyDamageUpdates'],
    'zombie/Lua/LuaManager$GlobalObject': ['requestMedicalCheck', 'acceptMedicalCheck', 'syncBodyPart', 'sendClientCommand'],
    'zombie/Lua/LuaEventManager': ['triggerEvent', 'AddEvent', 'AddEvents', 'register', 'reroute'],
    'zombie/Lua/LuaManager$Exposer': ['exposeAll', 'shouldExpose'],
    'zombie/Lua/Event': None,
    'zombie/network/GameServer': ['receiveClientCommand', 'disconnectPlayer'],
}
ACTIONS = ['ISApplyBandage', 'ISCleanBurn', 'ISComfreyCataplasm', 'ISDisinfect',
           'ISGarlicCataplasm', 'ISPlantainCataplasm', 'ISRemoveBullet',
           'ISRemoveGlass', 'ISSplint', 'ISStitch']
LUA = ['client/XpSystem/ISUI/ISHealthPanel.lua',
       'client/ISUI/ISWorldObjectContextMenu.lua',
       'client/TimedActions/ISMedicalCheckAction.lua',
       'client/TimedActions/ISTimedActionQueue.lua',
       'server/ClientCommands.lua',
       'shared/TimedActions/ISBaseTimedAction.lua']
LUA = sorted(set(LUA + ['shared/TimedActions/'+a+'.lua' for a in ACTIONS]))

def constant(c):
    if hasattr(c, 'class_') and hasattr(c, 'name_and_type'):
        return c.class_.name.value+'.'+c.name_and_type.name.value+c.name_and_type.descriptor.value
    if hasattr(c, 'string'):
        return repr(c.string.value)
    if hasattr(c, 'name_and_type'):
        return 'dynamic:'+c.name_and_type.name.value+c.name_and_type.descriptor.value
    if hasattr(c, 'name'):
        return c.name.value
    return str(getattr(c, 'value', c))

def disassemble(data, methods):
    from jawa.cf import ClassFile
    cf = ClassFile(io.BytesIO(data))
    lines = ['CLASS '+cf.this.name.value, 'SUPER '+(cf.super_.name.value if cf.super_ else '')]
    attribute = cf.attributes.find_one(name='RuntimeVisibleAnnotations')
    if attribute:
        stream = io.BytesIO(attribute.info)
        def u2():
            return struct.unpack('>H', stream.read(2))[0]
        def value():
            tag = stream.read(1).decode()
            if tag == 'e':
                return [constant(cf.constants.get(u2())), constant(cf.constants.get(u2()))]
            if tag == '[':
                return [value() for _ in range(u2())]
            return constant(cf.constants.get(u2()))
        for _ in range(u2()):
            name, fields = constant(cf.constants.get(u2())), {}
            for _ in range(u2()):
                key = constant(cf.constants.get(u2()))
                fields[key] = value()
            lines.append('ANNOTATION '+name+' '+json.dumps(fields, sort_keys=True))
    for method in cf.methods:
        if methods is not None and method.name.value not in methods:
            continue
        lines.append('METHOD '+method.name.value+method.descriptor.value)
        if not method.code:
            continue
        for ins in method.code.disassemble():
            values = []
            for operand in ins.operands:
                if isinstance(operand, dict):
                    values.append(str(operand))
                elif operand.op_type.name == 'CONSTANT_INDEX':
                    values.append(constant(cf.constants.get(operand.value)))
                elif operand.op_type.name == 'BRANCH':
                    values.append('->'+str(ins.pos+operand.value))
                else:
                    values.append(str(operand.value))
            lines.append(f'  {ins.pos:05d} {ins.mnemonic} '+', '.join(values))
    return '\n'.join(lines)+'\n'

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--game', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    game, out = args.game.resolve(), args.output.resolve()
    assert not out.is_relative_to(game), 'Never write into the game installation'
    out.mkdir(parents=True, exist_ok=False)
    manifest = {'status': 'SOURCE ONLY; native runtime NOT TESTED', 'sha256': {},
                'loose_overrides': [], 'missing': [], 'output_sha256': {}}
    with zipfile.ZipFile(game/'projectzomboid.jar') as archive:
        for cls, methods in NATIVE.items():
            name = cls+'.class'
            if name not in archive.namelist():
                manifest['missing'].append(name)
                continue
            data = archive.read(name)
            manifest['sha256'][name] = hashlib.sha256(data).hexdigest()
            loose = game/name
            if loose.exists() and loose.read_bytes() != data:
                manifest['loose_overrides'].append(name)
            text = disassemble(data, methods)
            target = cls+'.bytecode.txt'
            (out/target).parent.mkdir(parents=True, exist_ok=True)
            (out/target).write_text(text, encoding='utf-8', newline='\n')
            manifest['output_sha256'][target] = hashlib.sha256(text.encode()).hexdigest()
    for name in LUA:
        relative = 'media/lua/'+name
        data = (game/relative).read_bytes()
        manifest['sha256'][relative] = hashlib.sha256(data).hexdigest()
        text = '\n'.join(f'{i}: {line}' for i, line in enumerate(data.decode('utf-8-sig').splitlines(), 1))+'\n'
        target = name+'.numbered.txt'
        (out/target).parent.mkdir(parents=True, exist_ok=True)
        (out/target).write_text(text, encoding='utf-8', newline='\n')
        manifest['output_sha256'][target] = hashlib.sha256(text.encode()).hexdigest()
    (out/'evidence.json').write_text(json.dumps(manifest, indent=2)+'\n', encoding='utf-8')
    print(json.dumps({'output': str(out), 'files': len(manifest['sha256']),
                      'missing': manifest['missing'], 'loose_overrides': manifest['loose_overrides']}, indent=2))

if __name__ == '__main__':
    main()
