

## Parâmetros de conexão com Microsoft Graph
$clientID = $clientID
$tenantID = $tenantID
$clientSecret = $clientSecret

## Autenticação com Microsoft Graph
$body = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientID
    Client_Secret = $clientSecret
}

$TokenRequest = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $body
$accessToken = $TokenRequest.access_token

## Ler o CSV de usuários
Try {
    $csvUsers = import-csv $csvUsersPath
}
catch {
    write-error "Could not import CSV with users, please check the path and try again. Error:`n $_"
    #exit
}

## Função para obter o ID de um usuário a partir de um endereço de e-mail
#$email = "rob@monga.dev.br"
<#

function Get-UserId($email) {
    $filter = "userPrincipalName eq '$email'"
    $user = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users?`$filter=$filter" -Headers @{Authorization = "Bearer $accessToken" }
    return $user.value[0].id
}

#>

function Get-UserId($email) {
    $filter = "imAddresses/any(i:i eq '$email')"
    $user = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/users?`$filter=$filter" -Headers @{Authorization = "Bearer $accessToken" }
    return $user.value[0].id
}

## Função para adicionar um usuário ao grupo se não estiver já presente
function Add-UserToGroup($userIds, $groupId) {
    # Obter os membros do grupo
    $groupMembers = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups/$groupId/members" -Headers @{Authorization = "Bearer $accessToken" }
    $existingUserIds = $groupMembers.value | ForEach-Object { $_.id }
    # Separar os usuários que não estão no grupo
    $newUserIds = $userIds | Where-Object { $_ -notin $existingUserIds }

    # Configurar o body da requisição para adicionar os usuários ao grupo
    if ($newUserIds.Count -gt 0) {
        $addMembersBody = @{
            "members@odata.bind" = $newUserIds | ForEach-Object { "https://graph.microsoft.com/v1.0/directoryObjects/$_" }
        }
        # Adicionar os usuários ao grupo
        $response = try {
            Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups/$groupId" -Method PATCH -Headers @{Authorization = "Bearer $accessToken"; "Content-Type" = "application/json" } -Body ($addMembersBody | ConvertTo-Json -Depth 10) -ErrorAction Stop
        } catch {
            $_.Exception.Response
        }
        # Verificar se a requisição foi bem sucedida
        if ($response.StatusCode -eq 'BadRequest') {
            Write-Host "Failed to add users to group $groupId. Status code: $($response.StatusCode)"
        } else {
            Write-Host "Added users to group $groupId."
        }
    # Se todos os usuários já estiverem no grupo    
    } else {
        Write-Host "All users already in group $groupId."
    }
}

## Cria a lista de membros a partir do CSV e verifica se estão no grupo
$members = @()
$userIds = @()
$csvUsers | ForEach-Object {
    $userId = Get-UserId $_.Email
    $userIds += $userId

    $members += @{
        "@odata.type"     = "#microsoft.graph.aadUserConversationMember"
        "user@odata.bind" = "https://graph.microsoft.com/v1.0/users('$userId')"
        roles             = @("owner")
    }
}

## Adiciona usuários ao grupo
Add-UserToGroup -userIds $userIds -groupId $GroupID

## Parâmetros do canal
$params = @{
    "@odata.type"  = "#Microsoft.Graph.channel"
    membershipType = "private"
    displayName    = $channelDisplayName
    description    = $channelDescription
    members        = $members
}

## Criar o canal no Teams
$teamId = $GroupID
$uri = "https://graph.microsoft.com/v1.0/teams/$teamId/channels"

$response = Invoke-RestMethod -Uri $uri -Method POST -Headers @{Authorization = "Bearer $accessToken"; "Content-Type" = "application/json" } -Body ($params | ConvertTo-Json -Depth 10)

if ($response) {
    write-host "Channel created successfully."
} else  {
    write-error "Could not create the channel."
}



