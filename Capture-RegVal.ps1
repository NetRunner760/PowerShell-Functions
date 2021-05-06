# Capture-RegVal
# Tests the path and captures the value of the named key if the specified key exists. Returns error if non-existent.
# Juan Parra
# 04/30/21

Function Capture-Val {
    Test-Computer
     if ( $TV = Invoke-Command -Computer $Computer {Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'TestVal1' -ErrorAction Ignore}) {
         Write-Host "Value is $TV" -for blue
     } else {
         Write-Host 'TestVal1 does not exist at the specified Registry location' -for red
     }
 }