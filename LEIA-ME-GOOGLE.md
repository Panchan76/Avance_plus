# Avance+ — criar conta e entrar com Google

Esta atualização é para o projeto que já está funcionando com o pacote de login/cadastro anterior. Contém apenas sete arquivos Dart novos/alterados e este guia. Não é um projeto completo.

## Como funciona

O botão **Continuar com Google** aparece na tela inicial, no login e nos dois cadastros. Ele serve tanto para criar uma conta quanto para entrar.

- Primeiro acesso: autentica com Google, preenche o nome disponível e pede o tipo de perfil (candidato ou empresa). Empresas também informam o CNPJ. Ao salvar, cria `users/{uid}`.
- Acessos seguintes: recupera o mesmo perfil e abre sua área diretamente.
- Login por e-mail e senha permanece disponível.
- O app pede apenas autenticação: não acessa Gmail, Drive ou contatos.
- O app não armazena a senha do Google nem grava tokens no Firestore.

## 1. Copiar os arquivos e adicionar a dependência

Faça uma cópia de segurança do projeto. Copie a pasta `lib` deste ZIP para a raiz do projeto existente, mesclando as pastas e substituindo os arquivos correspondentes. Não apague a pasta `lib` inteira. Se você fez alterações próprias nos mesmos arquivos após o pacote anterior, compare antes de substituir.

Na raiz, execute:

```bash
flutter pub add "google_sign_in:^7.2.0"
```

Isso adiciona `google_sign_in` às dependências do seu `pubspec.yaml` e resolve os pacotes. O código usa a API 7.x (`GoogleSignIn.instance`, `initialize()` e `authenticate()`), não a API 6.x.

## 2. Ativar o Google no Firebase

No console https://console.firebase.google.com/, selecione **avanceplus-36d4d**.

1. Acesse **Authentication → Sign-in method / Método de login**.
2. Abra o provedor **Google** e ative.
3. Selecione o e-mail de suporte solicitado pelo console e salve.

As regras do Firestore do pacote anterior continuam válidas. Não é necessário republicá-las nem criar outra coleção.

## 3. Android: cadastrar assinatura e atualizar configuração

O `google-services.json` do RAR original estava sem entradas OAuth. Para Google funcionar no Android, baixe um arquivo atualizado depois de ativar o provedor e cadastrar a assinatura.

No terminal PowerShell do Windows, a partir da raiz:

```powershell
cd android
.\gradlew.bat signingReport
cd ..
```

Em macOS/Linux:

```bash
cd android
./gradlew signingReport
cd ..
```

No relatório, localize a variante `debug` usada em desenvolvimento e copie SHA-1 e SHA-256. Não use impressões digitais de outro computador.

No Firebase, abra **Configurações do projeto → Geral → Seus aplicativos → Android**. No projeto enviado, o pacote Android é **com.example.avance_plus**. Adicione as impressões digitais e salve.

Baixe novamente o `google-services.json` desse aplicativo e substitua:

```text
android/app/google-services.json
```

O plugin Google Services já está aplicado no Gradle do projeto. O novo JSON precisa conter um cliente OAuth web (`client_type: 3`); assim `GoogleSignIn.initialize()` obtém a configuração sem IDs fixos no Dart. Se ele ainda estiver ausente, confira o provedor Google e os clientes OAuth do projeto, seguindo a documentação oficial abaixo.

Para uma versão assinada de distribuição, cadastre também as assinaturas correspondentes. Se usar Play App Signing, inclua a assinatura fornecida pelo Google Play para o app distribuído.

Depois de mudar a configuração nativa, encerre o app e faça uma nova execução completa; hot reload não basta.

## 4. Web: autorizar o domínio

Em **Authentication → Settings / Configurações → Authorized domains / Domínios autorizados**, confira o domínio onde o app roda. Adicione `localhost` se estiver ausente para teste local e o domínio real quando publicar.

Execute:

```bash
flutter run -d chrome
```

No navegador, a implementação usa `FirebaseAuth.signInWithPopup(GoogleAuthProvider())`. Permita o popup do Google se o navegador bloquear. Não é necessário inicializar `google_sign_in_web` nem adicionar um client ID ao HTML para este fluxo via Firebase.

Teste em navegador normal; navegadores embutidos podem restringir o login OAuth.

## 5. iPhone/iPad e macOS, se você usar essas plataformas

É necessário configurar os valores OAuth do seu aplicativo Apple. Eles não estavam disponíveis no material enviado, portanto não foram inventados nem inseridos no projeto.

