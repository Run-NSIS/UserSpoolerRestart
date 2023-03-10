# UserSpoolerRestart
Permits spooler restart to user, take a look here (in italian): https://go.gioxx.org/userspoolerrestart    

Sources:  
https://www.winhelponline.com/blog/view-edit-service-permissions-windows/  
https://learn.microsoft.com/en-us/windows/win32/secauthz/ace-strings  
https://learn.microsoft.com/en-us/windows/win32/services/service-security-and-access-rights

## Security Principal

<table style="border-collapse:collapse;width:100%"><tbody><tr><td style="width:20%"><strong>Abbreviation</strong></td><td style="width:80%"><strong>Security Principal</strong></td></tr><tr><td style="width:20%">AU</td><td style="width:80%">Authenticated Users</td></tr><tr><td style="width:20%">BA</td><td style="width:80%">Built-in administrators</td></tr><tr><td style="width:20%">SY</td><td style="width:80%">Local System</td></tr><tr><td style="width:20%">BU</td><td style="width:80%">Built-in users</td></tr><tr><td style="width:20%">WD</td><td style="width:80%">Everyone</td></tr></tbody></table>

## Security Descriptors meaning
<table style="border-collapse:collapse;width:100%"><tbody><tr><td style="width:20%">D:</td><td style="width:80%">Discretionary ACL (DACL)</td></tr><tr><td style="width:20%">S:</td><td style="width:80%">System Access Control List (SACL)</td></tr></tbody></table>

<table style="border-collapse:collapse;width:100%"><tbody><tr><td style="width:20%"><strong>ACE type</strong></td><td style="width:80%"><strong>Meaning</strong></td></tr><tr><td style="width:20%">A</td><td style="width:80%">Access Allowed</td></tr></tbody></table>

<table style="border-collapse:collapse;width:100%"><tbody><tr><td style="width:20%"><strong>ACE flags string</strong></td><td style="width:40%">Meaning</td><td style="width:40%"></td></tr><tr><td style="width:20%">CC</td><td style="width:40%">SERVICE_QUERY_CONFIG</td><td style="width:40%">Query the SCM for the service configuration</td></tr><tr><td style="width:20%">LC</td><td style="width:40%">SERVICE_QUERY_STATUS</td><td style="width:40%">Query the SCM the current status of the service</td></tr><tr><td style="width:20%">SW</td><td style="width:40%">SERVICE_ENUMERATE_DEPENDENTS</td><td style="width:40%">List dependent services</td></tr><tr><td style="width:20%">LO</td><td style="width:40%">SERVICE_INTERROGATE</td><td style="width:40%">Query the service its current status</td></tr><tr><td style="width:20%">RC</td><td style="width:40%">READ_CONTROL</td><td style="width:40%">Query the security descriptor of the service</td></tr><tr><td style="width:20%">RP</td><td style="width:40%">SERVICE_START</td><td style="width:40%">Start the service</td></tr><tr><td style="width:20%">DT</td><td style="width:40%">SERVICE_PAUSE_CONTINUE</td><td style="width:40%">Pause/Resume the service</td></tr><tr><td style="width:20%">CR</td><td style="width:40%">SERVICE_USER_DEFINED_CONTROL</td><td style="width:40%"></td></tr><tr><td style="width:20%">WD</td><td style="width:40%">WRITE_DAC</td><td style="width:40%">Change the permissions of the service</td></tr><tr><td style="width:20%">WO</td><td style="width:40%">WRITE_OWNER</td><td style="width:40%">Change the owner in the object???s security descriptor.</td></tr><tr><td style="width:20%">WP</td><td style="width:40%">SERVICE_STOP</td><td style="width:40%">Stop the service</td></tr><tr><td style="width:20%">DC</td><td style="width:40%">SERVICE_CHANGE_CONFIG</td><td style="width:40%">Change service configuration</td></tr><tr><td style="width:20%">SD</td><td style="width:40%">DELETE</td><td style="width:40%">The right to delete the service</td></tr></tbody></table>
