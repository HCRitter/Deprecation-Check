$AzureADUser = Get-AzureADUser -ObjectId $UserId
$AzureADUser | Select-Object -Property ObjectId, DisplayName, UserPrincipalName, AccountEnabled, Mail, Department, JobTitle


Get-AzureADApplicationOwner 
Get-ChildItem
New-MsolGroup -DisplayName "Test Group" -Description "This is a test group" -MailEnabled $false -SecurityEnabled $true