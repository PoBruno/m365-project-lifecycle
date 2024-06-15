# Script PowerShell para Criar Plano e Canais no Microsoft Teams

## Descrição

Este script em PowerShell automatiza a criação de um plano no Microsoft Planner e dos canais associados em um time do Microsoft Teams, utilizando dados de um arquivo CSV. Esta automação inicial é parte de um projeto mais amplo para desenvolver um ciclo de vida completo de gerenciamento de projetos integrando Planner, SharePoint e Teams.

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


## Uso

1. Clone este repositório em sua máquina local.
    * `git clone https://github.com/PoBruno/m365-project-lifecycle.git`
    * `cd m365-project-lifecycle/Scripts/`
2. Abra o PowerShell (versão 7 ou superior).
3. Execute o script `Prepare-Plan-Channel.ps1` fornecendo os parâmetros necessários:
    
    ```powershell
    .\Prepare-Plan-Channel.ps1 `
        -clientID $clientID `
        -tenantID $tenantID `
        -clientSecret $clientSecret `
        -csvfilepath $csvfilepath `
        -PlanName $PlanName `
        -GroupID $groupID
    ```
    > Certifique-se de substituir os valores das variáveis pelos valores apropriados.

4. O script irá criar o plano no Microsoft Planner, os buckets e tarefas associadas, e o canal no Microsoft Teams.
5. Verifique se o plano e canal foram criados com sucesso.
5. Execute o script `Prepare-TeamChannel.ps1` fornecendo os parâmetros necessários:
    
    ```powershell
    .\Prepare-TeamChannel.ps1 `
        -clientID $clientID `
        -tenantID $tenantID `
        -clientSecret $clientSecret `
        -channelDisplayName $channelDisplayName `
        -channelDescription $channelDescription `
        -groupID $groupID
    ```
    > Certifique-se de substituir os valores das variáveis pelos valores apropriados.

6. O script irá criar o canal no Microsoft Teams e adicionar a tab do Planner.
7. Verifique se o canal foi criado com sucesso e se a tab do Planner foi adicionada.


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

