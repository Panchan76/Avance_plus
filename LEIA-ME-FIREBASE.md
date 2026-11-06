# Avance+ — login e cadastro com Firebase

Esta atualização foi preparada a partir do avance_plus.rar enviado nesta conversa. É um pacote de atualização: contém apenas arquivos novos ou alterados, não um projeto Flutter completo.

## 1. Aplicar os arquivos

1. Faça uma cópia de segurança do seu projeto.
2. Extraia o ZIP e abra a pasta `avance_plus` contida nele.
3. Copie o conteúdo para a raiz do seu projeto existente, onde está o `pubspec.yaml`.
4. Mescle as pastas e substitua os arquivos com os mesmos nomes. Não apague sua pasta `lib` nem as pastas de plataformas.
5. Se você modificou esses arquivos depois de enviar o RAR, compare suas alterações antes de substituir.

As dependências `firebase_core`, `firebase_auth` e `cloud_firestore` já estão declaradas no seu `pubspec.yaml`. Não é necessário adicionar um pacote para estas funções. O arquivo original exige Dart ^3.12.1; confira `flutter --version` se a resolução de dependências falhar. As versões do seu pubspec foram preservadas e não foram resolvidas neste ambiente.

## 2. Ativar o login no console

Abra https://console.firebase.google.com/ e selecione o projeto **avanceplus-36d4d**, que já está nos arquivos enviados.

Em **Authentication → Primeiros passos / Sign-in method → E-mail/senha**, ative o provedor E-mail/senha e salve. A opção de link de e-mail não é necessária para este fluxo.

Não é necessário criar os usuários manualmente. Eles serão criados pelo formulário do app. Use um e-mail a que você tenha acesso para testar recuperação de senha.

## 3. Preparar o Firestore

Em **Firestore Database**, crie o banco padrão `(default)` se ainda não existir. Use o modo de produção e escolha a localização adequada antes de concluir a criação.

Abra **Regras**, copie o conteúdo do arquivo `firestore.rules` deste pacote e publique.

Estas regras permitem criar e ler apenas o próprio documento `users/{uid}`; não permitem listar outros perfis, alterar o tipo de conta, atualizar ou excluir perfis. As demais coleções ficam bloqueadas nesta etapa. Se você já tem outras regras em uso, integre este bloco de `users` às suas regras e remova permissões genéricas que tornem os perfis públicos: permissões sobrepostas são somadas.

Alternativa, se você já tem o Firebase CLI instalado e autenticado, na raiz do projeto:

```bash
firebase deploy --only firestore:rules --project avanceplus-36d4d
```

O `firebase.json` mantém a configuração Flutter original e aponta para essas regras. Não é preciso criar manualmente a coleção `users`: o cadastro cria o documento.

## 4. Executar

Na raiz do seu projeto:

```bash
flutter pub get
flutter analyze
flutter run
```

Para testar no navegador:

```bash
flutter run -d chrome
```

As opções existentes de Firebase e o `google-services.json` original foram mantidos. A inicialização saiu do arquivo de opções e foi colocada no `main()` assíncrono. O manifesto Android agora declara acesso à internet também para builds de release.

Se você trocar de projeto Firebase ou adicionar plataformas, execute `flutterfire configure` para o projeto desejado. A plataforma Linux não estava configurada no arquivo enviado.

## 5. O que foi implementado

- Cadastro de candidato e empresa com e-mail e senha no Firebase Authentication.
- Perfil privado no Firestore, usando o mesmo UID da conta.
- Login e encaminhamento conforme o campo `role`: `candidate` ou `company`.
- Retomada da sessão por `authStateChanges()` e leitura do perfil no servidor.
- Nome e e-mail reais na área de perfil; CNPJ na área da empresa.
- Botão de sair nas duas áreas.
- Recuperação de senha pelo botão “Esqueci minha senha”, usando o e-mail preenchido.
- Bloqueio de envios repetidos e de voltar durante o envio dos formulários de login/cadastro; mensagens em português.
- Conclusão de perfil quando a conta foi criada, mas a gravação no Firestore falhou ou o app foi fechado.
- Erros de rede/leitura mostram opção de tentar novamente ou sair; um perfil inválido não libera automaticamente a área de candidato.

O cadastro em Authentication e a gravação no Firestore não constituem uma única transação. Por isso, a conta é preservada se houver falha no perfil. Entre com o mesmo e-mail e senha e conclua os dados, sem criar outra conta. A transação de perfil só cria documentos ausentes: uma repetição não sobrescreve o perfil nem troca seu tipo.

