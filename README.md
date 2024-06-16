# Script PowerShell para Criar Plano e Canais no Microsoft Teams


## Descrição

Este script em PowerShell automatiza a criação de um plano no Microsoft Planner e dos canais associados em um time do Microsoft Teams, utilizando dados de um arquivo CSV. Esta automação inicial é parte de um projeto mais amplo para desenvolver um ciclo de vida completo de gerenciamento de projetos integrando Planner, SharePoint e Teams.


![Teams Plan](./images/TeamsChannelPlan.png)


## Pré-requisitos

- PowerShell versão 7 ou superior
- Módulos do Azure e Microsoft Graph devidamente instalados e configurados

## Funcionalidades

- Cria um plano no Microsoft Planner
- Cria buckets no plano com base em dados de um arquivo CSV
- Cria tarefas nos buckets também baseadas no arquivo CSV
- Cria um canal no Microsoft Teams associado ao plano
- Adiciona uma tab do Planner ao canal do Teams

<br>



### Objetivo e Visão Futura

---

O objetivo final deste projeto é estabelecer uma arquitetura lógica robusta para o gerenciamento de projetos, facilitando a colaboração e a execução eficiente através das seguintes etapas:

- **Automação com PowerShell**: Desenvolver e testar a lógica central do processo de gerenciamento de projetos utilizando PowerShell.
- **Integração Completa**: Integrar Microsoft Planner para planejamento de tarefas, SharePoint para armazenamento e colaboração de documentos, e Teams para comunicação e execução de tarefas.
- **Expansão Funcional**: Futuramente, adicionar funcionalidades como atribuição de datas de início e término, responsáveis por tarefas, e outros campos personalizados conforme necessário.
- **Transição para Power Automate**: Uma vez validada a lógica de automação e integração no PowerShell, migrar para o Power Automate para uma solução mais escalável e acessível.

<br>

## Configuração do Aplicativo no Azure AD

Antes de executar o script, é necessário configurar um aplicativo no Azure AD para autenticar e autorizar as chamadas à API do Microsoft Graph.

### Passos para Criar um App Registration:

1. **Acessar o Portal do Azure:**
    
    - Acesse [https://portal.azure.com](https://portal.azure.com).
2. **Criar um novo App Registration:**
    
    - No portal do Azure, navegue até "Azure Active Directory" > "App registrations" > "New registration".
    - Forneça um nome para o aplicativo e escolha a opção de conta adequada.
3. **Configurar as Permissões de API (Microsoft Graph):**
    
    - Após criar o aplicativo, navegue até "API permissions".
    - Clique em "Add a permission" e selecione "Microsoft Graph".

4. **Adicionar Permissões (Scope) do Microsoft Graph:**
    
    - Para adicionar permissões do Microsoft Graph, clique em "Add a permission".
    - Selecione "Microsoft Graph" > "Application permissions".
    <br><br>
    - Application Permissions (Permissões de Aplicativo):

        - **Group.ReadWrite.All**: Permite que o aplicativo leia e escreva em todos os grupos.
        - **Group.Read.All**: Permite que o aplicativo leia todos os grupos.
        - **User.Read.All**: Permite que o aplicativo leia todos os usuários.
        - **Directory.ReadWrite.All**: Permite que o aplicativo leia e escreva em todos os dados do diretório.
        - **Tasks.ReadWrite**: Permite que o aplicativo leia e escreva tarefas no Planner.
        - **Channel.ReadWrite.All**: Permite que o aplicativo leia e escreva em todos os canais do Microsoft Teams.
    <br><br>
    
5. **Conceder Permissões:**
    
    - Após adicionar as permissões, você precisará concedê-las. Clique em "Grant admin consent for [tenant]" para garantir que as permissões sejam aplicadas ao locatário.
6. **Gerar Client Secret:**
    
    - Vá para "Certificates & secrets" no menu do aplicativo no portal do Azure.
    - Em "Client secrets", clique em "New client secret".
    - Forneça uma descrição e escolha a duração da expiração do segredo.
    - Copie o valor do segredo gerado. Este será usado como `$clientSecret` no script PowerShell.


## Uso

## Uso

1. Clone este repositório em sua máquina local:
    ```bash
    #Clonar o repositorio
    git clone https://github.com/PoBruno/m365-project-lifecycle.git
    #Acessar a pasta Scripts
    cd m365-project-lifecycle/Scripts/
    ```

2. Configuração do Aplicativo no Azure AD:
    - Siga os passos acima para criar um App Registration, adicionar permissões do Microsoft Graph e gerar um Client Secret.

3. Abra o PowerShell (versão 7 ou superior).

4. Execute o script `Create-PlannerAndTeamsChannel.ps1` fornecendo os parâmetros necessários:

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

5. Verifique se todas as operações foram executadas com sucesso.


## Parâmetros

- **clientID**: ID do cliente da aplicação Azure AD.
- **tenantID**: ID do tenant da aplicação Azure AD.
- **clientSecret**: Segredo do cliente da aplicação Azure AD.
- **csvFilePath**: Caminho para o arquivo CSV que contém as tarefas e buckets.
- **PlanName**: Nome do plano a ser criado no Microsoft Planner.
- **GroupID**: ID do grupo Microsoft 365 ao qual o plano e canal serão associados.

## Modelos de Planos em CSV

O arquivo CSV deve conter as seguintes colunas obrigatórias para importação no Planner: `TaskName`, `BucketName` e `Details`. Templates de arquivos CSV estão disponíveis na pasta [./data](./data).

### Estrutura do CSV

- **TaskName**: Nome da tarefa a ser criada no Planner.
- **BucketName**: Nome do bucket (categoria) ao qual a tarefa será associada.
- **Details**: Detalhes adicionais relevantes para a tarefa.

### Personalização e Expansão Futura

Inicialmente projetei para importações básicas, o modelo de CSV pode ser expandido no futuro para incluir:

- **Datas de Início e Término**: Para agendar tarefas.
- **Responsáveis**: Para atribuir tarefas a membros da equipe.
- **Outros Campos Personalizados**: Para atender a necessidades específicas de planejamento.

### Exemplos e Documentação

Para exemplos práticos de como estruturar seu arquivo CSV e detalhes sobre como expandir suas funcionalidades, consulte os modelos fornecidos na pasta [./data](./data).




## Contribuições

Se você está interessado em contribuir para este projeto, estamos felizes em receber suas sugestões, correções de bugs e novas funcionalidades. Para começar, siga as orientações abaixo:

- Leia nosso [guia de contribuição](CONTRIBUTING.md) para entender como contribuir.
- **Abra uma issue** para discutir o que você gostaria de mudar antes de enviar um pull request.

## Autor

[Bruno Gomes](https://github.com/PoBruno)

## Licença

Este projeto está licenciado sob a [Licença MIT](./LICENSE.md).

## Agradecimentos

- [Planner](https://planner.uservoice.com/forums/330525-microsoft-planner-feedback-forum)
- [Teams](https://microsoftteams.uservoice.com/forums/555103-public?category_id=210045)
- [Microsoft Graph](https://docs.microsoft.com/pt-br/graph/overview)
- [Azure AD](https://docs.microsoft.com/pt-br/azure/active-directory/)
- [PowerShell](https://docs.microsoft.com/pt-br/powershell/scripting/overview?view=powershell-7.1)
- [Microsoft Graph API](https://developer.microsoft.com/pt-br/graph)

