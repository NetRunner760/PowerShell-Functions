# Remote-Restart_MSTR
# Juan Parra
# 03/31/2021
#---------------------------------------------------------------------#
<#
.DESCRIPTION
Master Functions file for: Remote-Restart script.

.NOTES
    Version 1.0: ------- 03/31/21
        Initial Release.

    Version 1.1: ------- 04/06/21
        Added in shell Yes or No prompt function.

    Version 1.2: ------- 04/26/21
        Condensed $Computer variable code into Get-Computer function. 
        Added Test-Computer function to test for correct Hostname / active Network connection before doing anything else.

    Version 1.3: ------- 05/03/21
        Cleaned up formating, revised function order, and aliases. 
        Implemented introductional comment block.
        Moved functions onto a separate "Master Functions File". Which imports before StartScript, enabling the calling of said functions.
#>
#---------------------------------------------------------------------#
# ---------------------- Begin Functions ---------------------------- #
function Bump {
    Write-Host
    Write-Host
} <#
.Description: Bump
    Adds 2 blank spaces for easier reading of command output.
#>
function Write-ScriptTitle {
$Title = 'Remote-Restart'
    Clear-Host 
    Write-Host `n$('>' * ($Title.length))`n$Title`n$('<' * ($Title.length))`n -ForegroundColor Red
} <#
.Description: Write-ScriptTitle
    Displays script title on script start.
#>
function Get-Computer {
    Read-Host -Prompt 'Target Computer'
} <#
.Description: Get-Computer
    Prompts user for a target computer.
#>
function Test-Computer {
    if (!(Test-Connection -ComputerName $Computer -count 1 -quiet -ErrorAction SilentlyContinue)) {
        Bump
        Write-Host "Unable to contact $Computer. Please verify hostname / network connectivity and try again." -for red
        [void] [System.Windows.MessageBox]::Show( "Unable to contact $Computer. Please verify hostname / network connectivity and try again.", "Network Error", "OK", "Information" )
        Break
    }
} <#
.Description: Test-Computer
    Pings computer to verify the Hostname is valid and Network connection is active before continuing script.
#>
function Start-Restart {
    Bump
    Write-Host "Restarting $Computer" -ForegroundColor White
    Restart-Computer -Force -ComputerName $Computer
} <#
.Description: Start-Restart
    Restarts specified computer.
#>
function Confirm-Restart {
    Bump
    $title = Write-Host "Confirm Restart: " -ForegroundColor Yellow

    $message = Write-Host "Are you sure you want to restart $Computer ? " -ForegroundColor Yellow

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Restarts $Computer"
    
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Ends script"
    
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 
    switch ($result)
        {
            0 { Start-Restart }
            1 { Bump
                Write-Host "Restart Cancelled" -ForegroundColor Yellow
                Exit }
        }
} <#
.Description: Confirm-Restart
    Prompts to confirm you want to restart the target computer.
#>
function Request-Ping {
    Bump
    $title = Write-Host "Ping Prompt: " -ForegroundColor Yellow

    $message = Write-Host "Do you want to ping $Computer ? " -ForegroundColor Yellow

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Pings $Computer"
    
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Ends script"
    
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $options, 1) 
    switch ($result)
        {
            0 { ping -n 169 $Computer }
            1 { Bump
                Write-Host "Skipped Ping" -ForegroundColor Yellow
                Exit }
        }
} <#
.Description: Request-Ping
    Prompts if you want to run the ping function.
#>
function Write-ScriptEnd {
$End = 'Script has completed.'
    Write-Host `n$('>' * ($End.length))`n$End`n$('<' * ($End.length))`n -ForegroundColor Red
} <# 
.Description Write-ScriptEnd
    Displays script completion message.
#>
#---------------------------------------------------------------------#
# ----------------------- End of Functions -------------------------- #