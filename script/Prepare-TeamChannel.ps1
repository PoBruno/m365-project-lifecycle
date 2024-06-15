<#
.SYNOPSIS
    Este script cria um novo canal em um time do Microsoft Teams.
.DESCRIPTION
    Este script cria um novo canal em um time do Microsoft Teams especificado.
    O script usa o Microsoft Graph API para criar o canal.
    O script requer credenciais de cliente válidas para obter o token de acesso.
    O script requer permissões de aplicativo para criar canais em times.
    O script requer permissões de aplicativo para ler detalhes do time.
    O script exibe o nome de exibição do time após a criação do canal.
    O script exibe mensagens de erro se ocorrerem problemas durante a execução.
.EXAMPLE
    .\Prepare-TeamChannel.ps1 `
        -clientID "<clientID>" `
        -tenantID "<tenantID>" `
        -clientSecret "<clientSecret>" `
        -channelDisplayName "<channelDisplayName>" `
        -channelDescription "<channelDescription>"
.NOTES
    File Name      : Prepare-TeamChannel.ps1
    Author         : Bruno Gomes
    GitHub         : https://github.com/PoBruno/m365-project-lifecycle
#>

param(
    [parameter(Mandatory = $true)]
    [String] $clientID,
    [parameter(Mandatory = $true)]
    [String] $tenantID,
    [parameter(Mandatory = $true)]
    [String] $clientSecret,
    [parameter(Mandatory = $true)]
    [String] $channelDisplayName,
    [parameter(Mandatory = $true)]
    [String] $channelDescription,
    [parameter(Mandatory = $true)]
    [String] $groupID  # Adicionei este parâmetro necessário para identificar o Team
)

# Função para obter o token de acesso usando credenciais de cliente
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

# Exemplo de uso das funções para criar um canal em um time do Microsoft Teams
try {

    # Obtém o token de acesso
    $accessToken = Get-AccessToken -clientID $clientID -tenantID $tenantID -clientSecret $clientSecret

    if ($accessToken) {
        Write-Host "Token de Acesso obtido com sucesso." -ForegroundColor Green
        
        # Cria o canal no time especificado
        $response = Create-TeamChannel -accessToken $accessToken -teamId $teamId -channelDisplayName $channelDisplayName -channelDescription $channelDescription

        if ($response) {
            Write-Host "Canal criado com sucesso." -ForegroundColor Green

            # Obtém e exibe o nome de exibição do time
            $teamDisplayName = Get-TeamDisplayName -accessToken $accessToken -teamId $teamId

            if ($teamDisplayName) {
                Write-Host "Nome de exibição do time: $teamDisplayName" -ForegroundColor Yellow
            } else {
                Write-Host "Não foi possível obter o nome de exibição do time." -ForegroundColor Yellow
            }
        } else {
            Write-Host "Não foi possível criar o canal." -ForegroundColor Red
        }
    } else {
        Write-Host "Não foi possível obter o token de acesso." -ForegroundColor Red
    }
} catch {
    Write-Host "Erro geral: `n$_" -ForegroundColor Red
}


# Obter o token de acesso
$accessToken = Get-AccessToken -clientID $clientID -tenantID $tenantID -clientSecret $clientSecret

if ($accessToken) {
    Write-Host "Token de Acesso gerado com sucesso." -ForegroundColor Green

    # Obter o nome do time
    $teamDisplayName = Get-TeamDisplayName -accessToken $accessToken -teamId $groupID

    if ($teamDisplayName) {
        # Criar um novo canal
        $response = Create-TeamChannel -accessToken $accessToken -teamId $groupID -channelDisplayName $channelDisplayName -channelDescription $channelDescription

        if ($response) {
            Write-Host "Canal criado com sucesso." -ForegroundColor Green
            Write-Host "`n`t- Time  : $teamDisplayName`n`t- Canal : $channelDisplayName`n" -ForegroundColor Yellow
        } else {
            Write-Host "Não foi possível criar o Canal." -ForegroundColor Red
        }
    } else {
        Write-Host "Não foi possível encontrar o Time." -ForegroundColor Red
    }
} else {
    Write-Host "Erro ao gerar Token de Acesso." -ForegroundColor Red
}

pause

# #
# FIM DO SCRIPT
