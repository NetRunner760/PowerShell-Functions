# Get-Computer
# Sets computer name variable and tests connection. 
# Test function will intentionally break the script if computer is offline or hostname is bad, this is intended to be a failsafe.
# Juan Parra
# 4/20/21

function Bump {
    Write-Host
    Write-Host
}
function Get-Computer {
    Read-Host -Prompt 'Target Computer'
}
function Test-Computer {
    if (!(Test-Connection -ComputerName $Computer -count 1 -quiet -ErrorAction SilentlyContinue)) {
        [void] [System.Windows.MessageBox]::Show( "Unable to contact $Computer. Please verify hostname / network connectivity and try again.", "Network Error", "OK", "Information" )
        Write-Host "Unable to contact $Computer. Please verify hostname / network connectivity and try again." -for red
        Break
    }
}

#_________*StartScript*_________
Clear-Host
$Computer = Get-Computer
Test-Computer