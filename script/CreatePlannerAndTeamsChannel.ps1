<#
.SYNOPSIS
    Script to automate the creation of a Microsoft Planner plan, including buckets and tasks from a CSV file, and configuring a Planner tab in a Microsoft Teams channel.

.DESCRIPTION
    This script leverages Microsoft Graph API to create a plan in Microsoft Planner, add buckets and tasks based on a CSV file, and configure a Planner tab in a Microsoft Teams channel.

.PARAMETER clientID
    Specifies the client ID for Azure AD authentication.

.PARAMETER tenantID
    Specifies the tenant ID for Azure AD authentication.

.PARAMETER clientSecret
    Specifies the client secret for Azure AD authentication.

.PARAMETER GroupID
    Specifies the Microsoft Teams group ID where the plan will be created.

.PARAMETER PlanName
    Specifies the name of the plan to be created in Microsoft Planner.

.PARAMETER csvFilePath
    Specifies the file path to the CSV file containing task information.

.PARAMETER teamsTabName
    Specifies the name of the Planner tab to be created in the Microsoft Teams channel. Default is "Planner".

.PARAMETER channelDisplayName
    Specifies the display name of the Microsoft Teams channel to be created. If not provided, defaults to PlanName.

.PARAMETER channelDescription
    Specifies the description of the Microsoft Teams channel to be created. If not provided, defaults to a standard description.

.NOTES
    Author: Bruno Gomes
    GitHub: https://github.com/pobruno/m365-project-lifecycle
    LinkedIn: https://www.linkedin.com/in/brunopoleza/
    Date: 16/06/2024

.EXAMPLE

    # Example 1

    .\CreatePlannerAndTeamsChannel.ps1 -clientID "your-client-id" -tenantID "your-tenant-id" -clientSecret "your-client-secret" -GroupID "your-group-id" -PlanName "My Plan" -csvFilePath "path\to\tasks.csv"
    This command creates a plan named "My Plan" in Planner, adds buckets and tasks from a CSV file, and configures a Planner tab in a Microsoft Teams channel.


    # Example 2
    
    $clientID = "your-client-id"
    $tenantID = "your-tenant-id"
    $clientSecret = "your-client-secret"
    $GroupID = "your-group-id"
    $PlanName = "My Plan"
    $csvFilePath = "path\to\tasks.csv"
    $teamsTabName = "Planner"
    $channelDisplayName = "My Channel"
    $channelDescription = "Channel for managing tasks in Planner - My Plan"

    .\CreatePlannerAndTeamsChannel.ps1 -clientID $clientID -tenantID $tenantID -clientSecret $clientSecret -GroupID $GroupID -PlanName $PlanName -csvFilePath $csvFilePath -teamsTabName $teamsTabName -channelDisplayName $channelDisplayName -channelDescription $channelDescription

#>


[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String] $clientID,

    [Parameter(Mandatory=$true)]
    [String] $tenantID,

    [Parameter(Mandatory=$true)]
    [String] $clientSecret,

    [Parameter(Mandatory=$true)]
    [String] $GroupID,

    [Parameter(Mandatory=$true)]
    [String] $PlanName,

    [Parameter(Mandatory=$true)]
    [String] $csvFilePath,

    [Parameter(Mandatory=$false)]
    [String] $teamsTabName = "Planner",

    [Parameter(Mandatory=$false)]
    [String] $channelDisplayName,

    [Parameter(Mandatory=$false)]
    [String] $channelDescription
)

# Definir valores padrão para parâmetros opcionais, se não fornecidos
if (-not $channelDisplayName) {
    $channelDisplayName = $PlanName
}

if (-not $channelDescription) {
    $channelDescription = "Canal para gerenciamento de tarefas do Planner - $PlanName"
}

###################################################################################
#                     M G R A P H   A C C E S S   T O K E N                       #
###################################################################################

# Função para obter o token de acesso
function Get-AccessToken {
    param (
        [String] $clientID,
        [String] $tenantID,
        [String] $clientSecret
    )

    $body = @{
        client_id     = $clientID
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }

    try {
        $response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $body -ContentType "application/x-www-form-urlencoded"
        return $response.access_token
    } catch {
        Write-Error "Não foi possível obter o token de acesso. Erro:`n $_"
        return $null
    }
}

# Obter o token de acesso
$accessToken = Get-AccessToken -clientID $clientID -tenantID $tenantID -clientSecret $clientSecret

if (-not $accessToken) {
    Write-Error "Falha ao obter o token de acesso. Verifique suas credenciais e tente novamente.`n$_"
    exit
}


###################################################################################
#                               P L A N N E R                                     #
###################################################################################

