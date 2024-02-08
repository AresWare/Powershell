<#	
	NOTES
	 Created on:   	2/7/2024
	 Created by:   	Hunter Mancini
	DESCRIPTION
		This script was created to change all O365 groups to private
#>
 #Grabs all O365 Groups
$Groups = get-unifiedgroup | Select-Object -ExpandProperty PrimarySmtpAddress
#Creates a loops to check groups for access type
Foreach ($Group in $Groups)
{
    #Grabs group email and checks it's access type
    Write-Host "Checking $Group for Access Type" -ForegroundColor White
    $AccessType = get-unifiedgroup -identity $Group | Select-Object -ExpandProperty AccessType

    If ($AccessType -match "Public")
    #Changes group to private if it's public
    {
    Write-Host "Changing $Group to Private" -ForegroundColor Red
    Set-UnifiedGroup -Identity $Group -AccessType Private

    }

    Else
    #Writes host the group is already private
    {
    Write-Host "Great! $Group is Private" -ForegroundColor Green
    }

}
