

# Usando o Script

## Pré-requisitos

- PowerShell versão 5 ou superior

## Executando o Script

1. Clone o repositório e navegue até a pasta dos scripts:
    ```bash
    git clone https://github.com/PoBruno/m365-project-lifecycle.git
    cd m365-project-lifecycle/Scripts/
    ```

2. Configure o aplicativo no Azure AD conforme descrito [aqui](./azure-ad-setup.md).

3. Execute o script `Create-PlannerAndTeamsChannel.ps1` fornecendo os parâmetros necessários:
    ```powershell
    .\Create-PlannerAndTeamsChannel.ps1 `
        -clientID $clientID `
        -tenantID $tenantID `
        -clientSecret $clientSecret `
        -csvFilePath $csvFilePath `
        -PlanName $PlanName `
        -GroupID $groupID `
        [-teamsTabName $teamsTabName] `
        [-channelDisplayName $channelDisplayName] `
        [-channelDescription $channelDescription]
    ```

Certifique-se de substituir os valores das variáveis pelos valores apropriados.

## Verificando a Execução

Verifique se todas as operações foram executadas com sucesso no Microsoft Planner e no Microsoft Teams.
