# Disable-autoAcct-RegKeys
# Changes the autologin reg key values to 0
# Juan Parra
# 1/22/2021

function DisableAutoLogon {
    Write-Host "Disabling autologin"
        Invoke-Command -Session $Session -ScriptBlock { Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon' -value '0'}
        Invoke-Command -Session $Session -ScriptBlock { Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'forceautologon' -value '0'} | Remove-PSSession -Session $Session
}

function Set-PSSession {
    New-PSSession -ComputerName $Computer -Credential $c
}

#StartScript
Clear-Host
$c = Get-Credential -Message 'Enter your Credentials'
$Computer = Read-Host -Prompt 'Target Computer'
$Session = Set-PSSession
DisableAutoLogon