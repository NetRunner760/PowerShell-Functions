# Get-InstalledSoftwares
# Fast effective function that gets all installed softwares from local or remote computer. Call function alone for local or call it and specify a Remote Computer.
# EXAMPLE: Get-InstalledSoftware TestComputer123 (lists software for remote computer TestComputer123). Get-InstalledSoftware (lists for your local PC).
# Modify displayed properties via $props per your needs.
# Written by The PoSH Wolf

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
        $props = 'ComputerName','Name','Installdate','Publisher','Version','UninstallCommand','RegPath'
        $masterKeys = ($masterKeys | Where-Object $woFilter | Select-Object $props | Sort-Object Name)
        $masterKeys
    }
    End{}
}