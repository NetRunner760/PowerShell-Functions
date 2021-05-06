# Switch-AutoLogon_MSTR
# Juan Parra
# 04/30/2021
#---------------------------------------------------------------------#
<#
.DESCRIPTION
Master Functions file for: Switch-AutoLogon script.

.NOTES
    Version 1.0: ------- 04/30/21
        Researched methods, wrote up initial functions, and tested functionality.

    Version 1.1: ------- 05/01/21
        Combined enable and disable key scripts. 
            Added in shell Yes or No prompt function to tie in enable key function.
                Created a function to check, capture, and display the current key value for value verification.

    Version 1.2: ------- 05/03/21
        Corrected and finalized Show-Result functions.
            Cleaned up formating, revised function order, and names. 
                Implemented introductional comment block, with change notes.
                    Moved functions onto a separate "Master Functions File", which imports before StartScript. Enabling the calling of said functions and cleaning up appearance.
                        Imported Write-ScriptTitle / End functions.
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
    $Title = 'Switch-AutoLogon'
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
    Bump
    if (!(Test-Connection -ComputerName $Computer -count 1 -quiet -ErrorAction SilentlyContinue)) {
        Write-Host "Unable to contact $Computer. Please verify hostname / network connectivity and try again." -ForegroundColor red
        [void] [System.Windows.MessageBox]::Show( "Unable to contact $Computer. Please verify hostname / network connectivity and try again.", "Network Error", "OK", "Information" )
        Break
    }
} <#
.Description: Test-Computer
    Pings computer to verify the Hostname is valid and Network connection is active before continuing script.
#>
function Get-Creds {
    Get-Credential -Message 'Enter your Credentials'
} <#
.Description: Get-Creds
    Prompts user for Domain Credentials.
#>
function Set-PSSession {
    New-PSSession -ComputerName $Computer -Credential $Creds
} <#
.Description: Set-PSSession
    Sets variables for remote PS Session.
#>
function Disable-AutoLogon {
    Bump
    Write-Host "Disabling AutoLogon for $Computer" -ForegroundColor yellow
        Invoke-Command -Session $Session -ScriptBlock { Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon' -value '0'}
        Invoke-Command -Session $Session -ScriptBlock { Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'forceautologon' -value '0'} | Remove-PSSession -Session $Session
    Show-Result
} <#
.Description: Disable-AutoLogon
    Sets AutoAdminLogon and forceautologon key values to 0, effectively and quickly disabling autologon on the desired machine.
#>
function Enable-AutoLogon {
    Bump
    Write-Host "Re-enabling AutoLogon for $Computer" -ForegroundColor green
        Invoke-Command -Session $Session -ScriptBlock { Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon' -Value '1'} 
        Invoke-Command -Session $Session -ScriptBlock { Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'forceautologon' -Value '1'} | Remove-PSSession -Session $Session
    Show-Result
} <#
.Description: Enable-AutoLogon
    Sets AutoAdminLogon and forceautologon key vcalues to 1, re-enabling AutoLogon for the targeted computer.
#>
function Skip-EnableMessage {
    Bump
    Write-Host "You chose to not re-enable AutoLogon" -ForegroundColor Yellow
        Start-Sleep -Seconds 1.5
            Break
} <#
.Description: Skip-EnableMessage
    Sets message for skipping the Enable function.
#>
function Switch-EnableAutoLogon {
    Bump
    $title = "Re-enable AutoLogon Keys?"

    $message = "Do you want to re-enable the AutoLogon registry keys now? (Default is yes)"

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
        "Re-enables autologon keys"
    
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
        "Ends script"
    
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

    $result = $host.ui.PromptForChoice($title, $message, $options, 0) 
    switch ($result)
        {
            0 { Enable-AutoLogon }
            1 { Skip-EnableMessage }
        }
} <#
.Description: Switch-EnableAutoLogon
    Prompts user if they want to Enable AutoLogon at that moment.
#>
function Set-AutoADM {
    Invoke-Command -Computer $Computer {Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon' -ErrorAction SilentlyContinue}
} <#
.Description: Set-AutoADM
    Sets the AutoADM variable.
#>
function Set-ForceAuto {
    Invoke-Command -Computer $Computer {Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'forceautologon' -ErrorAction SilentlyContinue}
} <#
.Description: Set-ForceAuto
    Sets the ForceAuto variable.
#>
function Show-Result {
    $AutoADM = Set-AutoADM
    $ForceAuto = Set-ForceAuto
        Bump
        Write-Host "AutoAdminLogon value set to $AutoADM" -ForegroundColor Blue
        Write-Host "ForceAutoLogon value set to $ForceAuto" -ForegroundColor Blue
    Start-Sleep -Seconds 2

} <#
.Description: Show-Result
    Pulls AutoADM and ForceAuto variables and displays their current values to the user.
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