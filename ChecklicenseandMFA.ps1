#Variable counters
$UsersnotfoundinOffice365 = 0
$Userswithalicense = 0
$Userswithoutalicense = 0
$UsersChecked = 0
$UserswithMFA = 0
$UsersnotfoundinAzureAD = 0
$UserswithoutMFA = 0
 
 
#CSV with the users
$Users = "C:users.csv"
Write-Host "Connecting to Office 365..." -ForegroundColor Yellow
#Connect to Office 365
#Connect-MsolService
#Connect-AzureAD 
 
Import-Csv $Users | Foreach-Object{
$Name = $_.Name

    $license ="thelazyadmin:STANDARDPACK" #E1 = STANDARDPACK, E2 = STANDARDWOFFPACK
	
	#Display a status to the shell on what user it's working on
	Write-Host "Working on $Name" -ForegroundColor Yellow
    $UsersChecked++
	
	
	#Find the user from the CSV and match them with an Office 365 user
	$LicensedUsers = Get-MsolUser -UserPrincipalName $_.UserPrincipalName | select-object -expandproperty UserPrincipalName
	If (!($LicensedUsers))
	{
		Write-Host "Could not find a matched user in Office 365 for $Name" -ForegroundColor Red
		$UsersnotfoundinOffice365++
	}
	Else
	{
		Write-Host "Matched $Name with $LicensedUsers" -ForegroundColor White
		
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
                set-msoluserlicense -userPrincipalName $_.userPrincipalName -AddLicenses $license
			}
			
		}
	}
      #Begins checking which MFA group users are apart of  
	  $MFAUsers = Get-AzureADUser -ObjectId $_.userPrincipalName | Select-Object -ExpandProperty objectid
        If (!($MFAUsers))
        #
        {
            Write-Host "Could not find Azure User for $Name" -ForegroundColor Red
            $UsernotfoundinAzureAD++
        
        }
        Else 
        {
            Write-Host "Matched $Name with $MFAUsers" -ForegroundColor White
            Foreach ($MFAUser in $MFAUsers)
        {
        #Checks user for Non FOB MFA group if true it'll display 
                Write-Host "Checking MFA group for $Name..." -ForegroundColor White
                $MFAStatus = (Get-AzureADUserMembership -ObjectID $MFAUser | Select DisplayName)
    
                If  ($MFAStatus -match "MFA_Group_Non_FOB")
                
                {
    
                    Write-Host "$Name is a non fob user" -ForegroundColor Cyan
                    $UserswithMFA++
                }
            Elseif ($MFAStatus -match "MFA_FOB") 
            {
                Write-Host "$Name is a FOB user" -ForegroundColor DarkCyan
                $UserswithMFA++
            }
            Else 
            {
                Write-Host "$Name is not in MFA!" -ForegroundColor Red
                $UserswithoutMFA++
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
Write-Host "USERS NOT FOUND IN AZURE: $UsersnotfoundinAzureAD" -ForegroundColor Black -BackgroundColor White
Write-Host "USERS WITH MFA: $UserswithMFA" -ForegroundColor Black -BackgroundColor White
Write-Host "USERS WITHOUT MFA: $UserswithoutMFA" -ForegroundColor Black -BackgroundColor White
Write-Host "-------------------------------------------------------------" -ForegroundColor White
