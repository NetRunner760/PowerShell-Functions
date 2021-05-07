# Remote-Uninstall_MSTR
# Juan Parra
# 04/20/2021
#---------------------------------------------------------------------#
<#
.DESCRIPTION
Master Functions file for: Remote-Uninstall script.

.NOTES
    Version 1.0: ------- 04/20/21
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
    $Title = 'Remote-Uninstall'
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
function Show-Info {
    Bump
    Write-Host "Generating programs list for $Computer"
        Start-Sleep -Seconds 1
    Test-Computer
    Write-Host "If you would like to uninstall a program from the generated list, simply select it and click ok to proceed."
    
} <#
.Description
    Informs user how to fill the $App variable.
#>
function Get-InstalledSoftware {
    Param(
        [Alias('Computer','ComputerName','HostName')]
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$true,Mandatory=$false,Position=1)]
        [string[]]$Name = $env:COMPUTERNAME
    )
    Begin{
        $lmKeys = "Software\Microsoft\Windows\CurrentVersion\Uninstall","SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
        $lmReg = [Microsoft.Win32.RegistryHive]::LocalMachine
        $cuKeys = "Software\Microsoft\Windows\CurrentVersion\Uninstall"
        $cuReg = [Microsoft.Win32.RegistryHive]::CurrentUser
    }
    Process{
        if (!(Test-Connection -ComputerName $Name -count 1 -quiet)) {
            Write-Error -Message "Unable to contact $Name. Please verify its network connectivity and try again." -Category ObjectNotFound -TargetObject $Computer
            Break
        }
        $masterKeys = @()
        $remoteCURegKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($cuReg,$Name)
        $remoteLMRegKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($lmReg,$Name)
        foreach ($key in $lmKeys) {
            $regKey = $remoteLMRegKey.OpenSubkey($key)
            foreach ($subName in $regKey.GetSubkeyNames()) {
                foreach($sub in $regKey.OpenSubkey($subName)) {
                    $masterKeys += (New-Object PSObject -Property @{
                        "ComputerName" = $Name
                        "Name" = $sub.GetValue("displayname")
                        "SystemComponent" = $sub.GetValue("systemcomponent")
                        "ParentKeyName" = $sub.GetValue("parentkeyname")
                        "Version" = $sub.GetValue("DisplayVersion")
                        "Publisher" = $sub.GetValue("Publisher")
                        "UninstallCommand" = $sub.GetValue("UninstallString")
                        "InstallDate" = $sub.GetValue("InstallDate")
                        "RegPath" = $sub.ToString()
                    })
                }
            }
        }
        foreach ($key in $cuKeys) {
            $regKey = $remoteCURegKey.OpenSubkey($key)
            if ($regKey -ne $null) {
                foreach ($subName in $regKey.getsubkeynames()) {
                    foreach ($sub in $regKey.opensubkey($subName)) {
                        $masterKeys += (New-Object PSObject -Property @{
                            "ComputerName" = $Computer
                            "Name" = $sub.GetValue("displayname")
                            "SystemComponent" = $sub.GetValue("systemcomponent")
                            "ParentKeyName" = $sub.GetValue("parentkeyname")
                            "Version" = $sub.GetValue("DisplayVersion")
                            "Publisher" = $sub.GetValue("Publisher")
                            "UninstallCommand" = $sub.GetValue("UninstallString")
                            "InstallDate" = $sub.GetValue("InstallDate")
                            "RegPath" = $sub.ToString()
                        })
                    }
                }
            }
        }
        $woFilter = {$null -ne $_.name -AND $_.SystemComponent -ne "1" -AND $null -eq $_.ParentKeyName}
        $props = 'ComputerName','Name','Installdate','Publisher','Version','RegPath','UninstallCommand'
        $masterKeys = ($masterKeys | Where-Object $woFilter | Select-Object $props | Sort-Object Name)
        $masterKeys
    }
    End{}
} <#
.Description
    Searches registry for installed programs.
#>
function Set-App{
    Get-InstalledSoftware $Computer| Out-GridView -Title "$Computer : Installed Programs. Select a program and press Ok to uninstall." -PassThru| Select-Object -ExpandProperty Name
} <#
.Description
    Calls Get-InstallSoftware function and formats output into a GUI list. The selection can be passed into a variable.
#>
function Request-Uninstall {
    Bump
$title = "Uninstall Prompt."
$message = "Continue to the uninstall function?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    " Continues to uninstall program from $Computer prompt. "

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    " Exits script "

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 1) 
    Bump
switch ($result)
    {
        0 { Confirm-Uninstall }
        1 { Write-Host "You selected to skip the uninstall function, exiting." }
    }
} <#
.Description
    Prompts user if they want to continue the script into the Uninstall function.
#>
function Confirm-Uninstall {
    Write-Host "You selected $App ."
    Start-Sleep -Seconds 1
        Bump
$title = "Confirm Uninstall"
$message = "Are you sure you want to uninstall $App ?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Uninstalls $App"

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Cancels Uninstall"

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

$result = $host.ui.PromptForChoice($title, $message, $options, 1) 
    Bump
switch ($result)
    {
        0 { Start-Uninstall }
        1 { [void] [System.Windows.MessageBox]::Show( "$App uninstall was cancelled.", "Action Cancelled", "OK", "Information" )
            Write-Host "$App uninstall was cancelled." }
    }
} <#
.Description
    Displays the selected program name and prompts to confirm the user wants to continue the uninstall.
#>
function Start-Uninstall {
    Write-Host "Uninstalling $App"
    Start-Sleep -Seconds 4
        Get-CimInstance -ClassName Win32_Product -ComputerName $Computer | Where-Object {$_.Name -eq $App} | Remove-CimInstance

        if($?) {
            [void] [System.Windows.MessageBox]::Show( "$App was successfully uninstalled.", "Action Completed", "OK", "Information" )
            "$App was successfully uninstalled"
                Start-Sleep -Seconds 1
            Bump
                }
        if (!$?) {
            [void] [System.Windows.MessageBox]::Show( "$App uninstall failed.", "Action Failed", "OK", "Information" )
            "$App uninstallation failed"
                Start-Sleep -Seconds 1
            Bump
               exit
                }
} <#
.Description
    Starts the uninstall function on the selected program.
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