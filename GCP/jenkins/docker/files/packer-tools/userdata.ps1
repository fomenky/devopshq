<powershell>
# Set Execution Policy
Write-Output "Setting execution policy"
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force -ErrorAction Ignore
$ErrorActionPreference = "stop"

## Create utility scripts
New-Item -Path "$env:ALLUSERSPROFILE\GetBusy\DevOps\Scripts" -ItemType "directory"
New-Item -Path "$env:ALLUSERSPROFILE\GetBusy\DevOps\Libs" -ItemType "directory"
New-Item -Path "$env:ALLUSERSPROFILE\GetBusy\DevOps\Logs" -ItemType "directory"
New-Item -Path "$env:USERPROFILE\Downloads\GetBusy\DevOps" -ItemType "directory"

@'
function Enable-RemoteConfigSecure {
  [CmdletBinding()]
  Param(
    [uint16]$WinRMPort = 5986,
    [uint32]$WinRMTimeout = 1800000,
    [uint16]$IsTrace = 0
  )

  Set-PSDebug -Trace $IsTrace

  Write-Output "[$(Get-Date -Format HH:mm:ss)] Creating self-signed certificate"

  $instanceFqdn = Get-EC2InstanceMetadata -Category PublicHostname
  if ( ! $instanceFqdn ) {
    $instanceFqdn = Get-EC2InstanceMetadata -Category LocalHostname
  }
  $winRmCert = New-SelfSignedCertificate -DnsName $instanceFqdn -CertStoreLocation Cert:\LocalMachine\My


  Write-Output "[$(Get-Date -Format HH:mm:ss)] Configuring WinRM service"

  Enable-PSRemoting -Force -SkipNetworkProfileCheck
  Set-WSManQuickConfig -SkipNetworkProfileCheck -Force
  Set-Item WSMan:\LocalHost\MaxTimeoutms -Value $WinRMTimeout
  Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*" -Force
  Set-Item WSMan:\LocalHost\Service\AllowUnencrypted -Value $false
  Set-Item WSMan:\LocalHost\Client\AllowUnencrypted -Value $false
  Set-Item WSMan:\LocalHost\Service\Auth\Basic -Value $true
  Set-Item WSMan:\LocalHost\Client\Auth\Basic -Value $true
  Set-Item WSMan:\LocalHost\Service\Auth\CredSSP -Value $true

  Write-Output "[$(Get-Date -Format HH:mm:ss)] Configuring WinRM listener"

  Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse
  New-Item -Path WSMan:\Localhost\Listener -Transport HTTPS -Port $WinRMPort -Address * -Hostname $instanceFqdn -CertificateThumbprint $winRmCert.Thumbprint -Force

  Write-Output "[$(Get-Date -Format HH:mm:ss)] Allowing WinRM in Firewall"
  New-NetFirewallRule -DisplayName "Allow Remote-Configuration (HTTPS-In)" -Name "Allow TCP $WinRMPort" -Direction Inbound -Profile Any -Action Allow -Protocol TCP -LocalPort $WinRMPort -RemoteAddress Any

  Write-Output "[$(Get-Date -Format HH:mm:ss)] Starting WinRM"
  Stop-Service WinRM
  Set-Service WinRM -StartMode Automatic
  Start-Service WinRM

  Set-PSDebug -Trace 0
}
'@ | Set-Content -Path $env:ALLUSERSPROFILE\GetBusy\DevOps\Libs\Userdata.ps1


## Execute scripts
Import-Module $env:ALLUSERSPROFILE\GetBusy\DevOps\Libs\Userdata.ps1 -Force

Enable-RemoteConfigSecure
</powershell>
