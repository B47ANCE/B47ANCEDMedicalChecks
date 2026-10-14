"""Read installed vanilla evidence without Java execution or game modifications."""
import argparse
import hashlib
import json
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[1]
CLASSES=['zombie/core/Core.class','zombie/network/GameServer.class','zombie/network/packets/RequestMedicalCheckPacket.class','zombie/network/packets/BodyDamageUpdatePacket.class','zombie/Lua/LuaManager$GlobalObject.class','zombie/Lua/LuaEventManager.class']
LUA=['media/lua/client/XpSystem/ISUI/ISHealthPanel.lua','media/lua/client/TimedActions/ISMedicalCheckAction.lua','media/lua/client/ISUI/ISWorldObjectContextMenu.lua','media/lua/shared/Translate/EN/UI.json','media/lua/shared/Translate/EN/Sandbox.json']
def main():
 p=argparse.ArgumentParser();p.add_argument('--game',type=Path,required=True);args=p.parse_args()
 expected=json.loads((ROOT/'docs/api-baseline.json').read_text(encoding='utf-8'))
 with zipfile.ZipFile(args.game/'projectzomboid.jar') as z:
  actual={n:hashlib.sha256(z.read(n)).hexdigest() for n in CLASSES}
 for n in LUA: actual[n]=hashlib.sha256((args.game/n).read_bytes()).hexdigest()
 assert actual==expected['sha256'],'Installed evidence differs; audit before extending capabilities'
 for n in CLASSES:
  loose=args.game/n
  if loose.exists() and hashlib.sha256(loose.read_bytes()).hexdigest()!=actual[n]: print('UNKNOWN effective loose override:',n)
 locales=sorted(p.name for p in (args.game/'media/lua/shared/Translate').iterdir() if p.is_dir())
 print('VERIFIED SOURCE: audited 42.21 vanilla JAR/Lua fingerprints match; no Lua packet veto established')
 print('Installed locale folders:',','.join(locales))
 print('Actual engine/dedicated behavior NOT TESTED')
if __name__=='__main__': main()
