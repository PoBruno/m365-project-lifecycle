<#
.SYNOPSIS
    Este script cria um plano no Planner e os buckets e tarefas associados a partir de um arquivo CSV.
.DESCRIPTION
    Este script cria um plano no Planner e os buckets e tarefas associados a partir de um arquivo CSV. O arquivo CSV deve conter as seguintes colunas:
    - Task
    - Bucket
    - Details
.PARAMETER clientID
    O ID do Cliente da Aplicação Azure AD.
.PARAMETER tenantID
    O ID do Tenant da Aplicação Azure AD.
.PARAMETER clientSecret
    O Segredo do Cliente da Aplicação Azure AD.
.PARAMETER csvFilePath
    O caminho para o arquivo CSV que contém Tarefas, Buckets e Detalhes.
.PARAMETER PlanName
    O nome do Plano do Planner a ser criado.
.PARAMETER GroupID
    O ID do Grupo Microsoft 365 para associar ao Plano.
.PARAMETER StorageAccountName
    O nome da Conta de Armazenamento onde o arquivo CSV está localizado.
.PARAMETER StorageContainerName
    O nome do Contêiner de Armazenamento onde o arquivo CSV está armazenado.
.EXAMPLE
    .\Prepare-Plan-Channel.ps1 `
        -clientID "12345678-1234-1234-1234-123456789012" `
        -tenantID "12345678-1234-1234-1234-123456789012" `
        -clientSecret "12345678-1234-1234-1234-123456789012" `
        -csvFilePath "C:\Users\user\Documents\Tarefas.csv" `
        -PlanName "Projeto de Marketing" `
        -csvUsersPath "C:\Users\user\Documents\Usuários.csv" `
        -GroupID "12345678-1234-1234-1234-123456789012"
.NOTES
    Nome do Arquivo : Prepare-Plan-Channel.ps1
    Autor           : Bruno Gomes
    GitHub          : https://github.com/PoBruno/m365-project-lifecycle
#>

# Parametros
param(
    [parameter(Mandatory = $true)]
    [String] $clientID,
    [parameter(Mandatory = $true)]
    [String] $tenantID,
    [parameter(Mandatory = $true)]
    [String] $clientSecret,
    [parameter(Mandatory = $true)]
    [String] $csvFilePath,
    [parameter(Mandatory = $true)]
    [String] $PlanName,
    [parameter(Mandatory = $true)]
    [String] $GroupID,
    [parameter(Mandatory = $false)]
    [String] $StorageAccountName,
    [parameter(Mandatory = $false)]
    [String] $StorageContainerName
)

# Se o nome da conta de armazenamento for fornecido, baixe o CSV da conta de armazenamento
if ($StorageContainerName) {
    Write-Host "Parâmetro do Contêiner de Armazenamento detectado, baixando CSV da conta de armazenamento..." -ForegroundColor Cyan
    try {
        Connect-AzAccount -Identity
        $context = New-AzStorageContext -StorageAccountName $StorageAccountName
        Get-AzStorageBlobContent -Blob $CSVFilePath -Container $StorageContainerName -Context $context
        $csv = Import-Csv $CSVFilePath
        Write-Host "CSV baixado e importado com sucesso." -ForegroundColor Green
    } catch {
        Write-Error "Não foi possível baixar o CSV do armazenamento. Verifique o nome do contêiner e tente novamente. Erro:`n$_"
        #exit
    }
} else {
    Write-Host "Importando CSV localmente..." -ForegroundColor Cyan
    try {
        $csv = Import-Csv $csvFilePath -Delimiter ";"

        # Verifica se o CSV contém as colunas necessárias
        if ($null -eq $csv.task -or $null -eq $csv.bucket) {
            Write-Error "O CSV não contém as colunas 'task' ou 'bucket'. Verifique o CSV e tente novamente."
            #exit
        } else {
            Write-Host "CSV importado com sucesso." -ForegroundColor Green
        }

    } catch {
        Write-Error "Não foi possível importar o CSV. Verifique o caminho e tente novamente. Erro:`n$_"
        #exit
    }
}

# Funcao para Obter o token de acesso
function Get-AccessToken {
    param (
        [String] $clientID,
        [String] $tenantID,
        [String] $clientSecret
    )
    $body = @{
        Grant_Type    = "client_credentials"
        Scope         = "https://graph.microsoft.com/.default"
        Client_Id     = $clientID
        Client_Secret = $clientSecret
    }
    try {
        $TokenRequest = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $body
        return $TokenRequest.access_token
    } catch {
        Write-Host "Erro ao obter o token de acesso: `n`t- $_" -ForegroundColor Red
        return $null
    }
}

# Conectar ao Graph
try {
    $accessToken = Get-AccessToken -clientID $clientID -tenantID $tenantID -clientSecret $clientSecret
    if (-not $accessToken) {
        throw "Não foi possível obter o token de acesso. Verifique as credenciais e tente novamente."
    }
    $secureAccessToken = ConvertTo-SecureString -String $accessToken -AsPlainText -Force
    Write-Host "Token de acesso obtido com sucesso." -ForegroundColor Green
    Connect-MgGraph -AccessToken $secureAccessToken
} catch {
    Write-Error "Erro ao obter ou utilizar o token de acesso:`n$_"
    #exit
}


