#Variable counters
$UsersnotfoundinOffice365 = 0
$Userswithalicense = 0
$Userswithoutalicense = 0
$UsersChecked = 0
$UsernotfoundinAzureAD = 0

 
 
#CSV with the users
$CSVCheck = "C:\8-1-23.csv"
#Get credential to log into Office 365
$UserCredential = Get-Credential
Write-Host "Connecting to Office 365..." -ForegroundColor Yellow
#Connect to Office 365
Connect-MsolService -Credential $UserCredential
Connect-Azuread -Credential $UserCredential
 
Import-Csv $CSVCheck | Foreach-Object{
	#CSV headers to variables to work with
	$Users = $_.Name
	
	#Display a status to the shell on what user its working on
	Write-Host "Working on $Users" -ForegroundColor Yellow
    $UsersChecked++
	
	
	#Find the user from the CSV and match them with an Office 365 user
	$LicensedUsers = (Get-MsolUser | Where-Object { $_.DisplayName -like "*$Users*" }).UserPrincipalName
	If (!($LicensedUsers))
	{
		Write-Host "Could not find a matched user in Office 365 for $Users" -ForegroundColor Red
		$UsersnotfoundinOffice365++
	}
	Else
	{
		Write-Host "Matched $Users with $LicensedUsers" -ForegroundColor White
		
		Foreach ($LicensedUser in $LicensedUsers)
		{
			Write-Host "Checking license for $LicensedUser..." -ForegroundColor White
            #Get the users isLiscensed attribute value
			$LicenseStatus = (Get-MsolUser -UserPrincipalName $LicensedUser).isLicensed
			
			If ($LicenseStatus -eq "True")
			{
				Write-Host "$LicensedUser is Licensed!" -ForegroundColor Green
				$Userswithalicense++
			}
			Else
			{
				Write-Host "$LicensedUser is not Licensed!" -ForegroundColor Red
				$Userswithoutalicense++
			}
			
		}
	}
    
    $MFAUsers = (Get-AzureADUser -ObjectId $User.userPrincipalName)
    If (!($MFAUsers))
    {
        Write-Host "Could not find Azure User for $User" -ForegroundColor Red
        $UsernotfoundinAzureAD++
    
    }

    else

    {
        Write-Host "Matched $User with $MFAUsers" -ForegroundColor White
        Foreach ($MFAUsers in $MFAUsers)
        {
            Write-Host "Checking MFA group for $User..." -ForegroundColor White
            $MFAStatus = Get-AzureADUserMembership -ObjectID $MFAUser.ObjectID | Select DisplayName

            If ( ($MFAStatus -eq "MFA_Group_Non_Fob") or ($MFAStatus -eq "MFA_FOB") )			
			{
                Write-Host "$User is a non fob user" -ForegroundColor Green
				$UserwithMFA++
        }
        else {
            Write-Host "$User is not in MFA!" -ForegroundColor Red
        }

        }
    }
	
	
}
#End script stats
Write-Host "--------------------------STATS------------------------------" -ForegroundColor White
Write-Host "TOTAL USERS CHECKED: $UsersChecked" -ForegroundColor Black -BackgroundColor White
Write-Host "USERS NOT FOUND IN OFFICE 365: $UsersnotfoundinOffice365" -ForegroundColor Black -BackgroundColor White
Write-Host "USERS NOT LICENSED: $Userswithoutalicense" -ForegroundColor Black -BackgroundColor White
Write-Host "USERS WITH A  LICENSE: $Userswithalicense" -ForegroundColor Black -BackgroundColor White
Write-Host "USERS NOT FOUND IN AZURE: $UsernotfoundinAzureAD" -ForegroundColor Black -BackgroundColor White
Write-Host "USERS WITH MFA: $UserwithMFA" -ForegroundColor Black -BackgroundColor White
Write-Host "-------------------------------------------------------------" -ForegroundColor White
