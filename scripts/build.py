"""Lua-only validation entry point. Historical native builds are not executable here."""
import subprocess
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def main():
 for script,args in [('preflight.py',[]),('check_versions.py',['--root',str(ROOT)]),('test.py',[])]:
  subprocess.run([sys.executable,str(ROOT/'scripts'/script),*args],check=True)
 print('STATIC/OFFLINE checks complete; no package, deployment, publication or PZ launch')
if __name__=='__main__': main()
