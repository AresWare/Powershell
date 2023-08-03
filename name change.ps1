<#	
	NOTES
	 Created by:   	Hunter Mancini
     Created on: 8/2/2023
	DESCRIPTION
		This Powershell was created to automate legal name changes
#>

$OldFirstName =  Read-Host 'Enter the current FIRST name of the user'
#Extracts the first letter from above input
$OldFirstLetter = $OldFirstName.Substring(0,1)
$OldLastName = Read-Host 'Enter the current LAST name of the user'
#Creates the old SAM name based on the variables above then makes it lowercase
$OldSamName = "$OldFirstLetter.$OldLastName".ToLower()
$OldEmailAccount = "$OldSamAccount+@domain.org".ToLower()
$Oldsmtp = "smtp:$OldEmailAccount"
$NewFirstName = Read-Host 'Enter the NEW FIRST name of the user'
#Extracts the first letter from above input
$NewFirstLetter = $NewFirstName.Substring(0,1)
$NewLastName = Read-Host 'Enter the NEW LAST name of the user'
#Creates the new SAM name based on the variables above then makes it lowercase
$NewSamAccount = "$NewFirstLetter.$NewLastName".ToLower()
$NewEmailAccount = "$NewSamAccount+@domain.org".ToLower()
$NewSMTP = "SMTP:$NewEmailAccount"
$NewSIP = "SIP:$NewEmailAccount"

#Process users.
ForEach-Object {

    #Change display name, and company name
    set-aduser -Identity $OldSamName -Displayname "$($NewFirstName) $($NewLastName)"
    #Change distinguished name
        Try {
            Write-Host "Updating login to $NewSamAccount"
            Rename-ADObject -identity $OldSamName -Newname $NewSamName
        }
        Catch {
            Write-Host "$NewSamName may already exist."
        }
    Set-AdUser -Identity $NewSamName -Replace @{proxyAddresses=$Oldsmtp,$NewSMTP,$NewSIP -split ","}
    }


  
