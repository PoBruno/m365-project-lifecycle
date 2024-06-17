# Documentação Completa

Esta documentação fornece detalhes completos sobre como usar o script PowerShell para criar planos e canais no Microsoft Teams.

## Índice

- [Configuração do Aplicativo no Azure AD](./azure-ad-setup.md)
- [Preparando o Arquivo CSV](./csv-templates.md)
- [Executando o Script](#executando-o-script)
- [Modelos de Planos em CSV](./csv-templates.md)
- [Parâmetros do Script](./script-parameters.md)
- [Contribuições](./contributing.md)

<br>

## Visão Geral

Este script em PowerShell automatiza a criação de um Backlog de Projeto no **Microsoft Planner**, a criação de um canal no **Microsoft Teams** e o provisionamento de uma biblioteca de arquivos do **SharePoint**.

A documentação está organizada em seções para facilitar a navegação e a compreensão.

## Executando o Script

1. **Clone o Repositório e Navegue até a Pasta dos Scripts:**

    ```bash
    git clone https://github.com/PoBruno/m365-project-lifecycle.git
    cd m365-project-lifecycle/Scripts/
    ```

2. **Configure o Aplicativo no Azure AD:**

    Antes de executar o script, siga os passos para configurar um aplicativo no Azure AD descritos [aqui](./azure-ad-setup.md).

3. **Prepare seu Arquivo CSV:**

    Crie um arquivo CSV com as tarefas e buckets conforme o formato especificado [aqui](./csv-templates.md).

4. **Execute o Script `Create-PlannerAndTeamsChannel.ps1`:**

    Execute o script fornecendo os parâmetros necessários:

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

Para mais detalhes sobre os parâmetros, consulte [aqui](./script-parameters.md).


# Preparando o Arquivo CSV

Para facilitar a criação e o gerenciamento de projetos no Microsoft Planner, utilize arquivos CSV padronizados.

## Formato do Arquivo CSV

- **Delimitador:** Ponto e vírgula (`;`)
- **Colunas Necessárias:**
    - **TaskName:** Nome da tarefa.
    - **BucketName:** Nome do bucket.
    - **Details:** Detalhes ou descrição da tarefa.

## Estrutura do Arquivo CSV

Exemplo de estrutura:

TaskName;BucketName;Details
Identificar Stakeholders;Planejamento;Identificar os stakeholders chave para o projeto de migração do SQL Server.
Definir Objetivos do Projeto;Planejamento;Definir objetivos e metas claras para a migração do SQL Server.

markdown
Copy code

## Banco de Templates

Recomendamos a criação de um banco de templates para diferentes tipos de projetos. Isso facilita a padronização e agilidade na criação de novos planos de projeto.

1. **Crie seus Templates:** Crie templates de projetos em formato CSV e salve-os na pasta `./script/templates`.
2. **Padronize a Criação de Projetos:** Use os templates para modelar o escopo de todos os projetos.
3. **Edite os Templates:** Personalize os templates conforme necessário.
4. **Salve e Importe:** Salve os arquivos CSV e use o script PowerShell para importar os dados.

Exemplo de template: `./script/templates/Template_MigraSQL.csv`

|Task|Bucket|Details|
|---|---|---|
|Identificar Stakeholders|Planejamento|Identificar os stakeholders chave para o projeto de migração do SQL Server.|
|Elaborar Cronograma|Planejamento|Elaborar um cronograma detalhado para a migração.|
...