# Função para criar o plano
function Create-Plan {
    param (
        [String] $accessToken,
        [String] $groupID,
        [String] $planName
    )

    $uri = "https://graph.microsoft.com/v1.0/planner/plans"
    $body = @{
        owner = $groupID
        title = $planName
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Method POST -Body ($body | ConvertTo-Json) -Headers @{Authorization = "Bearer $accessToken"; "Content-Type" = "application/json"}
        return $response
    } catch {
        Write-Error "Erro ao criar o plano:`n $_"
        return $null
    }
}

# Função para criar um bucket
function Create-Bucket {
    param (
        [String] $accessToken,
        [String] $planID,
        [String] $bucketName,
        [String] $orderHint
    )

    $uri = "https://graph.microsoft.com/v1.0/planner/buckets"
    $body = @{
        name      = $bucketName
        planId    = $planID
        orderHint = $orderHint
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Method POST -Body ($body | ConvertTo-Json) -Headers @{Authorization = "Bearer $accessToken"; "Content-Type" = "application/json"}
        return $response
    } catch {
        Write-Error "Erro ao criar o bucket:`n $_"
        return $null
    }
}

# Função para criar uma tarefa
function Create-Task {
    param (
        [String] $accessToken,
        [String] $planID,
        [String] $bucketID,
        [String] $taskTitle
    )

    $uri = "https://graph.microsoft.com/v1.0/planner/tasks"
    $body = @{
        planId   = $planID
        bucketId = $bucketID
        title    = $taskTitle
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Method POST -Body ($body | ConvertTo-Json) -Headers @{Authorization = "Bearer $accessToken"; "Content-Type" = "application/json"}
        return $response
    } catch {
        Write-Error "Erro ao criar a tarefa:`n $_"
        return $null
    }
}

# Função para atualizar detalhes da tarefa
function Update-TaskDetail {
    param (
        [String] $accessToken,
        [String] $taskID,
        [String] $description
    )

    $uri = "https://graph.microsoft.com/v1.0/planner/tasks/$taskID/details"
    $body = @{
        description = $description
        previewType = "description"
    }

    try {
        $taskDetails = Invoke-RestMethod -Uri $uri -Method GET -Headers @{Authorization = "Bearer $accessToken"; "Content-Type" = "application/json"}
        $etag = $taskDetails.'@odata.etag'

        $response = Invoke-RestMethod -Uri $uri -Method PATCH -Body ($body | ConvertTo-Json) -Headers @{Authorization = "Bearer $accessToken"; "Content-Type" = "application/json"; "If-Match" = $etag}
        return $response
    } catch {
        Write-Error "Erro ao atualizar os detalhes da tarefa:`n $_"
        return $null
    }
}


###################################################################################
#                                 T E A M S                                       #
###################################################################################

# Função para criar um novo canal em um time do Microsoft Teams
function Create-TeamChannel {
    param (
        [String] $accessToken,
        [String] $teamId,
        [String] $channelDisplayName,
        [String] $channelDescription
    )

    $uri = "https://graph.microsoft.com/v1.0/teams/$teamId/channels"
    $params = @{
        displayName = $channelDisplayName
        description = $channelDescription
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Method POST -Headers @{Authorization = "Bearer $accessToken"; "Content-Type" = "application/json"} -Body ($params | ConvertTo-Json -Depth 10)
        return $response
    } catch {
        Write-Host "Erro ao criar o canal: `n$_" -ForegroundColor Red
        return $null
    }
}

# Função para obter o nome de exibição de um time do Microsoft Teams
function Get-TeamDisplayName {
    param (
        [String] $accessToken,
        [String] $teamId
    )

    $uri = "https://graph.microsoft.com/v1.0/teams/$teamId"

    try {
        $teamData = Invoke-RestMethod -Uri $uri -Method GET -Headers @{Authorization = "Bearer $accessToken"; "Content-Type" = "application/json"}
        return $teamData.displayName
    } catch {
        Write-Host "Erro ao buscar o nome de exibição do time: `n$_" -ForegroundColor Red
        return $null
    }
}

# Função para adicionar o Planner como uma aba no canal do Teams
function Add-PlannerTabToChannel {
    param (
        [String] $accessToken,
        [String] $groupID,
        [String] $channelID,
        [String] $planID,
        [String] $teamsTabName
    )

    $uri = "https://graph.microsoft.com/v1.0/teams/$groupID/channels/$channelID/tabs"
    $body = @{
        "displayName" = $teamsTabName
        "teamsApp@odata.bind" = "https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/com.microsoft.teamspace.tab.planner"
        "configuration" = @{
            "entityId" = $planID
            "contentUrl" = "https://tasks.office.com/$tenantID/Home/PlannerFrame?page=7&planId=$planID&auth_pvr=OrgId&auth_upn={upn}&mkt={locale}"
            "removeUrl" = "https://tasks.office.com/$tenantID/Home/PlannerFrame?page=7&planId=$planID&auth_pvr=OrgId&auth_upn={upn}&mkt={locale}"
            "websiteUrl" = "https://tasks.office.com/$tenantID/Home/PlannerFrame?page=7&planId=$planID&auth_pvr=OrgId&auth_upn={upn}&mkt={locale}"
        }
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Method POST -Body ($body | ConvertTo-Json -Depth 4) -Headers @{Authorization = "Bearer $accessToken"; "Content-Type" = "application/json"}
        return $response
    } catch {
        Write-Error "Erro ao adicionar a aba do Planner no canal:`n $_"
        return $null
    }
}


