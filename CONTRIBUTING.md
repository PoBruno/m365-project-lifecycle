1. **Abra uma Issue**
    
    - Antes de começar a trabalhar em uma nova funcionalidade ou correção de bug, abra uma issue para discutir o que você gostaria de mudar.
    - Certifique-se de que não há outra pessoa trabalhando na mesma tarefa para evitar conflitos.

2. **Fork do Repositório**
    
    - Faça um fork do repositório para sua conta GitHub e clone o fork para o seu ambiente local.

        `git clone https://github.com/SEU_USUARIO/nome-do-repositorio.git cd nome-do-repositorio`
        
3. **Crie uma Branch**
    
    - Crie uma branch para trabalhar na sua contribuição.
        ```PowerShell
        git checkout -b MinhaContribuicao
        ```
4. **Implemente as Mudanças**
    
    - Faça as mudanças necessárias no código.
    - Siga as boas práticas de desenvolvimento e documentação.
    - **Dica**: Utilize o [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) para padronizar as mensagens de commit.

        ```PowerShell
        git add . 
        git commit -m "feat: Adiciona nova funcionalidade" 
        git push origin MinhaContribuicao
        ```
5. **Teste suas Mudanças**
    
    - Certifique-se de que o código continua funcionando corretamente.
    - Execute testes locais, se disponíveis.

6. **Envie um Pull Request**
    
    - Faça o commit das suas mudanças e envie um pull request para o repositório principal.
        
    - Lembre-se de incluir uma descrição clara das suas alterações no pull request.
        
        ```PowerShell
        git add . 
        git commit -m "Descrição concisa das mudanças" 
        git push origin MinhaContribuicao
        ```
        
7. **Revisão e Discussão**
    
    - Aguarde feedback e esteja disposto a fazer ajustes conforme necessário.
    - Responda às solicitações de revisão e participe da discussão conforme apropriado.

8. **Aceitação da Contribuição**
    
    - Após a aprovação da sua contribuição, ela será mesclada (merged) ao repositório principal.
    - Parabéns! Sua contribuição foi aceita e agora faz parte do projeto.
    

9. **Agradecimentos**
        
    - Obrigado por contribuir para o projeto! Sua ajuda é muito apreciada.
