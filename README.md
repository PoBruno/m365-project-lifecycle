# Script PowerShell para Criar Plano e Canais no Microsoft Teams

## Descrição

Este script em PowerShell automatiza a criação de um plano no Microsoft Planner e dos canais associados em um time do Microsoft Teams, utilizando dados de um arquivo CSV. Esta automação inicial é parte de um projeto mais amplo para desenvolver um ciclo de vida completo de gerenciamento de projetos integrando Planner, SharePoint e Teams.

> **Nota:** Através de templates de projetos em CSV, é possível criar um banco de templates para diferentes tipos de projetos, facilitando a criação de planos e canais de forma rápida e padronizada.

## Exemplo de Template: Projeto Migração SQL Server
`\data\Template_MigraSQL.csv`

|Task|Bucket|Details|
|---|---|---|
|Identificar Stakeholders|Planejamento|Identificar os stakeholders chave para o projeto de migração do SQL Server.|
|Definir Objetivos do Projeto|Planejamento|Definir objetivos e metas claras para a migração do SQL Server.|
|Elaborar Cronograma|Planejamento|Elaborar um cronograma detalhado para a migração.|
|Analisar Infraestrutura Atual|Avaliação|Analisar a infraestrutura atual do SQL Server.|
|Inventariar Banco de Dados|Avaliação|Inventariar todos os bancos de dados que serão migrados.|
|Identificar Dependências|Avaliação|Identificar dependências e integrações com outros sistemas.|
|Realizar Backup Completo|Pré-Migração|Realizar um backup completo dos bancos de dados.|
|Configurar Novo Ambiente|Pré-Migração|Configurar o novo ambiente de SQL Server.|
|Executar Testes de Migração|Pré-Migração|Executar testes de migração para garantir que tudo funcione corretamente.|
|Migrar Dados|Migração|Migrar os dados do ambiente antigo para o novo ambiente de SQL Server.|
|Validar Dados Migrados|Migração|Validar se todos os dados foram migrados corretamente.|
|Ajustar Configurações Pós-Migração|Pós-Migração|Ajustar configurações e otimizar o novo ambiente.|
|Realizar Testes de Desempenho|Pós-Migração|Realizar testes de desempenho no novo ambiente de SQL Server.|
|Treinar Usuários e Administradores|Pós-Migração|Treinar usuários e administradores no uso do novo sistema.|
|Obter Aprovação Final|Encerramento|Obter aprovação final dos stakeholders após a migração.|
|Documentar Lições Aprendidas|Encerramento|Documentar lições aprendidas e realizar um encerramento formal do projeto.|

## Imagem Exemplo

![Teams Plan](./images/TeamsChannelPlan.png)


## Pré-requisitos

- PowerShell versão 5 ou superior

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

<br>

## Modelos de Planos em CSV

O arquivo CSV deve ter como delimitador ponto e virgula ``;``, pois desse modo podemos usar ``,`` para o campo destinado a descrição da tarefa. Deve conter as seguintes colunas para importação no Planner: `TaskName`, `BucketName` e `Details`. Templates de arquivos CSV estão disponíveis na pasta [./data](./data).

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



## Parâmetros

### `-clientID`

- **Tipo:** String
- **Obrigatório:** Sim
- **Descrição:** ID do cliente usado para autenticação no Azure AD.

### ``-tenantID``

- **Tipo:** String
- **Obrigatório:** Sim
- **Descrição:** ID do locatário (tenant) usado para autenticação no Azure AD.

### ``-clientSecret``

- **Tipo:** String
- **Obrigatório:** Sim
- **Descrição:** Segredo do cliente usado para autenticação no Azure AD.

### ``-GroupID``

- **Tipo:** String
- **Obrigatório:** Sim
- **Descrição:** ID do grupo do Microsoft Teams onde o plano e os canais serão criados.

### ``-PlanName``

- **Tipo:** String
- **Obrigatório:** Sim
- **Descrição:** Nome do plano que será criado no Microsoft Planner.

### ``-csvFilePath``

- **Tipo:** String
- **Obrigatório:** Sim
- **Descrição:** Caminho do arquivo CSV contendo as tarefas e os buckets a serem importados. O CSV precisa conter o formato `TaskName;BucketName;Details`, hearder e delimitador ``;``.

### ``-teamsTabName``

- **Tipo:** String
- **Obrigatório:** Não (Padrão: "Planner")
- **Descrição:** Nome da aba do Teams onde o Planner será adicionado.

### ``-channelDisplayName``

- **Tipo:** String
- **Obrigatório:** Não (Padrão: Nome do plano)
- **Descrição:** Nome do canal a ser criado no Teams.

### ``-channelDescription``

- **Tipo:** String
- **Obrigatório:** Não (Padrão: "Canal para gerenciamento de tarefas do Planner - PlanName")
- **Descrição:** Descrição do canal a ser criado no Teams.

<br>

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

