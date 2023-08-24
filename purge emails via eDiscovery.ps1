<#	
	NOTES
	 Created by:   	Hunter Mancini
	DESCRIPTION
		This Powershell was created to automate the purging of phishing/spam emails this will also add them to our Office 365 block list
#>
$searchName = Read-Host 'Enter the name of the search that you want to start'
$searchSubject = Read-Host 'Enter the content to match the query'
$purge = "_Purge"
$searchNamePurge = "$searchName" + $purge
Pause
New-ComplianceSearch -Name $searchName -ExchangeLocation all -ContentMatchQuery $searchSubject
Start-Sleep -Second 20
echo starting compliance search
echo please wait...
Start-ComplianceSearch -Identity $searchName

#Add email address to block list
Set-HostedContentFilterPolicy -Identity "Default" -BlockedSenders @{Add="$searchName"}

#Wait till search is done before proceeding

do {
    $SearchStatus = (Get-ComplianceSearch $searchName).status
    Start-Sleep 30
    }

    Until ($SearchStatus -eq "Completed")

Write-Host "Compliance Search ended." -ForegroundColor Green
Start-Sleep 5
Write-Host "Click Yes to All in the popup window!" -ForegroundColor Magenta
New-ComplianceSearchAction -SearchName $searchName -Purge -PurgeType HardDelete

#Wait till purge started before proceeding

do {

    $PurgeStatus = (Get-ComplianceSearchAction $searchNamePurge).status
    }

    Until ($PurgeStatus -eq "Starting")

    write-host "Hard Delete process started." -ForegroundColor DarkRed

#Wait till purge completed before proceeding

do {
    $PurgeStatus = (Get-ComplianceSearchAction $searchNamePurge).status
    }

    Until ($PurgeStatus -eq "Completed")
    write-host "Hard Delete process completed." -ForegroundColor Green

#Creates a table to show the amount purged and from what mailbox
echo Here is the summary:
Get-ComplianceSearchAction $searchNamePurge | Format-List Results
Pause
