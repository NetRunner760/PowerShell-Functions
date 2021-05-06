# Test-Val
# Checks specified registry value for existence and reports to user.
# Juan Parra
# 04/30/21

Function Test-RegistryValue {
    if (Invoke-Command -Computer $Computer {Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'TestVal12' -ErrorAction Ignore}) {
        'Detected, kill it with fire'
    } else {
        'Nah Foo its not here'
    }
}