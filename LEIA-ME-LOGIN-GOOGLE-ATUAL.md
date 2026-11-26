# Login Google — atualização

Botões na tela inicial e de login, para Android e Web. O AuthGate existente continua verificando o e-mail e encaminhando contas novas para Concluir cadastro. Candidato deve ter 60 anos ou mais; empresa informa CNPJ válido no formulário de conclusão. Contas existentes mantêm o perfil. Não há vinculação manual de provedores.

1. Authentication > Método de login > Google: já ativado conforme print.
2. Authentication > Configurações > Domínios autorizados: confira localhost e o domínio publicado.
3. Android: o JSON enviado contém cliente OAuth web e clientes Android. Confira SHA-1/SHA-256 da assinatura usada; baixe JSON atualizado se necessário.
4. Execute flutter pub get e flutter analyze.
5. Web: flutter run -d chrome --dart-define=RECAPTCHA_SITE_KEY=SUA_CHAVE_COMPLETA
6. Android: flutter build apk --release; instale e teste. App Check continua como antes; debug pode exigir token de depuração cadastrado.
7. Teste conta nova, conta existente, cancelamento, saída e login por senha.

Não alteramos regras Firestore, App Check, dependências nem configurações remotas. Não há Flutter/Dart neste ambiente para compilar ou testar. iOS e desktop nativo não recebem botão nesta atualização. O ícone G é desenhado localmente. O ZIP exclui caches e builds gerados. O guia LEIA-ME-GOOGLE.md anterior é histórico; siga este arquivo.