Após ativar Google, baixe o `GoogleService-Info.plist` atualizado da aplicação Apple correta no Firebase e consulte os valores `CLIENT_ID` e `REVERSED_CLIENT_ID`. Para configurar o plugin, copie esses valores para `ios/Runner/Info.plist`, dentro do dicionário principal:

```xml
<key>GIDClientID</key>
<string>VALOR_DE_CLIENT_ID</string>
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>VALOR_DE_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

Substitua os dois marcadores pelos valores reais. Se `CFBundleURLTypes` já existir, acrescente o dicionário à lista existente; não duplique a chave nem remova outros esquemas.

No macOS, aplique os valores ao `macos/Runner/Info.plist` da aplicação correspondente e habilite Keychain Sharing conforme a documentação do plugin:

```xml
<key>keychain-access-groups</key>
<array>
  <string>$(AppIdentifierPrefix)com.google.GIDSignIn</string>
</array>
```

A configuração Apple não foi executada neste ambiente. Windows e Linux nativos não têm botão Google nesta entrega, pois não são suportados pelo plugin oficial utilizado; no computador, use a versão web.

## 6. Conferir e executar

Na raiz do projeto:

```bash
flutter analyze
flutter run
```

Teste:

1. Toque em Continuar com Google usando uma conta nova. Conclua como candidato e confirme o nome/e-mail no perfil.
2. Confira o usuário no Authentication e `users/{uid}` no Firestore.
3. Saia e entre novamente com o mesmo Google: deve abrir a área sem pedir o perfil outra vez.
4. Use outra conta Google para testar empresa e CNPJ.
5. Cancele a seleção de conta: o app deve liberar os botões novamente.
6. Confira que login e recuperação por e-mail continuam disponíveis.
7. Feche e reabra o app autenticado; a sessão anterior deve ser restaurada.
8. Teste o fluxo Android no dispositivo/emulador e o web no Chrome, conforme as plataformas utilizadas.

Se o mesmo e-mail já tiver cadastro, a associação segue o comportamento do Firebase para provedores confiáveis. Esta atualização não implementa uma tela para vinculação manual de provedores. Se ocorrer `account-exists-with-different-credential`, o app pede acesso pelo método original. Não crie outro documento de perfil nem troque seu UID para tentar contornar o conflito.

## Erros comuns

- **operation-not-allowed:** ative Google no Authentication.
- **unauthorized-domain:** autorize o domínio em uso no Firebase.
- **popup-blocked:** permita a janela de autenticação e tente de novo.
- **clientConfigurationError / serverClientId:** confira JSON atualizado, cliente OAuth web e configuração nativa.
- **Cancelamento logo depois de selecionar uma conta no Android:** também pode indicar configuração de SHA ou OAuth incorreta. O SDK nem sempre distingue essa falha de um cancelamento real.
- **permission-denied ao concluir perfil:** confira as regras de `users/{uid}` e eventual exigência de App Check.
- **Inicialização Google continua falhando depois de ajustar configuração:** pare e reabra o app; a inicialização do plugin ocorre uma única vez por execução.

## Arquivos

- `lib/features/auth/data/auth_service.dart`: autenticação Google web/nativa, saída e mensagens de erro.
- `lib/features/auth/presentation/widgets/google_sign_in_button.dart`: botão compartilhado e proteção contra envios repetidos.
- `lib/features/auth/presentation/pages/welcome_page.dart`: botão inicial e rolagem para telas menores.
- `lib/features/auth/presentation/pages/login_page.dart`: opção Google no login.
- `lib/features/auth/presentation/pages/candidate_signup_page.dart`: opção Google no cadastro.
- `lib/features/auth/presentation/pages/company_signup_page.dart`: opção Google no cadastro de empresa.
- `lib/features/auth/presentation/pages/complete_profile_page.dart`: nome sugerido pela conta Google e escolha do perfil.

## Validação e limites

Os sete arquivos Dart foram analisados sintaticamente com tree-sitter, sem erros, e seus imports locais foram conferidos contra o projeto e a atualização anterior. Não há Flutter/Dart instalado neste ambiente, portanto não foi possível fazer análise de tipos, compilar ou testar OAuth real. A configuração do provedor, assinaturas e domínios precisa ser feita no seu console. Não foram criados clientes OAuth, alteradas configurações remotas nem criadas contas de teste por esta entrega.

Referências oficiais:
- https://firebase.google.com/docs/auth/flutter/federated-auth
- https://pub.dev/packages/google_sign_in
- https://pub.dev/packages/google_sign_in_android
- https://pub.dev/packages/google_sign_in_ios
- https://firebase.google.com/docs/auth/android/google-signin
- https://firebase.google.com/docs/auth/web/google-signin
