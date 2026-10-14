"""Write reviewed English fallback text to installed vanilla locale identifiers."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
LOCALES='AR CA CH CN CS DA DE EN ES ES_CL ES_MX FI FR HU ID IT JP KO NL NO PL PT PTBR RO RU STREW TH TR UA'.split()
UI={
 'Settings':'Medical consent status and saved preferences',
 'Loading':'Loading server settings; consent enforcement is unavailable.',
 'AlwaysAsk':'Always Ask (saved preference; inactive)',
 'OnlyOnce':'Only Ask Once Per Player (saved preference; inactive)',
 'Draft':'Saved preferences and approvals are inactive; vanilla examinations remain unchanged.',
 'Revoke':'Revoke selected saved record', 'Refresh':'Refresh',
 'NoApprovals':'No saved approval records',
 'Blocked':'Server consent enforcement is blocked; vanilla examinations remain unchanged.',
 'Saved':'Settings saved. This does not change vanilla examination permission.',
 'Invalid':'Invalid setting or saved record; no change was made.',
 'RateLimited':'Changes are too fast; no change was made. Wait briefly and try again.',
 'StorageFailed':'Server settings storage unavailable; changes disabled. Vanilla remains unchanged.',
 'ProtocolMismatch':'Update the client mod. Consent enforcement is unavailable.',
 'Policy1':'Configured policy: Player Choice (enforcement inactive)',
 'Policy2':'Configured policy: Force Always Ask (enforcement inactive)',
 'Policy3':'Configured policy: Force Only Ask Once (enforcement inactive)',
 'Policy4':'Configured policy: No Examination Requests (enforcement inactive)',
}
SANDBOX={'Sandbox_B47ANCEDMedicalChecks':"B47ANCE'd Medical Checks (consent enforcement blocked)"}
options={
 'Policy':('Configured consent policy',['Player Choice','Force Always Ask','Force Only Ask Once','No Examination Requests']),
 'DefaultPreference':('Default saved preference',['Always Ask','Only Ask Once Per Player']),
 'Retention':('Reserved approval retention',['Persistent Until Revoked','Until Patient Disconnects']),
 'RequestCooldown':('Reserved denial cooldown (seconds)',[]),
 'RequestTimeout':('Reserved request timeout (seconds)',[]),
 'DebugLogging':('Reserved decision diagnostics',[]),
}
for key,(label,choices) in options.items():
 prefix='Sandbox_B47MC_'+key
 SANDBOX[prefix]=label
 SANDBOX[prefix+'_tooltip']='Consent enforcement is BLOCKED in this Lua-only build. Vanilla medical requests and health data remain unchanged. Only Policy and DefaultPreference affect saved-settings presentation; retention, request timing and decision diagnostics are reserved and inactive.'
 for i,choice in enumerate(choices,1): SANDBOX[prefix+'_option'+str(i)]=choice
def main():
 for language in LOCALES:
  folder=ROOT/'src/B47ANCEDMedicalChecks/42/media/lua/shared/Translate'/language
  folder.mkdir(parents=True,exist_ok=True)
  for category,values in [('UI',{'UI_B47MC_'+k:v for k,v in UI.items()}),('Sandbox',SANDBOX)]:
   (folder/(category+'.json')).write_text(json.dumps(values,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
if __name__=='__main__': main()