Write-Host -f Yellow "Provisionando Plano..."
## Criar o Plano
$params = @{
    container = @{
        url = "https://graph.microsoft.com/v1.0/groups/$GroupID"
    }
    title = $PlanName
}

try {
    $plan = New-MgPlannerPlan -BodyParameter $params

    if (-not $plan) {
        throw "Não foi possível criar o plano. Verifique se o grupo existe e tente novamente."
    }
    Write-Host "Plano criado com sucesso." -ForegroundColor Green
} catch {
    $errorMessage = $_.Exception.Message
    Write-Error "Erro ao criar o plano: $errorMessage"
    #exit
}


Write-Host -f Yellow "Provisionando Buckets..."
## Percorrer os buckets únicos e provisionar os Buckets
[array]$Buckets = ($csv | Select-Object -ExpandProperty Bucket -Unique)
$BucketList = @()

foreach ($bucket in $Buckets) {
    Write-Progress -Activity "Criando Buckets" -Status "Criando Bucket '$bucket'" -PercentComplete ((($Buckets.IndexOf($bucket) + 1) / $Buckets.count) * 100)

    $params = @{
        name      = $bucket
        planId    = $plan.id
        orderHint = " !"
    }

    try {
        $CreatedBucket = New-MgPlannerBucket -BodyParameter $params
        $BucketList += $CreatedBucket
        $params.orderHint = " $($CreatedBucket.orderhint)!"  # Atualiza o orderHint para o próximo bucket
    } catch {
        Write-Error "Não foi possível criar o bucket: '$bucket'. Erro:`n$_"
        #exit
    }
}
Write-Host "Todos os buckets foram criados com sucesso." -ForegroundColor Green


Write-Host -f Yellow "Provisionando Tarefas..."
## Criar Tarefas nos buckets
$i = 0
foreach ($Task in $csv) {
    $i++
    Write-Progress -Activity "Criando Tarefas" -Status "Criando Tarefa $i de $($csv.count)" -PercentComplete (($i / $csv.count) * 100)
    $CurrentBucket = $BucketList | Where-Object { $_.name -eq $Task.Bucket }

    try {
        $params = @{
            planId   = "$($plan.id)"
            bucketId = "$($CurrentBucket.id)"
            title    = "$($Task.task)"
        }

        $CreatedTask = New-MgPlannerTask -BodyParameter $params

        $params = @{
            description = "$($Task.details)"
            previewType = "description"
        }

        ## Atualizar detalhes da Tarefa
        try {
            Update-MgPlannerTaskDetail -PlannerTaskId $CreatedTask.Id -BodyParameter $params -IfMatch (Get-MgPlannerTaskDetail -PlannerTaskId $CreatedTask.id).AdditionalProperties["@odata.etag"]
        } catch {
            Write-Error "Não foi possível atualizar os detalhes da tarefa: $($Task.task). Erro:`n $_"
            #exit
        }

    } catch {
        Write-Error "Não foi possível criar a tarefa: $($Task.task). Erro:`n $_"
        #exit
    }
}


Try {
    $ChannelID = (Get-MgTeamChannel -TeamId $GroupID | ?{ $_.DisplayName -eq $PlanName }).id
    $params = @{
        name                  = "Escopo de Projeto"
        displayName           = "Escopo de Projeto"
        "teamsapp@odata.bind" = "https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/com.microsoft.teamspace.tab.planner"
        configuration         = @{
            contentUrl = "https://tasks.teams.microsoft.com/teamsui/{tid}/Home/PlannerFrame?page=7&auth_pvr=OrgId&auth_upn={userPrincipalName}&groupId={groupId}&planId=$($plan.id)&channelId={channelId}&entityId={entityId}&tid={tid}&userObjectId={userObjectId}&subEntityId={subEntityId}&sessionId={sessionId}&theme={theme}&mkt={locale}&ringId={ringId}&PlannerRouteHint={tid}"
            removeUrl = "https://tasks.teams.microsoft.com/teamsui/{tid}/Home/PlannerFrame?page=13&auth_pvr=OrgId&auth_upn={userPrincipalName}&groupId={groupId}&planId=$($plan.id)&channelId={channelId}&entityId={entityId}&tid={tid}&userObjectId={userObjectId}&subEntityId={subEntityId}&sessionId={sessionId}&theme={theme}&mkt={locale}&ringId={ringId}&PlannerRouteHint={tid}"
            websiteUrl = "https://tasks.office.com/{tid}/Home/PlanViews/$($plan.id)?Type=PlanLink&Channel=TeamsTab"
        }
    }
    $CreatedTab = New-MgTeamChannelTab -TeamId $GroupID -ChannelId $ChannelID -BodyParameter $params
} catch {
    Write-Error "Não foi possível criar o tab para a tarefa: $($Task.task). Erro:`n $_"
    #exit
}

Write-Host "Script finalizado com sucesso."

pause

# #
# FIM DO SCRIPT
