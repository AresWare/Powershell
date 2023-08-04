<#	
	NOTES
	 Created on:   	8/4/2023
	 Created by:   	Hunter Mancini
	DESCRIPTION
		This Powershell was created to automate adding AD users to a security group with folder permissions, then adding the folder shortcut to their network drive
#>
# Start transcript
Start-Transcript -Path C:\Temp\Add-ADUsers-Multi.log -Append

# Import AD Module
Import-Module ActiveDirectory


# Import the data from CSV file and assign it to variable
$List = Import-Csv "C:\testing.csv"

foreach ($User in $List) {
    # Retrieve UserSamAccountName and ADGroup
    $Groups = $User.Group
    $Group1 = "Group-Name"
    $Group2 = "Group-Name"
    $Group3 = "Group-Name"
    $Group4 = "Group-Name"
    $Group5 = "Group-Name"
    $Group6 = "Group-Name"
    $Folder1 = "\\UNC-TO-Folder" 
    $Folder2 = "\\UNC-TO-Folder"
    $Folder3 = "\\UNC-TO-Folder"
    $Folder4 = "\\UNC-TO-Folder"
    $Folder5 = "\\UNC-TO-Folder"
    $Folder6 = "\\UNC-TO-Folder"
    
    $DN = $User.DisplayName

    # Retrieve SamAccountName and ADGroup
    $ADUser = get-aduser -filter { displayName -like $DN } | select -expandproperty SamAccountName
    $ADGroups = Get-ADGroup -Filter * | Select-Object DistinguishedName, SamAccountName
    $UserFolder = "\\UNC\$ADUser"

    # User does not exist in AD
    if ($ADUser -eq $null) {
        Write-Host "$ADUser does not exist in AD" -ForegroundColor Red
        Continue
    }
    # User does not have a group specified in CSV file
    if ($Groups -eq $null) {
        Write-Host "$UserSam has no group specified in CSV file" -ForegroundColor Yellow
        Continue 
    }
    # Retrieve AD user group membership
    $ExistingGroups = Get-ADUser $ADUser -Properties MemberOf | Select-Object -ExpandProperty MemberOf | Get-ADGroup | Select-Object Name
        if ($ExistingGroups.Name -eq $50GrandGroup){
            Write-Host "Adding $Group1 to $ADUser" -ForeGroundColor Green
            Copy-Item $50Grand $UserFolder
            Copy-Item "Unc-To-Folder" "Unc-to-folder\$ADUser"
           
        }
        if ($ExistingGroups.Name -eq $374GrandGroup){
            Write-Host "Adding $Group2 to $ADUser" -ForeGroundColor Green
            Copy-Item "$374Grand" "$UserFolder"
            Copy-Item "Unc-To-Folder" "Unc-to-folder\$ADUser"
           
        }
        if ($ExistingGroups.Name -eq $150SargentGroup){
            Write-Host "Adding $Group3 to $ADUser" -ForeGroundColor Green
            Copy-Item $150Sargent $UserFolder
            Copy-Item "Unc-To-Folder" "Unc-to-folder\$ADUser"
            
        }
        if ($ExistingGroups.Name -eq $BellaVistaGroup){
            Write-Host "Adding $Group4 to $ADUser" -ForeGroundColor Green
            Copy-Item $BellaVista $UserFolder
            Copy-Item "Unc-To-Folder" "Unc-to-folder\$ADUser"
            
        }
        if ($ExistingGroups.Name -eq $DentalGroup){
            Write-Host "Adding $Group5 to $ADUser" -ForeGroundColor Green
            Copy-Item $Dental $UserFolder
            Copy-Item "Unc-To-Folder" "Unc-to-folder\$ADUser"
            
        }
        if ($ExistingGroups.Name -eq $ShorelineGroup){
            Write-Host "Adding $Group6 to $ADUser" -ForeGroundColor Green
            Copy-Item $Shoreline $UserFolder
            Copy-Item "Unc-To-Folder" "Unc-to-folder\$ADUser"
            
        }

    foreach ($Group in $Groups.Split(';')) {
        # Group does not exist in AD
        if ($ADGroups.SamAccountName -notcontains $Group) {
            Write-Host "$Group group does not exist in AD" -ForegroundColor Red
            Continue
        }

        # User already member of group
        if ($ExistingGroups.Name -eq $Group) {
            Write-Host "$DN already exists in group $Group" -ForeGroundColor Yellow
        } 
        else {
            # Add user to group
            Add-ADGroupMember -Identity $Group -Members $ADUser
            Write-Host "Added $UserSam to $Group" -ForeGroundColor Green
        }
    }

}
Stop-Transcript
