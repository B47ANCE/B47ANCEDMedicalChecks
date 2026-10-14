"""Lua-only/static release-surface checks. Never invokes Java, a game or a compiler."""
from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[1]
SOURCE=ROOT/'src/B47ANCEDMedicalChecks'
def check():
 files=[p for p in SOURCE.rglob('*') if p.is_file()]
 keys=[p.relative_to(SOURCE).as_posix().casefold() for p in files]
 assert len(keys)==len(set(keys)), 'case-colliding source paths'
 for p in files:
  assert p.suffix.lower() not in {'.java','.jar','.class','.dll','.so','.exe'}, p
  if p.suffix=='.lua' or p.name=='mod.info':
   text=p.read_text(encoding='utf-8')
   assert not re.search(r'B47MCNative|javaagent|luajava|loadJava|Premain-Class',text), p
 source_lua=[p for p in files if p.suffix=='.lua']
 module_paths={p.relative_to(SOURCE/'42/media/lua'/side).as_posix()[:-4] for side in ['shared','client','server'] for p in (SOURCE/'42/media/lua'/side).rglob('*.lua')}
 for p in source_lua:
  for name in re.findall(r'require\s*"(B47ANCEDMedicalChecks/[^"]+)"',p.read_text(encoding='utf-8')):
   assert name in module_paths, 'case/require mismatch: '+name
 print('STATIC PASS: Lua-only active source; case-correct internal requires')
 return files
if __name__=='__main__': check()
