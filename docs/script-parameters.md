## Índice

- [Visão Geral](#visao-geral)
- [Configuração do Aplicativo no Azure AD](./azure-ad-setup.md)
- [Preparando o Arquivo CSV](./csv-templates.md)
- [Modelos de Planos em CSV](./csv-templates.md)
- [Contribuições](./contributing.md)

<br>


# Parâmetros do Script

## `-clientID`

- **Tipo:** String
- **Obrigatório:** Sim
- **Descrição:** ID do cliente usado para autenticação no Azure AD.

## `-tenantID`

- **Tipo:** String
- **Obrigatório:** Sim
- **Descrição:** ID do locatário (tenant) usado para autenticação no Azure AD.

## `-clientSecret`

- **Tipo:** String
- **Obrigatório:** Sim
- **Descrição:** Segredo do cliente usado para autenticação no Azure AD.

## `-GroupID`

- **Tipo:** String
- **Obrigatório:** Sim
- **Descrição:** ID do grupo do Microsoft Teams onde o plano e os canais serão criados.

## `-PlanName`

- **Tipo:** String
- **Obrigatório:** Sim
- **Descrição:** Nome do plano que será criado no Microsoft Planner.

## `-csvFilePath`

- **Tipo:** String
- **Obrigatório:** Sim
- **Descrição:** Caminho do arquivo CSV contendo as tarefas e os buckets a serem importados. O CSV deve ter o formato `TaskName;BucketName;Details`.

## `-teamsTabName`

- **Tipo:** String
- **Obrigatório:** Não (Padrão: "Planner")
- **Descrição:** Nome da aba do Teams onde o Planner será adicionado.

## `-channelDisplayName`

- **Tipo:** String
- **Obrigatório:** Não (Padrão: Nome do plano)
- **Descrição:** Nome do canal a ser criado no Teams.

## `-channelDescription`

- **Tipo:** String
- **Obrigatório:** Não (Padrão: "Canal para gerenciamento de tarefas do Planner - PlanName")
- **Descrição:** Descrição do canal a ser criado no Teams.
