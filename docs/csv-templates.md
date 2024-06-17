## Índice

- [Visão Geral](#visao-geral)
- [Configuração do Aplicativo no Azure AD](./azure-ad-setup.md)
- [Preparando o Arquivo CSV](./csv-templates.md)
    - [Formato de Aquivo CSV](#formato-do-arquivo-csv)
    - [Estrutura do Arquivo CSV](#estrutura-do-arquivo-csv)
    - [Exemplo de Template: Projeto Migração SQL Server](#exemplo-de-template-projeto-migracao-sql-server)
    - [Criação de um Banco de Templates](#criacao-de-um-banco-de-templates)
    - [Como Utilizar os Templates](#como-utilizar-os-templates)
- [Parâmetros do Script](./script-parameters.md)
- [Contribuições](./contributing.md)

<br>


# Preparando o Arquivo CSV

Para facilitar a criação e o gerenciamento de projetos no Microsoft Planner, utilize arquivos CSV padronizados.
> **NOTA:** Templates de csv na pasta [./script/templates](./script/templates)


## Formato do Arquivo CSV

- **Delimitador:** Utilize ponto e vírgula (`;`) como delimitador. Isso permite o uso de vírgulas (`,`) no campo de descrição da tarefa sem problemas.
- **Colunas Necessárias:** Certifique-se de que o arquivo CSV contenha as seguintes colunas:
    - **TaskName:** Nome da tarefa.
    - **BucketName:** Nome do bucket onde a tarefa será categorizada.
    - **Details:** Detalhes ou descrição da tarefa.


## Estrutura do Arquivo CSV

<br>

Seu arquivo CSV deve ter a seguinte estrutura:

```
TaskName;BucketName;Details 
tarefa 01 ; Categoria ; Descrição da tarefa 01
...
```

## Exemplo de Template: Projeto Migração SQL Server
`\data\Template_MigraSQL.csv`
|Task|Bucket|Details|
|---|---|---|
|Identificar Stakeholders|Planejamento|Identificar os stakeholders chave para o projeto de migração do SQL Server.|
|Elaborar Cronograma|Planejamento|Elaborar um cronograma detalhado para a migração.|
|Inventariar Banco de Dados|Avaliação|Inventariar todos os bancos de dados que serão migrados.|
|Identificar Dependências|Avaliação|Identificar dependências e integrações com outros sistemas.|
|Configurar Novo Ambiente|Pré-Migração|Configurar o novo ambiente de SQL Server.|
|Executar Testes de Migração|Pré-Migração|Executar testes de migração para garantir que tudo funcione corretamente.|
|Migrar Dados|Migração|Migrar os dados do ambiente antigo para o novo ambiente de SQL Server.|
|Validar Dados Migrados|Migração|Validar se todos os dados foram migrados corretamente.|
|Ajustar Configurações Pós-Migração|Pós-Migração|Ajustar configurações e otimizar o novo ambiente.|
|Realizar Testes de Desempenho|Pós-Migração|Realizar testes de desempenho no novo ambiente de SQL Server.|
|Obter Aprovação Final|Encerramento|Obter aprovação final dos stakeholders após a migração.|
|Documentar Lições Aprendidas|Encerramento|Documentar lições aprendidas e realizar um encerramento formal do projeto.|

<br>

## Criação de um Banco de Templates

Recomendo a criação de um banco de templates próprios para diferentes tipos de projetos. Isso facilitará a padronização e agilidade na criação de novos planos de projeto. Conseguindo gerenciar um ciclo de vida completo de gerenciamento de projetos integrando Planner, SharePoint e Teams.

## Como Utilizar os Templates

1. **Crie seus Templates:** Crie templates de projetos em formato CSV seguindo a estrutura fornecida e salve-os na pasta [./script/templates](./script/templates).
2. **Padronize a Criação de Projetos:** Adotar internamente a prática de modelar o escopo de todos os projetos usando arquivos CSV com o formato padronizado.
3. **Edite os Templates:** Personalize os templates conforme necessário para cada projeto específico. Utilize um editor de planilhas (como Microsoft Excel ou Google Sheets) para facilitar a edição.
4. **Salve e Importe:** Certifique-se de salvar os arquivos CSV editados com ponto e vírgula (`;`) como delimitador. Use o script PowerShell fornecido para importar os arquivos CSV para o Microsoft Planner.


