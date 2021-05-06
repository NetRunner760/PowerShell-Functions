# Enable-AutoAcct-RegKeys
# Changes the autologin reg key values to 1
# Juan Parra
# 1/22/2021

function EnableAutoLogon {
    Write-Host "Re-enabling Autologin for $User"
    Invoke-Command -Session $Session -ScriptBlock { Set-Itemproperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon' -Value '1'} 
    Invoke-Command -Session $Session -ScriptBlock { Set-Itemproperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'forceautologon' -Value '1'} | Remove-PSSession -Session $Session
}

function Set-PSSession {
    New-PSSession -ComputerName $Computer -Credential $c
}

#StartScript
Clear-Host
$c = Get-Credential -Message 'Enter your Credentials'
$Computer = Read-Host -Prompt 'Target Computer'
$Session = Set-PSSession
EnableAutoLogon