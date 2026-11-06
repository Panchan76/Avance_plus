# Avance+ — perfil, catálogo e assistente offline

Este pacote substitui a atualização anterior de perfil/CNPJ/IA por uma versão sem consulta de CNPJ e sem API de inteligência artificial. Pode ser aplicado diretamente sobre o projeto com conversas e agenda, mesmo que você não tenha aplicado o pacote anterior.

## O que foi mantido

- Edição de nome, telefone, cidade e e-mail de contato no Perfil. O e-mail de login é mantido; currículo e histórico de conversas são separados.
- Seleção e remoção de foto no Perfil, usando Firebase Storage. JPG/PNG/WebP até 5 MB. A foto é privada ao proprietário e não aparece nos currículos.
- Configurações com letras maiores e recuperação de senha por e-mail para contas com senha.
- Ajuda com perguntas frequentes e acesso ao assistente.
- Catálogo com Enviar currículo e indicação Currículo enviado. Edição em Perfil > Currículo. Máximo de 5 cargos.
- Conversas, agenda e aprovação administrativa de cargos, como na versão anterior.

## O que foi retirado

- Consulta oficial de CNPJ e dependência do Serpro.
- Bloqueio de empresas por falta de verificação e unicidade de CNPJ.
- Cloud Functions, chave de API e chamada à OpenAI para o assistente.

O campo CNPJ continua no cadastro como informação declarada pela empresa, sem validação externa ou certificação. As regras impedem o cliente de inventar campos de certificação. Dados de verificação existentes não são apagados, mas não são mais usados para liberar acesso nem mostrados como certificado na interface.

## Como funciona o assistente

É um chatbot básico determinístico, escrito em Dart. Identifica temas por palavras/expressões e responde com orientações preparadas. Não é um modelo generativo, não aprende sozinho e não responde a qualquer assunto.

Funciona sem internet e sem custo por mensagem. Não precisa de API, servidor, chave, download de modelo ou biblioteca de IA. O histórico fica somente na memória da tela; sair da aba pode limpá-lo. As mensagens não são enviadas ao Firebase nem a terceiros pelo assistente.

Exemplos:

- “Como enviar currículo?”
- “Montar currículo”
- “Preparar entrevista”
- “Quero remarcar minha entrevista”
- “Como mudar minha foto?”
- “Aumentar as letras”
- “A empresa pediu pagamento por Pix”

Para montar um rascunho, envie um campo por linha:

```text
Objetivo: jardinagem
Experiência: cuidei do jardim de casa e ajudei vizinhos
Habilidades: poda e cuidados com plantas
```

O bot organiza somente o texto informado e marca o que estiver faltando. Não inventa tempo de experiência e não salva ou envia o currículo. Também não consulta nem altera a agenda, não envia notificações e não conversa com outras pessoas. Se não reconhecer a pergunta, oferece os temas disponíveis.

Para ampliar respostas, edite `lib/features/chatbot/domain/services/assistant_engine.dart`. Um modelo de linguagem local seria outro projeto: esta versão não inclui um LLM.

## Instalar no projeto atual

1. Faça uma cópia da pasta `avance_plus` atual.
2. Copie o conteúdo da pasta `avance_plus` deste ZIP para dentro do seu projeto. Mescle as pastas e substitua os arquivos de mesmo caminho, preservando o restante. Se fez mudanças próprias desde nosso último pacote, compare esses arquivos primeiro.
3. Na pasta do projeto, execute:

```powershell
flutter pub add image_picker
flutter pub get
flutter analyze
flutter test test/assistant_engine_test.dart
```

A dependência `firebase_storage` já existia no projeto. Não é necessário adicionar `cloud_functions` para esta versão. O ZIP não substitui seu pubspec.yaml nem os arquivos de build Android.

## Publicar regras

Para o cadastro empresarial e a edição de perfil funcionarem, publique as regras incluídas:

```powershell
firebase deploy --only firestore:rules --project avanceplus-36d4d
```

Para salvar fotos, mantenha o Firebase Storage configurado e publique também:

```powershell
firebase deploy --only storage --project avanceplus-36d4d
```

Não há funções novas para publicar e nenhuma chave para configurar. O índice de currículos existente não muda.

**O assistente é gratuito e offline; o restante do aplicativo continua usando Firebase.** Especialmente o upload de fotos no Storage exige um projeto no plano Blaze conforme as condições atuais do Firebase. Esta atualização não muda seu plano de faturamento. Se o Storage não estiver habilitado, o assistente e as demais funções independentes dele continuam funcionando; o envio de foto mostrará erro.

Na versão web, se houver erro CORS ao carregar fotos, o arquivo `storage.cors.json` inclui localhost na porta 5000 e os domínios Firebase do projeto. Com o Google Cloud CLI e permissão administrativa:

```powershell
gcloud storage buckets update gs://avanceplus-36d4d.firebasestorage.app --cors-file=storage.cors.json
flutter run -d chrome --web-port 5000
```

Preserve outras origens necessárias se o bucket já tiver CORS personalizado. Para iOS, acrescente a descrição `NSPhotoLibraryUsageDescription` ao Info.plist antes de usar a galeria; os arquivos de iOS não são substituídos neste pacote.

## Se você já aplicou a versão anterior com APIs

- Substitua os arquivos e publique as regras deste pacote para remover o bloqueio por CNPJ.
- A configuração Firebase incluída não possui a seção `functions`. Se você tem outras funções próprias, preserve a seção delas ao mesclar o firebase.json.
- Arquivos antigos `functions/`, `cnpj_validator.dart` e a dependência `cloud_functions` podem permanecer no computador: este app não os chama. Não publique o backend antigo para esta versão.
- Funções que já tenham sido publicadas continuam no servidor até serem removidas. Remover a configuração local não as desativa. Se você publicou especificamente `askAssistant` e `completeCompanyRegistration` do pacote anterior e não as usa em outro lugar, remova essas duas funções no Firebase Console. Não apague funções diferentes nem dados de usuários.
- Nenhum serviço externo foi cancelado automaticamente. Contratos ou credenciais criados anteriormente continuam sob sua conta.

## Testar e gerar APK

Teste edição de dados, foto e letras maiores. No catálogo, envie um currículo existente e confira o estado. Entre com uma empresa sem certificação e confirme o acesso. Verifique conversas e entrevistas nos dois perfis.

Para testar o assistente offline, entre no app enquanto conectado, abra a aba Assistente, desligue a internet e faça as perguntas de exemplo. Login, sincronização e carregamento inicial de outros dados não são garantidos offline.

Depois gere um novo APK:

```powershell
flutter build apk --debug
explorer .\build\app\outputs\flutter-apk
```

Instale o novo `app-debug.apk`. O APK anterior não tem esta atualização.

## Validação

As regras de cadastro/perfil foram atualizadas para permitir empresas sem consulta externa, preservando proteção de perfil, currículo, mensagens e entrevistas. Testes de regras estão em `tests/`; testes Flutter do assistente em `test/assistant_engine_test.dart`.

A sintaxe Dart e os imports foram verificados. Os testes de regras Firestore foram executados no emulador. Flutter SDK não está disponível neste ambiente: os testes Flutter, `flutter analyze`, a compilação e a interface precisam ser verificados na sua máquina. As regras e o código de fotos foram preservados da versão anterior, cujas regras Storage já foram testadas no emulador.

Documentação sobre Storage e faturamento: https://firebase.google.com/docs/storage/faqs-storage-changes-announced-sept-2024
