# Verificação de e-mail — Avance+

O Firebase Authentication pode criar uma conta com um endereço inventado. Não é possível confirmar a existência de uma caixa postal apenas pelo texto digitado. O acesso só é liberado depois que o usuário abre o link recebido e confirma o e-mail.

## Fluxo
1. Cadastro por e-mail/senha cria a conta e envia um link. O perfil é reservado no Firestore, mas ainda não é um perfil com acesso ativo.
2. AuthGate mostra a tela de confirmação até `emailVerified == true`.
3. Após clicar no link, o usuário seleciona **Já confirmei meu e-mail**. O app atualiza o usuário e o token de autenticação.
4. As regras de Firestore e Storage também bloqueiam acesso a dados protegidos sem `email_verified == true`.
5. O login por Google permanece disponível; contas Google normalmente já possuem e-mail verificado.

## Implantação obrigatória
**Publicar as regras atualizadas** `firestore.rules` e `storage.rules` no projeto Firebase antes de considerar a proteção de dados efetiva. Uma mudança no app local não publica regras automaticamente. Revise o impacto sobre usuários existentes sem e-mail verificado.

## Teste
- Criar conta com endereço real e confirmar o link; conferir acesso.
- Criar conta com endereço inventado; conferir que a tela de confirmação permanece e que o Firestore/Storage bloqueiam os dados protegidos.
- Sair, entrar novamente sem verificar e conferir o bloqueio.
- Testar login Google e usuário existente.
- Executar `flutter pub get`, `flutter analyze` e testes de regras no emulador.

**Observação:** a conta do Firebase Auth e o documento básico de perfil podem existir antes da confirmação; não são ativados para uso. Exclusão automática de contas pendentes exigiria rotina administrativa separada e não foi implementada.
