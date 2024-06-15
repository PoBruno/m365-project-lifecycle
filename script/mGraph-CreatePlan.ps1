##Parameters for the script to accept clientID, tenantID, clientSecret, CSVfilepath, PlanName and GroupID
param(
    [parameter(Mandatory = $true)]
    [String]
    $clientID,
    [parameter(Mandatory = $true)]
    [String]
    $tenantID,
    [parameter(Mandatory = $true)]
    [String]
    $clientSecret,
    [parameter(Mandatory = $true)]
    [String]
    $csvFilePath,
    [parameter(Mandatory = $true)]
    [String]
    $PlanName,
    [parameter(Mandatory = $true)]
    [String]
    $channelDisplayName,
    [parameter(Mandatory = $true)]
    [String]
    $channelDescription,
    [parameter(Mandatory = $true)]
    [String]
    $csvUsersPath,
    [parameter(Mandatory = $true)]
    [String]
    $GroupID,
    [parameter(Mandatory = $false)]
    [String]
    $StorageAccountName,
    [parameter(Mandatory = $false)]
    [String]
    $StorageContainerName,
    [parameter(Mandatory = $false)]
    [String]
    $TeamsChannelName
)
<#
Example for running locally:

.\graph-CreatePlanFromTemplate.ps1 `
    -clientID $clientID `
    -tenantID $tenantID `
    -clientSecret $clientSecret `
    -csvfilepath $csvfilepath `
    -PlanName $PlanName `
    -GroupID $groupID

$groupid = "000f7e60-e167-49a4-a973-27b80f6eb051"

#>

# If the storage account name is provided, download the CSV from the storage account
If ($StorageContainerName) {

    write-host "Storage Container Parameter detected, downloading CSV from storage account"
    Connect-AZAccount -Identity

    $context = New-AzStorageContext -StorageAccountName $storageaccountname

    Get-AzStorageBlobContent -Blob $CSVFilePath -Container $StorageContainerName -Context $context

    $csv = import-csv $csvFilePath

} else {
    ##Import the CSV
    Try {
        $csv = import-csv $csvFilePath -Delimiter ";"
    }
    catch {
        write-error "Could not import CSV, please check the path and try again. Error:`n $_"
        #exit
    }
}
##Connect to Microsoft Graph

try {
    $body = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        #Scope        = "https://graph.microsoft.com/Group.ReadWrite.All https://graph.microsoft.com/Calendars.ReadWrite https://graph.microsoft.com/Tasks.ReadWrite"
        Client_Id     = $clientID
        Client_Secret = $clientSecret
    }

    


    $TokenRequest = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $body

    #Token to security securestring
    $token = $TokenRequest.access_token | ConvertTo-SecureString -AsPlainText -Force

    Connect-MgGraph -AccessToken $token

} catch {
    write-error "Could not obtain a Microsoft Graph token. Error:`n $_"
    #exit
}

write-host "Provisioning Plan"
##Create the Plan
$params = @{
    container = @{
        url = "https://graph.microsoft.com/v1.0/groups/$($groupid)"
    }
    title = $planName
}

Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups/$groupid" -Headers @{Authorization = "Bearer $($TokenRequest.access_token)" }



try {
    $plan = New-MgPlannerPlan -BodyParameter $params
} catch {
    write-error "Could not create the plan. Error:`n $_"
    #exit
}

write-host "Provisioning Buckets"
##Loop through the unique buckets and provision the Buckets
[array]$Buckets = ($csv | Select-Object Bucket -Unique)
$orderhint = " !"
$BucketList = @()
$i = 0
foreach ($bucket in $Buckets) {
    $i++
    Write-Progress -Activity "Creating Buckets" -Status "Creating Bucket $i of $($Buckets.count)" -PercentComplete (($i / $Buckets.count) * 100)
    $params = @{
        name      = "$($bucket.Bucket)"
        planId    = "$($plan.id)"
        orderHint = "$($orderhint)"
    }
    
    $CreatedBucket = New-MgPlannerBucket -BodyParameter $params
    $BucketList += $CreatedBucket
    $orderhint = " $($createdBucket.orderhint)!"

}

