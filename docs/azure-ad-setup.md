## Índice

- [Visão Geral](#visao-geral)
- [Configuração do Aplicativo no Azure AD](./azure-ad-setup.md)
    - [Acesse o Portal do Azure](#1-acessar-o-portal-do-azure)
    - [Crie um novo App Registration](#2-criar-um-novo-app-registration)
    - [Configurar as Permissões de API (Microsoft Graph)](#3-configurar-as-permissoes-de-api-microsoft-graph)
    - [Adicionar Permissões (Scope) do Microsoft Graph](#4-adicionar-permissoes-scope-do-microsoft-graph)
    - [Conceder Permissões](#5-conceder-permissoes)
    - [Gerar Client Secret](#6-gerar-client-secret)
- [Preparando o Arquivo CSV](./csv-templates.md)
- [Modelos de Planos em CSV](./csv-templates.md)
- [Parâmetros do Script](./script-parameters.md)
- [Contribuições](./contributing.md)

<br>


# Configuração do Aplicativo no Azure AD

Para executar o script, você precisará configurar um aplicativo no Azure AD. Siga os passos abaixo:

## 1. **Acesse o Portal do Azure:**

- [https://portal.azure.com](https://portal.azure.com)

## 2. **Crie um novo App Registration:**

- Vá para "Azure Active Directory" > "App registrations" > "New registration".
- Forneça um nome para o aplicativo e escolha a opção de conta adequada.

## 3. **Configurar as Permissões de API (Microsoft Graph):**

- Após criar o aplicativo, vá para "API permissions".
- Clique em "Add a permission" e selecione "Microsoft Graph".

## 4. **Adicionar Permissões (Scope) do Microsoft Graph:**

- Application Permissions:
    - **Group.ReadWrite.All**
    - **Group.Read.All**
    - **User.Read.All**
    - **Directory.ReadWrite.All**
    - **Tasks.ReadWrite**
    - **Channel.ReadWrite.All**

## 5. **Conceder Permissões:**

- Clique em "Grant admin consent for [tenant]".

## 6. **Gerar Client Secret:**

- Vá para "Certificates & secrets" no menu do aplicativo.
- Em "Client secrets", clique em "New client secret".
- Copie o valor do segredo gerado para uso no script PowerShell.
