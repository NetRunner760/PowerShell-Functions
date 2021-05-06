# Disable/Re-enable AD User
# Juan Parra
# 01/22/2021

$User = Read-Host -Prompt 'Target User'

#Disables User AD Account and queries for verif
Write-Host "Disabling AD account for $User"
Disable-ADAccount -Identity $User
Get-ADUser $User | Select-Object Name, Enabled

#Re-enables User AD account and queries for verif
Write-Host "Re-enabling AD Account for $User"
Enable-ADAccount -Identity $User
Get-ADUser $User | Select-Object Name, Enabled
