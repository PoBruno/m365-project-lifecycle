# Script PowerShell para Criar Plano e Canais no Microsoft Teams

## Descrição

Este script em PowerShell automatiza a criação de um Backlog de Projeto no **Microsoft Planner** utilizando dados de um arquivo CSV, a criação de um canal associado ao Time do **Microsoft Teams** e ao provisionamento de uma **biblioteca de arquivos** do **SharePoint**.

Este projeto visa estabelecer uma arquitetura lógica robusta para o gerenciamento de projetos no Microsoft 365.

## Objetivos

- **Consistência:** Garantir que todos os projetos sigam uma estrutura padrão.
- **Agilidade:** Acelerar a criação de novos planos de projeto reutilizando templates existentes.
- **Organização:** Centralizar todos os templates em um repositório.

## Uso Rápido

1. Clone este repositório:
    ```bash
    git clone https://github.com/PoBruno/m365-project-lifecycle.git
    cd m365-project-lifecycle/Scripts/
    ```

2. Configure o aplicativo no Azure AD seguindo [este guia](./docs/azure-ad-setup.md).

3. Prepare seu arquivo CSV com os dados do projeto conforme [este exemplo](./docs/csv-templates.md).
    - Templates de csv na pasta [./script/templates](./script/templates)

4. Execute o script `Create-PlannerAndTeamsChannel.ps1` fornecendo os parâmetros necessários:

    ```powershell
    .\Create-PlannerAndTeamsChannel.ps1 `
        -clientID $clientID `                       # ID do Aplicativo no Azure AD
        -tenantID $tenantID `                       # ID do Tenant no Azure AD
        -clientSecret $clientSecret `               # Client Secret do Aplicativo no Azure AD
        -csvFilePath $csvFilePath `                 # Caminho do arquivo CSV
        -PlanName $PlanName `                       # Nome do Plano
        -GroupID $groupID `                         # ID do Grupo do Time
        [-teamsTabName $teamsTabName] `             # Opcional (Valor Padrão: {"Planner"})
        [-channelDisplayName $channelDisplayName] ` # Opcional (Valor Padrão: {-PlanName})
        [-channelDescription $channelDescription]   # Opcional (Valor Padrão: "Projeto - {-PlanName}")

Para instruções detalhadas, consulte a [documentação completa](./docs/overview.md).

## Contribuições

Leia nosso [guia de contribuição](./docs/contributing.md) para saber como colaborar.

## Licença

Este projeto está licenciado sob a [Licença MIT](./LICENSE.md).

## Autor

[Bruno Gomes](https://github.com/PoBruno)