####################################################################################
####################################################################################

# Importar o arquivo CSV
if (Test-Path $csvFilePath) {
    $csv = Import-Csv $csvFilePath
} else {
    Write-Error "Arquivo CSV não encontrado. Verifique o caminho e tente novamente."
    exit
}

# Teams Criar um novo canal
Write-Host -ForegroundColor Yellow "Provisionando Canal..."

# Obter o nome do time
$teamDisplayName = Get-TeamDisplayName -accessToken $accessToken -teamId $groupID

if ($teamDisplayName) {
    # Criar um novo canal
    $TeamChannel = Create-TeamChannel -accessToken $accessToken -teamId $groupID -channelDisplayName $channelDisplayName -channelDescription $channelDescription

    if ($response) {
        Write-Host "Canal criado com sucesso." -ForegroundColor Green
        Write-Host "`n`t- Time  : $teamDisplayName`n`t- Canal : $channelDisplayName`n" -ForegroundColor Yellow
    } else {
        Write-Host "Não foi possível criar o Canal." -ForegroundColor Red
    }
} else {
    Write-Host "Não foi possível encontrar o Time." -ForegroundColor Red
}


# Criar o plano
Write-Host -ForegroundColor Yellow "Provisionando Plano..."
$plan = Create-Plan -accessToken $accessToken -groupID $GroupID -planName $PlanName

if (-not $plan) {
    Write-Error "Falha ao criar o plano. Verifique se o grupo existe e tente novamente.`n $_"
    exit
}

Write-Host -ForegroundColor Green "Plano criado com sucesso."

# Criar os buckets
Write-Host -ForegroundColor Yellow "Provisionando Buckets..."
$Buckets = $csv | Select-Object -ExpandProperty Bucket -Unique
$BucketList = @()
$orderHint = " !"

foreach ($bucket in $Buckets) {
    Write-Progress -Activity "Criando Buckets" -Status "Criando Bucket '$bucket'" -PercentComplete ((($Buckets.IndexOf($bucket) + 1) / $Buckets.count) * 100)

    $CreatedBucket = Create-Bucket -accessToken $accessToken -planID $plan.id -bucketName $bucket -orderHint $orderHint

    if ($CreatedBucket) {
        $BucketList += $CreatedBucket
        $orderHint = " $($CreatedBucket.orderHint)!"  # Atualiza o orderHint para o próximo bucket
    } else {
        Write-Error "Não foi possível criar o bucket: '$bucket'.`n $_"
        exit
    }
}

Write-Host -ForegroundColor Green "Todos os buckets foram criados com sucesso."

# Criar as tarefas
Write-Host -ForegroundColor Yellow "Provisionando Tarefas..."
$i = 0
foreach ($Task in $csv) {
    $i++
    $PercentComplete = (($i / $csv.count) * 100)
    Write-Progress -Activity "Criando Tarefas" -Status "Criando Tarefa $i de $($csv.count)" -PercentComplete $PercentComplete
    $CurrentBucket = $BucketList | Where-Object { $_.name -eq $Task.Bucket }

    $CreatedTask = Create-Task -accessToken $accessToken -planID $plan.id -bucketID $CurrentBucket.id -taskTitle $Task.task

    if ($CreatedTask) {
        try {
            $TaskUpdate = Update-TaskDetail -accessToken $accessToken -taskID $CreatedTask.id -description $Task.details
        } catch {
            Write-Error "Não foi possível atualizar os detalhes da tarefa: '$($Task.task)'.`n $_"
        }
    } else {
        Write-Error "Não foi possível criar a tarefa: '$($Task.task)'.`n $_"
    }
}
Start-Sleep -Seconds 1
Write-Host -ForegroundColor Green "Todas as tarefas foram criadas com sucesso."
Start-Sleep -Seconds 2

# Adicionar o Planner como uma aba no canal do Teams
$tabResponse = Add-PlannerTabToChannel -accessToken $accessToken -groupID $groupID -channelID $($TeamChannel.id) -planID $($plan.id) -teamsTabName $teamsTabName

if ($tabResponse) {
    Write-Host -ForegroundColor Green "Aba do Planner adicionada com sucesso ao canal do Teams."
} else {
    Write-Error "Falha ao adicionar a aba do Planner ao canal do Teams.`n $_"
}


