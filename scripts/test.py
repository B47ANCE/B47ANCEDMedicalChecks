"""Offline Lua state/storage/UI tests; no actual game behavior is asserted."""
from pathlib import Path
import sys
import json
import re
import unittest
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'.venv-test'))
from lupa import LuaRuntime
sys.path.insert(0,str(ROOT/'scripts'))
from preflight import check
import package as packaging
import io
import zipfile
LUA=ROOT/'src/B47ANCEDMedicalChecks/42/media/lua'
def runtime():
 vm=LuaRuntime(unpack_returned_tuples=True)
 vm.globals().package.path=';'.join((LUA/s/'?.lua').as_posix() for s in ['shared','server','client'])+';'+vm.globals().package.path
 return vm
class Scenarios(unittest.TestCase): pass
for filename in ['engine_spec.lua','client_spec.lua','server_spec.lua','cooperative_spec.lua']:
 specs=runtime().execute((ROOT/'tests'/filename).read_text(encoding='utf-8'))
 for name in specs.keys():
  def scenario(self,fn=filename,key=name):
   vm=runtime();tests=vm.execute((ROOT/'tests'/fn).read_text(encoding='utf-8'));tests[key]()
  setattr(Scenarios,'test_'+filename.split('_')[0]+'_'+name,scenario)
class Structure(unittest.TestCase):
 def test_lua_syntax(self):
  vm=runtime()
  for p in LUA.rglob('*.lua'): vm.compile(p.read_text(encoding='utf-8'))
 def test_lua_only(self): check()
 def test_localization_keys_values_placeholders(self):
  from write_localization import UI,SANDBOX,LOCALES
  for locale in LOCALES:
   for category,expected in [('UI',{'UI_B47MC_'+k:v for k,v in UI.items()}),('Sandbox',SANDBOX)]:
    self.assertEqual(json.loads((LUA/'shared/Translate'/locale/(category+'.json')).read_text(encoding='utf-8')),expected)
  for p in LUA.rglob('*.lua'):
   for key in re.findall(r'getText\("UI_B47MC_([^"]+)"',p.read_text(encoding='utf-8')): self.assertIn(key,UI)
 def test_no_medical_hook_or_global_database(self):
  for p in LUA.rglob('*.lua'):
   self.assertNotRegex(p.read_text(encoding='utf-8'),r'Events\.(RequestMedicalCheck|AcceptedMedicalCheck)|ISMedicalCheckAction|ModData\.(transmit|getOrCreate)|B47MCNative')
 def test_package_plan_excludes_historical_java_and_private_snapshots(self):
  mapping=packaging.collect();packaging.safe_names(list(mapping))
  for name in mapping: self.assertNotRegex(name,r'/(native|history|research|dist|handoff)/|source-evidence|current-api-evidence')
 def test_package_rejects_unsafe_and_case_colliding_paths(self):
  for names in [['../x'],['/x'],['C:/x'],['a\\b'],['a','a'],['A','a'],['x.jar']]:
   with self.assertRaises(AssertionError): packaging.safe_names(names)
 def test_fixture_zip_crc_data_and_manifest_validation(self):
  import tempfile,hashlib
  with tempfile.TemporaryDirectory() as temp:
   p=Path(temp)/'fixture.txt';p.write_bytes(b'fixture-body')
   name='B47ANCEDMedicalChecks/fixture.txt';mapping={name:p};buffer=io.BytesIO()
   manifest={'project_version':(ROOT/'VERSION').read_text().strip(),'sha256':{name:hashlib.sha256(p.read_bytes()).hexdigest()}}
   with zipfile.ZipFile(buffer,'w',zipfile.ZIP_STORED) as archive:
    archive.writestr(name,p.read_bytes());archive.writestr('B47ANCEDMedicalChecks/PACKAGE_MANIFEST.json',json.dumps(manifest))
   with zipfile.ZipFile(io.BytesIO(buffer.getvalue())) as archive: packaging.verify(archive,mapping)
   bad=buffer.getvalue().replace(b'fixture-body',b'fixture-b0dy',1)
   with zipfile.ZipFile(io.BytesIO(bad)) as archive:
    with self.assertRaises(AssertionError): packaging.verify(archive,mapping)
 def test_fixture_zip_unexpected_member_rejected(self):
  buffer=io.BytesIO()
  with zipfile.ZipFile(buffer,'w') as archive: archive.writestr('unexpected.txt','x')
  with zipfile.ZipFile(io.BytesIO(buffer.getvalue())) as archive:
   with self.assertRaises(AssertionError): packaging.verify(archive,{})
 def test_historical_files_preserved(self):
  import hashlib
  h=ROOT/'history/java-era-0.1.0-dev.1';manifest=h/'preservation-manifest.json'
  if not manifest.exists(): self.skipTest('Local historical preservation manifest not distributed')
  for name,digest in json.loads(manifest.read_text()).items():
   path=h/name if (h/name).exists() else ROOT/name
   self.assertEqual(hashlib.sha256(path.read_bytes()).hexdigest(),digest,name)
if __name__=='__main__': unittest.main(verbosity=2)
