"""Write reviewed English fallback text to installed vanilla locale identifiers."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
LOCALES='AR CA CH CN CS DA DE EN ES ES_CL ES_MX FI FR HU ID IT JP KO NL NO PL PT PTBR RO RU STREW TH TR UA'.split()
UI={
 'Waiting':'Examination requested. Waiting for a response; dismissing this notice does not cancel the request.',
 'ApprovalStorageFailed':'Approval storage is unavailable; examination requests are disabled.',
 'WorkflowDisabled':'Medical Checks is disabled by the server; the context action uses vanilla approval.',
 'Settings':'Medical Checks settings',
 'Loading':'Loading server settings...',
 'AlwaysAsk':'Always Ask',
 'OnlyOnce':'Only Ask Once Per Player',
 'Draft':'Choose when to ask and manage remembered examiners.',
 'Revoke':'Revoke selected approval', 'Refresh':'Refresh',
 'NoApprovals':'No saved approval records',
 'Blocked':'Preferences loaded.',
 'Saved':'Preferences saved.',
 'Invalid':'Invalid setting or saved record; no change was made.',
 'RateLimited':'Changes are too fast; no change was made. Wait briefly and try again.',
 'StorageFailed':'Server settings storage unavailable; changes disabled. Vanilla remains unchanged.',
 'ProtocolMismatch':'Mod versions do not match. Update the client mod and reconnect.',
 'Policy1':'Server policy: Player Choice',
 'Policy2':'Server policy: Force Always Ask',
 'Policy3':'Server policy: Force Only Ask Once',
 'Policy4':'Server policy: No Examination Requests',
}
UI.update({'InactiveRecord': 'Legacy inactive record: %1', 'CooperativeWarning': 'Manage remembered examiners in Medical Checks settings.', 'AllowExaminer': 'Allow %1 to examine you?', 'RememberApproval': 'Yes remembers this examiner for future checks until revoked (subject to server retention).', 'AskEveryTime': 'Approval applies to this examination only.', 'ResultRefused': 'The patient declined this examination.', 'ResultExpired': 'The request expired or a participant moved/disconnected. Try again when nearby.', 'ResultRevoked': 'The patient revoked this approval.', 'ResultPolicyDenied': 'This server policy disables examination requests.', 'ResultUnavailable': 'The participant or request service is unavailable. No examination was opened.', 'ResultBusy': 'Another examination request is pending. Wait and try again.', 'ResultRateLimited': 'Please wait before sending another request.', 'ResultStorageFailed': 'The approval could not be verified in storage. No examination was opened.'})
SANDBOX={'Sandbox_B47ANCEDMedicalChecks':"B47ANCE'd Medical Checks"}
options={
 'CooperativeConsent':('Enable examination requests',[]),
 'Policy':('Examination approval policy',['Player Choice','Force Always Ask','Force Only Ask Once','No Examination Requests']),
 'DefaultPreference':('Default player preference',['Always Ask','Only Ask Once Per Player']),
 'Retention':('Approval retention',['Persistent Until Revoked','Until Either Player Disconnects']),
 'RequestCooldown':('Request cooldown (seconds)',[]),
 'RequestTimeout':('Response timeout (seconds)',[]),
 'DebugLogging':('Decision diagnostics',[]),
}
TOOLTIPS={
 'CooperativeConsent':'Enable Medical Checks approval requests. When disabled, the context action uses vanilla approval.',
 'Policy':'Let players choose, require approval every time, remember each examiner after approval, or disable examination requests.',
 'DefaultPreference':'Initial preference for players without a saved choice. Forced server policies override individual choices.',
 'Retention':'Keep approvals across reconnects and restarts, or clear session approvals when either player disconnects. Returning to Persistent reuses stored approvals until revoked.',
 'RequestCooldown':'Minimum delay between examination requests from one examiner.',
 'RequestTimeout':'Time allowed to answer or confirm an examination request before it expires.',
 'DebugLogging':'Write examination request decision codes to the server console for troubleshooting.',
}
for key,(label,choices) in options.items():
 prefix='Sandbox_B47MC_'+key
 SANDBOX[prefix]=label
 SANDBOX[prefix+'_tooltip']=TOOLTIPS[key]+' Inactive while Health Care is enabled.'
 for i,choice in enumerate(choices,1): SANDBOX[prefix+'_option'+str(i)]=choice
def main():
 for language in LOCALES:
  folder=ROOT/'src/B47ANCEDMedicalChecks/42/media/lua/shared/Translate'/language
  folder.mkdir(parents=True,exist_ok=True)
  for category,values in [('UI',{'UI_B47MC_'+k:v for k,v in UI.items()}),('Sandbox',SANDBOX)]:
   (folder/(category+'.json')).write_text(json.dumps(values,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
if __name__=='__main__': main()
