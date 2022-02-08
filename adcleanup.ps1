# Save Users in csv here: "C:\Scripts\ADCleanup\StaffUsers.csv" 
# Content of CSV should be the users email address.

# Import Modules
import-module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms

# Assign variables
$AADServer = "Your Azure AD Sync Server"
$Username = "AAD Admin"
$Pass = Get-Content "C:\Scripts\Password.txt" | ConvertTo-SecureString 
$Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Pass

# Import CSV
$users = Import-Csv -Path "C:\Scripts\ADCleanup\Users.csv" 

# Prompt User for which AD property to change
# Create Menu
function Show-Menu
{
    param (
        [string]$Title = 'UCFB Active Directory Properties Script'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "Once selected, this script will run against ALL users in the StaffUsers.csv located in the folder where this script is executed"
    Write-Host '1: Press "1" to change these users "Office".'
    Write-Host '2: Press "2" to change these users "Department".'
    Write-Host '3: Press "3" to change these users "Manager".'
    Write-Host 'Q: Press "Q" to quit.'
}

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    
    # Option 1 - Change Office
    '1' {
        Write-Host 'Please choose office location'
        Write-Host 'Press "1" to set the users location as "Location 1"'
        Write-Host 'Press "2" to set the users location as "Location 2"'
        Write-Host 'Press "3" to set the users location as "Location 3"'
        
        do {
            Show-Menu
            $selection = Read-Host "Please make a selection"
            switch ($selection) {
                '1' {
                    foreach ($user in $users)  {
                        $sam = ($user.userprincipalname.Split(“@”)[0])
                        write-host "Changing Office to Location 1 for, $sam"
                        Set-ADuser $sam -Office 'Location 1'
                    }
                } '2' {
                    foreach ($user in $users)  {
                        $sam = ($user.userprincipalname.Split(“@”)[0])
                        write-host "Changing Office to Location 2 for, $sam"
                        Set-ADuser $sam -Office 'Location 2'
                    }
                } '3' {
                    foreach ($user in $users)  {
                        $sam = ($user.userprincipalname.Split(“@”)[0])
                        Set-ADuser $sam -Office 'Location 3'
                        write-host "Changing Office to Location 3 for, $sam"
                    }
            }
        }
     pause
    }
    # Option 2 - Change Department
    '2' {
        Write-Host 'Please choose a department'
        Write-Host 'Press "1" to set the users location as "Finance"'
        Write-Host 'Press "2" to set the users location as "Marketing"'
        Write-Host 'Press "3" to set the users location as "HR"'
        do {
            Show-Menu
            $selection = Read-Host "Please make a selection"
            switch ($selection) {
                '1' {
                    foreach ($user in $users)  {
                        $sam = ($user.userprincipalname.Split(“@”)[0])
                        Write-Host 
                        Set-ADuser $sam -Department 'Finance'
                        Add-ADGroupMember -Identity "SG-Finance" -Members $sam
                    }
                '2' {
                    foreach ($user in $users)  {
                        $sam = ($user.userprincipalname.Split(“@”)[0])
                        Set-ADuser $sam -Department 'Marketing'
                        Add-ADGroupMember -Identity "SG-Marketing" -Members $sam
                    }
                 '3' {
                    foreach ($user in $users)  {
                        $sam = ($user.userprincipalname.Split(“@”)[0])
                        Set-ADuser $sam -Department 'HR'
                        Add-ADGroupMember -Identity "SG-HR" -Members $sam
                    }
    # Option 3 - Change Manager
    '3' {
      foreach ($user in $users)  {
        $sam = ($user.userprincipalname.Split(“@”)[0])
        $manager = Read-Host -prompt 'Please enter managers name in the format: "FirstInitial.Surname"'
        Set-ADuser $sam -Manager $manager
    }
    pause
 }    
 until ($selection -eq 'q')
}

# Run this command before executing script:
# Connect-MsolService 

write-host "Syncing change to Azure."

Invoke-Command -ComputerName $AADServer -ScriptBlock { Start-ADSyncSyncCycle -PolicyType Delta }

write-host "Sync Complete"
write-host "Changes Complete"
