# Documentação das APIs do Microsoft Graph  

Este documento descreve as APIs do Microsoft Graph utilizadas no projeto para automatização de criação de planos no Microsoft Planner e canais no Microsoft Teams.  

## APIs Utilizadas  

### Obter Token de Acesso  

- **Endpoint:** `POST https://login.microsoftonline.com/{tenantId}/oauth2/v2.0/token`

    ```json
    Body:
    {
        client_id: "client_id",
        scope: "https://graph.microsoft.com/.default",
        client_secret: "client_secret",
        grant_type: "client_credentials"
    }

    Headers:
    {
        Content-Type: "application/x-www-form-urlencoded"
    }
    ```
    #### Exemplo PowerShell: 
    ```powershell
    $Body = @{
        client_id     = "client_id"
        scope         = "https://graph.microsoft.com/.default"
        client_secret = "client_secret"
        grant_type    = "client_credentials"
    }
    $Headers = @{
        Content-Type = "application/x-www-form-urlencoded"
    }

    $response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method POST -Body $Body -Headers $Headers
    
    $access_token = $response.access_token
    ```

#### Descrição:
- Obtém um token de acesso para autenticar e autorizar as chamadas às APIs do Microsoft Graph.
- O token é utilizado no cabeçalho de autorização das chamadas às APIs do Microsoft Graph.
    - É obtido utilizando o fluxo de concessão de credenciais de cliente (client credentials grant).
    - Tem um tempo de expiração e deve ser renovado periodicamente.
    - É necessário para chamar as APIs do Microsoft Graph.
<br><br>

---

<br>

### Criar um Plano no Planner  

- **Endpoint:** `POST https://graph.microsoft.com/v1.0/planner/plans`

    ```json
    Body:
    {
        owner: "group-id",
        title: "Plano de Projeto"
    }

    Headers:
    {
        Authorization: "Bearer { access_token }",
        Content-Type: "application/json"
    }
    ```

    #### Exemplo: 
    ```powershell
    $Body = @{
        owner = "group-id"
        title = "Plano de Projeto"
    }
    $Headers = @{
        Authorization = "Bearer $access_token"
        Content-Type = "application/json"
    }

    New-MgPlannerPlan -BodyParameter $Body -Headers $Headers

    ```
    
#### Descrição:
- Cria um novo plano no Microsoft Planner associado a um grupo específico do Microsoft 365.
- O plano é criado com o título especificado e o grupo é definido como proprietário.
- O plano é criado com um conjunto padrão de buckets.
<br><br>

---

<br>

### Criar um Canal no Teams

- **Endpoint:** `https://graph.microsoft.com/v1.0/teams/{teamId}/channels`

    ```json	
        Body:
        {
            displayName: "Novo Canal"
        }

        Headers:
        {
            Authorization: "Bearer { access_token }",
            Content-Type: "application/json"
        }

    ```

- Exemplo PowerShell:

    ```powershell
    $Body = @{
        displayName = "Novo Canal"
    }
    $Headers = @{
        Authorization
        Content-Type = "application/json"
    }

    New-MgTeamChannel -TeamId $teamId -ChannelDisplayName "Novo Canal"
    ```
    
####  Descrição:

- Cria um novo canal em um time do Microsoft Teams com o nome especificado.
<br><br>

---

<br>

### Adicionar um Canal como Aba no Teams

- **Endpoint:** `POST https://graph.microsoft.com/v1.0/teams/{teamId}/channels/{channelId}/tabs`

```json
Body:
{
    name: "Planner",
    displayName: "Planner",
    "teamsapp@odata.bind": "https://graph.microsoft.com/v1.0/appCatalogs/teamsApps/com.microsoft.teamspace.tab.planner",
    configuration: {
        contentUrl: "https://tasks.teams.microsoft.com/...",
        removeUrl: "https://tasks.teams.microsoft.com/...",
        websiteUrl: "https://tasks.office.com/..."
    }
}

Headers:
{
    Authorization: "Bearer { access_token }",
    Content-Type: "application/json"
}
```

- Exemplo PowerShell:

```powershell
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

```

####  Descrição:
- Adiciona um canal como uma nova aba em um time do Microsoft Teams.
<br><br>

---

<br>


### Atualizar Detalhes de uma Tarefa no Planner

Endpoint:


PATCH https://graph.microsoft.com/v1.0/planner/tasks/{taskId}/details

####  Descrição:


Atualiza os detalhes de uma tarefa específica no Microsoft Planner.

#### Exemplo:


Update-MgPlannerTaskDetail -PlannerTaskId $taskId -BodyParameter @{     description = "Novos detalhes da tarefa"     previewType = "description" }

<br><br>

---

<br>


### Obter Detalhes de um Time do Teams

Endpoint:


GET https://graph.microsoft.com/v1.0/teams/{teamId}

####  Descrição:


Obtém os detalhes de um time específico do Microsoft Teams.

#### Exemplo:


Get-MgTeam -TeamId $teamId

<br><br>

---

<br>


### Obter Detalhes de um Canal do Teams

Endpoint:


GET https://graph.microsoft.com/v1.0/teams/{teamId}/channels/{channelId}

####  Descrição:


Obtém os detalhes de um canal específico em um time do Microsoft Teams.

#### Exemplo:


Get-MgTeamChannel -TeamId $teamId -ChannelId $channelId

Esta documentação lista as principais APIs do Microsoft Graph utilizadas no projeto para facilitar a automação de tarefas de gerenciamento de projetos utilizando o Planner e o Teams.