write-host "Provisioning Tasks"
##Create Tasks in buckets
$i = 0
foreach ($Task in $csv) {
    $i++
    Write-Progress -Activity "Creating Tasks" -Status "Creating Task $i of $($csv.count)" -PercentComplete (($i / $csv.count) * 100)
    $CurrentBucket = $BucketList | Where-Object { $_.name -eq $Task.Bucket }

    try {
        
        $params = @{
            planId   = "$($Plan.id)"
            bucketId = "$($CurrentBucket.id)"
            title    = "$($Task.task)"
        }
        
        $CreatedTask = New-MgPlannerTask -BodyParameter $params
    }
    catch {
        write-error "Could not create task: $($task.task), Error:`n $_"
        #exit
    }

    $params = @{
        description = "$($Task.details)"
        previewType = "description"
    }
    ##Update Plan Details
    try {
        
        Update-MgPlannerTaskDetail -PlannerTaskId $CreatedTask.Id -BodyParameter $params -IfMatch (Get-MgPlannerTaskDetail -PlannerTaskId $CreatedTask.id).AdditionalProperties["@odata.etag"] 
    }
    catch {
        write-error "Could not update task details: $($task.task), Error:`n $_"
        #exit
    }
}

##Add Planner to Teams Channel 
if ($TeamsChannelName) {
    Try {
        $ChannelID = (Get-MgTeamChannel -TeamId $groupid | ?{$_.DisplayName -eq $TeamsChannelName}).id
        $params = @{
            name                  = $PlanName
            displayName           = $PlanName
            "teamsapp@odata.bind" = "https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/com.microsoft.teamspace.tab.planner"
            configuration         = @{
                contentUrl = "https://tasks.teams.microsoft.com/teamsui/{tid}/Home/PlannerFrame?page=7&auth_pvr=OrgId&auth_upn={userPrincipalName}&groupId={groupId}&planId=$($plan.id)&channelId={channelId}&entityId={entityId}&tid={tid}&userObjectId={userObjectId}&subEntityId={subEntityId}&sessionId={sessionId}&theme={theme}&mkt={locale}&ringId={ringId}&PlannerRouteHint={tid}"
                removeUrl = "https://tasks.teams.microsoft.com/teamsui/{tid}/Home/PlannerFrame?page=13&auth_pvr=OrgId&auth_upn={userPrincipalName}&groupId={groupId}&planId=$($plan.id)&channelId={channelId}&entityId={entityId}&tid={tid}&userObjectId={userObjectId}&subEntityId={subEntityId}&sessionId={sessionId}&theme={theme}&mkt={locale}&ringId={ringId}&PlannerRouteHint={tid}"
                websiteUrl = "https://tasks.office.com/{tid}/Home/PlanViews/$($Plan.id)?Type=PlanLink&Channel=TeamsTab"        
            }
        
        }    
        $CreatedTab = New-MgTeamChannelTab -TeamId $groupid -ChannelId $ChannelID -BodyParameter $params
    }
    catch {
        write-error "Could not create tab for task: $($task.task), Error:`n $_"
        #exit
    }
}

<#

.\graph-CreatePlanFromTemplate.ps1 -clientID $clientID -tenantID $tenantID -clientSecret $clientSecret -csvfilepath $csvfilepath -PlanName $PlanName -GroupID $groupID


#>


# Caminho para o arquivo CSV
$csvUsersPath = "H:\Repository\AdminSeanMc\Graph Scripts\graph-CreatePlanFromTemplate\PlanUsers.csv"

# Função para criar um membro a partir de um endereço de e-mail
function New-Member($email) {
    return @{
        "@odata.type"     = "#microsoft.graph.aadUserConversationMember"
        "user@odata.bind" = "https://graph.microsoft.com/v1.0/users('{0}')" -f (Get-MgUser -UserPrincipalName $email).Id
        roles             = @("owner")
    }
}

# Lê o CSV e cria a lista de membros
$members = @()
Import-Csv -Path $csvUsersPath | ForEach-Object {
    $members += New-Member $_.Email
}

# Parâmetros do canal
$params = @{
    "@odata.type"  = "#Microsoft.Graph.channel"
    membershipType = "private"
    displayName    = $channelDisplayName
    description    = $channelDescription
    members        = $members
}

# Cria o canal
New-MgTeamChannel -TeamId $groupid -BodyParameter $params










