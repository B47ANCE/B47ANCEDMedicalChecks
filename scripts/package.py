"""Plan/verify Lua-only package inputs. --development explicitly creates a local test ZIP."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import zipfile
from preflight import ROOT,check
def collect():
 check(); mapping={}
 prefix='B47ANCEDMedicalChecks/'
 for folder in ['src','docs','scripts','tests']:
  for p in sorted((ROOT/folder).rglob('*')):
   if p.is_file() and '__pycache__' not in p.parts and p.name not in {'source-evidence.json','current-api-evidence.json'}:
    mapping[prefix+p.relative_to(ROOT).as_posix()]=p
 for name in ['VERSION','README.md','CHANGELOG.md','WORKSHOP_CHANGE_NOTE.txt','version-inventory.json','REPOSITORY.md','requirements-dev.txt','thumbnail.png']:
  mapping[prefix+name]=ROOT/name
 for p in check():
  mapping[prefix+'Contents/mods/B47ANCEDMedicalChecks/'+p.relative_to(ROOT/'src/B47ANCEDMedicalChecks').as_posix()]=p
 return mapping
def safe_names(names):
 assert len(names)==len(set(names)), 'duplicate ZIP member'
 assert len(names)==len(set(n.casefold() for n in names)), 'case-colliding ZIP members'
 for n in names:
  p=PurePosixPath(n)
  assert not p.is_absolute() and '..' not in p.parts and '\\' not in n and ':' not in n, 'unsafe ZIP member'
  assert p.suffix.lower() not in {'.java','.jar','.class','.dll','.so','.exe'}, 'non-Lua dependency'
def verify(archive,mapping):
 names=archive.namelist();safe_names(names)
 assert set(names)==set(mapping)|{'B47ANCEDMedicalChecks/PACKAGE_MANIFEST.json'}, 'unexpected member'
 assert archive.testzip() is None, 'CRC failure'
 for name,path in mapping.items(): assert archive.read(name)==path.read_bytes(),name
 manifest=json.loads(archive.read('B47ANCEDMedicalChecks/PACKAGE_MANIFEST.json'))
 assert manifest['project_version']==(ROOT/'VERSION').read_text().strip()
 assert manifest['sha256']=={n:hashlib.sha256(p.read_bytes()).hexdigest() for n,p in mapping.items()}
def main():
 parser=argparse.ArgumentParser();parser.add_argument('--development',action='store_true');args=parser.parse_args()
 mapping=collect();safe_names(list(mapping))
 if not args.development:
  print('STATIC PASS: package plan only; no ZIP created; historical artifacts untouched');return
 version=(ROOT/'VERSION').read_text().strip()
 out=ROOT/'dist/lua-only-current'/('B47ANCEDMedicalChecks-development-'+version+'.zip')
 out.parent.mkdir(parents=True,exist_ok=True)
 if out.exists(): raise SystemExit('Artifact exists; preserve it. Choose an explicit retention/version plan before replacement.')
 with zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED) as z:
  for name,path in mapping.items(): z.writestr(name,path.read_bytes())
  z.writestr('B47ANCEDMedicalChecks/PACKAGE_MANIFEST.json',json.dumps({'project_version':version,'status':'development build; dedicated multiplayer NOT TESTED','sha256':{n:hashlib.sha256(p.read_bytes()).hexdigest() for n,p in mapping.items()}},indent=2))
 with zipfile.ZipFile(out) as z: verify(z,mapping)
 out.with_suffix('.zip.sha256').write_text(hashlib.sha256(out.read_bytes()).hexdigest()+'  '+out.name+'\n',encoding='utf-8')
 print('OFFLINE package integrity PASS:',out)
if __name__=='__main__': main()
