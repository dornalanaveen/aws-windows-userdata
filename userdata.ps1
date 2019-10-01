$REGION="%s"
$STACK_NAME="%s"
$ENVIRONMENT="%s"
$NODELABEL="%s"
$INSTANCE_ID = Invoke-RestMethod -uri http://169.254.169.254/latest/meta-data/instance-id
$HOSTNAME = $INSTANCE_ID.TrimStart('i', '-')
$HOSTNAME = $HOSTNAME.Remove($HOSTNAME.Length - 2)
$LOCAL_IP = Invoke-RestMethod -uri http://169.254.169.254/latest/meta-data/local-ipv4
$USERNAME ='domain\sa-exampleserviceaccount'
$PASSWORD = 'changeme'
$SECUREPASSWORD = $PASSWORD | ConvertTo-SecureString -AsPlainText -Force
$CREDENTIAL = New-Object System.Management.Automation.PsCredential($USERNAME, $SECUREPASSWORD)
Install-PackageProvider -Name NuGet -Force
Install-Module -Name AWSPowerShell -Scope CurrentUser -Force
new-item c:\Code -itemtype directory
invoke-webrequest -uri https://raw.githubusercontent.com/examplerepo/win-server-provision/master/ConfigureAnsible.ps1 -outfile c:\Code\ConfigureAnsible.ps1 -headers @{'Authorization'='token inserttokenhere'}
C:\Code\ConfigureAnsible.ps1 -ForceNewSSLCert -EnableCredSSP -Verbose
Add-Computer -DomainName domain.example.com -Credential $CREDENTIAL -Options JoinWithNewName,AccountCreate -Force
$Computer = Get-WmiObject Win32_ComputerSystem
Sleep 10
$RESULT = $Computer.Rename("$HOSTNAME", $CREDENTIAL.GetNetworkCredential().Password, $CREDENTIAL.Username)
Sleep 10
$NAMETAG = -join($ENVIRONMENT, "-", $STACK_NAME, "0", $NODELABEL)
$EXTENDEDNAMETAG = -join($ENVIRONMENT, "-", $STACK_NAME, "0", $NODELABEL, "-", $REGION, "-", $LOCAL_IP)
$TAG = New-Object Amazon.EC2.Model.TAG
$TAG.Key = "Name"
$TAG.Value = $NAMETAG
New-EC2TAG -Resource $INSTANCE_ID -tags $TAG
Sleep 10
$TAG = New-Object Amazon.EC2.Model.TAG
$TAG.Key = "ExtendedName"
$TAG.Value = $EXTENDEDNAMETAG
New-EC2TAG -Resource $INSTANCE_ID -tags $TAG
Restart-Computer -Force