Campos de `users/{uid}`:

| Campo | Conteúdo |
| --- | --- |
| uid | UID do Authentication |
| email | E-mail da conta autenticada |
| name | Nome do candidato ou empresa |
| role | candidate ou company |
| cnpj | Apenas empresas; texto informado no formulário |
| createdAt | Data/hora definida pelo servidor |

Senhas não são armazenadas no Firestore. O CNPJ é apenas coletado; não há validação cadastral da empresa nesta entrega. Os dois tipos de perfil são autodeclarados e não representam privilégios administrativos.

## 6. Teste de aceitação no seu projeto

1. Cadastre um candidato com um e-mail novo. Confira a entrada em Authentication → Usuários e o documento `users/{uid}` no Firestore.
2. Confira o nome/e-mail em Perfil. Saia e entre novamente; deve abrir a área de candidato.
3. Repita com outro e-mail como empresa; deve abrir o painel da empresa e exibir seu CNPJ.
4. Feche e reabra o app; a sessão deve ser restaurada e o perfil consultado.
5. Tente senha errada, e-mail já cadastrado, e-mail inválido, senha curta e confirmação diferente. O app deve informar o erro sem liberar acesso.
6. Preencha seu e-mail em Entrar e toque em “Esqueci minha senha”. Confira a caixa de entrada/spam, redefina a senha e entre com a nova senha.
7. Toque rapidamente duas vezes no botão de cadastro: deve haver somente uma solicitação ativa.
8. Para testar recuperação de cadastro em uma conta de teste, crie um usuário de e-mail/senha no console Authentication sem um documento correspondente em `users`. Ao entrar, deve aparecer “Concluir cadastro”. Salve o perfil e confira a área correta.
9. No simulador de regras do Firestore, confira: leitura do próprio perfil permitida; leitura de outro UID e usuário não autenticado negadas; mudança de `role` negada. Faça estes testes com contas de teste.

A autenticação e a consulta inicial do perfil requerem conexão. Se o projeto já exige App Check para Authentication/Firestore, configure os provedores App Check das plataformas antes de testar; este pacote não ativa App Check automaticamente.

## 7. Arquivos principais

- `lib/main.dart`: inicialização e tela de falha de inicialização.
- `lib/firebase_options.dart`: opções preservadas, trecho inválido removido.
- `lib/app/app.dart`: entrada pelo AuthGate.
- `lib/features/auth/data/auth_service.dart`: operações Firebase e tradução de erros.
- `lib/features/auth/presentation/pages/auth_gate.dart`: sessão e seleção da área.
- `lib/features/auth/presentation/pages/complete_profile_page.dart`: recuperação de perfil incompleto.
- `lib/features/auth/presentation/pages/login_page.dart`: login e recuperação de senha.
- `lib/features/auth/presentation/pages/candidate_signup_page.dart`: cadastro de candidato.
- `lib/features/auth/presentation/pages/company_signup_page.dart`: cadastro de empresa.
- `lib/features/auth/presentation/widgets/`: sair da conta e compartilhamento do perfil.
- `lib/features/profile/presentation/pages/profile_page.dart`: dados do candidato e saída.
- `lib/features/company/presentation/pages/company_navigation_page.dart`: dados da empresa e saída.
- `android/app/src/main/AndroidManifest.xml`: permissão de internet.
- `firestore.rules` e `firebase.json`: regras e configuração de publicação.

## Verificação feita nesta entrega

Os 30 arquivos Dart do conjunto original + alterações passaram por análise sintática com tree-sitter, sem erros de sintaxe, e todos os imports locais foram resolvidos. JSON e XML alterados foram validados. Isso não substitui a análise de tipos do Dart nem testes do aplicativo.

Não foi possível executar `flutter analyze`, compilar ou testar autenticação e regras no Firebase: este ambiente não possui Flutter/Dart nem uma sessão administrativa do seu projeto. Execute os passos acima para confirmar a integração real. Não foram criados usuários nem publicadas regras remotamente.

Vagas, candidaturas, edição de perfil e assistente de IA continuam com o comportamento anterior; esta etapa conecta autenticação e criação/leitura de perfis.

Referências oficiais consultadas:
- https://firebase.google.com/docs/flutter/setup
- https://firebase.google.com/docs/auth/flutter/password-auth
- https://firebase.google.com/docs/auth/flutter/manage-users
- https://firebase.google.com/docs/rules/basics
