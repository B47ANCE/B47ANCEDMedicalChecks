"""Write reviewed English fallback text to installed vanilla locale identifiers."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
LOCALES='AR CA CH CN CS DA DE EN ES ES_CL ES_MX FI FR HU ID IT JP KO NL NO PL PT PTBR RO RU STREW TH TR UA'.split()
UI={
 'Waiting':'Cooperative examination requested. Waiting for the patient/server; dismissing this notice does not cancel the request.',
 'ApprovalStorageFailed':'Cooperative approval storage is unavailable; examinations through this workflow are disabled.',
 'WorkflowDisabled':'Cooperative workflow disabled by the server; the ordinary context action uses vanilla approval.',
 'Settings':'Medical consent status and saved preferences',
 'Loading':'Loading server settings; consent enforcement is unavailable.',
 'AlwaysAsk':'Always Ask',
 'OnlyOnce':'Only Ask Once Per Player',
 'Draft':'Cooperative UI only; modified clients can bypass consent. Native privacy is not enforced.',
 'Revoke':'Revoke selected saved record', 'Refresh':'Refresh',
 'NoApprovals':'No saved approval records',
 'Blocked':'Cooperative preferences loaded. Native server consent enforcement remains blocked.',
 'Saved':'Saved for the cooperative workflow; native access is not protected.',
 'Invalid':'Invalid setting or saved record; no change was made.',
 'RateLimited':'Changes are too fast; no change was made. Wait briefly and try again.',
 'StorageFailed':'Server settings storage unavailable; changes disabled. Vanilla remains unchanged.',
 'ProtocolMismatch':'Update the client mod. Consent enforcement is unavailable.',
 'Policy1':'Cooperative policy: Player Choice (UI workflow only)',
 'Policy2':'Cooperative policy: Force Always Ask (UI workflow only)',
 'Policy3':'Cooperative policy: Force Only Ask Once (UI workflow only)',
 'Policy4':'Cooperative policy: No Examination Requests (UI workflow only)',
}
UI.update({'InactiveRecord': 'Legacy inactive record: %1', 'CooperativeWarning': 'Cooperative convenience only. Modified clients can bypass this; native health access is not protected.', 'AllowExaminer': 'Allow %1 to examine you?', 'RememberApproval': 'Yes remembers this examiner for future cooperative checks until revoked (subject to server retention).', 'AskEveryTime': 'Approval applies to this cooperative examination only.', 'ResultRefused': 'The patient declined this examination.', 'ResultExpired': 'The request expired or a participant moved/disconnected. Try again when nearby.', 'ResultRevoked': 'The patient revoked this cooperative approval.', 'ResultPolicyDenied': 'This server policy disables cooperative examination requests.', 'ResultUnavailable': 'The cooperative workflow or participant is unavailable. No examination was opened.', 'ResultBusy': 'Another cooperative examination request is pending. Wait and try again.', 'ResultRateLimited': 'Please wait before sending another request.', 'ResultStorageFailed': 'The approval could not be verified in storage. No examination was opened.'})
SANDBOX={'Sandbox_B47ANCEDMedicalChecks':"B47ANCE'd Medical Checks (consent enforcement blocked)"}
options={
 'CooperativeConsent':('Enable cooperative consent workflow',[]),
 'Policy':('Configured consent policy',['Player Choice','Force Always Ask','Force Only Ask Once','No Examination Requests']),
 'DefaultPreference':('Default saved preference',['Always Ask','Only Ask Once Per Player']),
 'Retention':('Cooperative approval retention',['Persistent Until Revoked','Until Either Player Disconnects']),
 'RequestCooldown':('Cooperative request cooldown (seconds)',[]),
 'RequestTimeout':('Cooperative response timeout (seconds)',[]),
 'DebugLogging':('Cooperative decision diagnostics',[]),
}
for key,(label,choices) in options.items():
 prefix='Sandbox_B47MC_'+key
 SANDBOX[prefix]=label
 SANDBOX[prefix+'_tooltip']='Controls the cooperative UI workflow only. Modified clients and native medical packets can bypass it; server medical privacy remains BLOCKED. Disabling the workflow restores the vanilla context action. Retention applies to new cooperative approvals; legacy records remain inactive. Revocation affects future cooperative checks, not open native panels.'
 for i,choice in enumerate(choices,1): SANDBOX[prefix+'_option'+str(i)]=choice
def main():
 for language in LOCALES:
  folder=ROOT/'src/B47ANCEDMedicalChecks/42/media/lua/shared/Translate'/language
  folder.mkdir(parents=True,exist_ok=True)
  for category,values in [('UI',{'UI_B47MC_'+k:v for k,v in UI.items()}),('Sandbox',SANDBOX)]:
   (folder/(category+'.json')).write_text(json.dumps(values,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
if __name__=='__main__': main()
