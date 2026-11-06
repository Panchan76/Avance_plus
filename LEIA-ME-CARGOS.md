# Avance+ — cargos aprovados, currículos e consulta pelas empresas

Aplicar sobre o projeto que já está funcionando com login por e-mail/Google e o ajuste da posição do botão Google. Este ZIP é uma atualização de arquivos, não um projeto Flutter completo.

## O que esta etapa entrega

- Catálogo inicial: Carpinteiro, Jardineiro, Cozinheiro, Costureiro, Recepcionista e Artesão.
- Empresas solicitam cargos adicionais e acompanham a situação: aguardando aprovação, aprovado ou não aprovado.
- Apenas a administração aprova ou rejeita, usando o console Firebase. A empresa não tem permissão de alterar o status nem o próprio tipo de conta.
- Um cargo aprovado entra no catálogo geral. Ele não pertence exclusivamente à empresa que o solicitou.
- Candidato preenche e edita seu currículo dentro do app, com nome, contatos, cidade, apresentação, experiência, formação e habilidades.
- Um currículo pode estar vinculado a até cinco cargos. Para alterar os cargos, basta editar e salvar novamente.
- Candidato escolhe se disponibiliza o currículo às empresas ou o mantém privado. A opção começa desativada.
- Empresas escolhem um cargo, consultam os currículos disponíveis e copiam os contatos para combinar uma entrevista externamente.
- Tela inicial e textos principais do assistente local foram adaptados para o fluxo de cargos.

O currículo desta etapa é preenchido em formulário. Ainda não há upload de PDF, chat entre usuários, convite de entrevista, agenda ou notificações. Esses recursos ficam para a próxima etapa do fluxo discutido. O assistente continua sendo o classificador local existente, com orientações ajustadas; não analisa uma agenda ainda.

## 1. Aplicar os arquivos

Faça uma cópia de segurança. Copie o conteúdo da pasta `avance_plus` deste ZIP para a raiz do projeto, mesclando as pastas e substituindo os arquivos correspondentes. Não apague `lib` inteira.

Não há nova dependência Flutter. Os arquivos das telas de autenticação e do botão Google não são substituídos por este pacote.

O pacote contém `firebase.json`, `firestore.rules` e `firestore.indexes.json`. Como você informou que não fez outras alterações no projeto, eles foram preparados a partir da versão anterior. Caso você tenha outras regras ou índices próprios, integre-os antes de publicar; não descarte configurações em uso.

## 2. Publicar regras e índice

Com Firebase CLI instalado e autenticado, execute na raiz:

```bash
firebase login
firebase deploy --only firestore:rules,firestore:indexes --project avanceplus-36d4d
```

Essa publicação é necessária: as regras anteriores bloqueiam as novas coleções. O comando publica apenas regras/índices do Firestore, não o site nem o app.

Espere o índice de `resumes` ficar pronto antes de testar a consulta de candidatos. A construção pode levar alguns minutos.

Alternativa pelo console:

1. Em Firestore Database → Regras, substitua pelas regras deste pacote e publique.
2. Em Índices → Compostos, crie um índice para a coleção `resumes`, escopo Collection, com os campos `shared` Ascending e `roleIds` Array contains.
3. Aguarde o índice indicar que está pronto.

O índice permite consultar currículos com `shared == true` e o cargo selecionado no campo `roleIds`.

## 3. Executar o app

```bash
flutter analyze
flutter run
```

Candidato: abra **Cargos**, escolha uma profissão e toque **Vincular meu currículo**. Complete os campos, marque os cargos e ative a divulgação se quiser aparecer para empresas. Salve. Também é possível acessar por Início → Meu currículo ou Perfil → Currículo.

Empresa: abra **Solicitar** para pedir um cargo novo; use **Candidatos** para consultar pessoas por cargo. O catálogo aprovado fica na aba **Cargos**.

Se o candidato já tiver cinco cargos, ao abrir outro cargo ele precisará desmarcar um e selecionar o novo antes de salvar.

## 4. Aprovar ou rejeitar um cargo

A administração usa o console do projeto com uma conta que tenha permissão de editar o Firestore. Não há senha de administrador embutida nem painel de aprovação dentro do app nesta entrega.

1. No Firebase, abra Firestore Database → Dados → `career_roles`.
2. Encontre o pedido cujo campo `status` é `pending`.
3. Confira `title`, `description` e `requestedBy` (UID da empresa). Verifique se já existe cargo equivalente no catálogo para evitar duplicação.
4. Para aprovar, altere o valor string de `status` para **`approved`** e salve.
5. Para rejeitar, altere-o para **`rejected`**. Opcionalmente, acrescente `reviewNote` do tipo string, explicando o motivo. A empresa verá essa observação.

Use os valores exatamente como escritos, em inglês. Não renomeie campos nem remova `requestedBy`, `title` ou `description`. Não é necessário criar outro documento: o mesmo pedido aprovado vira uma entrada do catálogo.

Os seis cargos iniciais estão definidos no código (`CatalogService.initialRoles`) e são reconhecidos pelas regras; não precisam ser cadastrados manualmente no Firestore. Não crie documentos adicionais para duplicá-los. Para alterar essa lista inicial no futuro, mantenha o código e a lista `initialRole()` nas regras sincronizados.

## Dados e acesso

| Caminho | Finalidade | Acesso pelo app |
| --- | --- | --- |
| `users/{uid}` | Perfil de autenticação já existente | Leitura pelo próprio usuário; tipo de conta imutável |
| `career_roles/{id}` | Pedido de cargo e estado da aprovação | Empresa cria pendente e vê seus pedidos; aprovados aparecem a usuários autenticados |
| `resumes/{uid}` | Currículo e cargos escolhidos | Candidato edita o próprio; empresas consultam somente currículos disponibilizados |

O perfil `users` continua privado. Os contatos profissionais que o candidato decide divulgar ficam em `resumes`. Desativar a divulgação e salvar retira o currículo das consultas futuras; isso não apaga contatos que uma empresa já tenha copiado.

O tipo “empresa” ainda é autodeclarado no cadastro. Esta etapa aprova cargos, não verifica a identidade jurídica de cada empresa. Os textos de consentimento dizem “empresas cadastradas”, sem sugerir uma verificação inexistente.

## Teste de aceitação

1. Entre como empresa e peça um cargo que não esteja no catálogo. Verifique “Aguardando aprovação”.
2. Entre como candidato: esse pedido ainda não deve aparecer.
3. Aprove o pedido no console. Verifique que aparece para candidato e empresa.
4. Envie outro pedido e rejeite com `reviewNote`. A empresa deve ver a decisão e a observação; ele não deve aparecer no catálogo.
5. Como candidato, preencha um currículo, selecione Jardineiro e salve sem divulgar: a empresa não deve encontrá-lo.
6. Ative a divulgação e salve. Na empresa, selecione Jardineiro em Candidatos, expanda o currículo e confira os contatos.
7. Altere experiência/contatos e salve. A consulta da empresa deve refletir as alterações.
8. Desative a divulgação e salve. O currículo deve sair da consulta da empresa.
9. Confira que e-mail/Google, sessão e botão de sair continuam funcionando.

## Verificação feita

- Os 10 arquivos Dart passaram por análise sintática com tree-sitter; imports locais resolvidos contra o projeto e as atualizações anteriores.
- JSON de configuração e índices validado.
- Testes reais no emulador Firestore passaram para criação pendente, bloqueio de autoaprovação, restrição de pedidos privados, consultas de cargos aprovados, isolamento de currículos, bloqueio de alteração de tipo de conta, recusa de cargos pendentes/inexistentes e retirada de divulgação.
- Os testes carregam explicitamente o conteúdo de `firestore.rules` no ambiente de teste. Não usaram o Firebase de produção.
- Flutter/Dart não está instalado neste ambiente: análise de tipos, compilação e aparência das telas ainda precisam ser verificadas no seu computador. O emulador não verifica a construção dos índices de produção.

Para repetir os testes locais de regras, com Node e Java instalados:

```bash
cd tests
npm install
npm test
```

As dependências JavaScript são apenas ferramentas locais de teste; não são dependências do aplicativo. O teste usa o projeto fictício `demo-avance-catalog` e porta 8089, nunca o projeto real.

Referências:
- https://firebase.google.com/docs/firestore/security/rules-query
- https://firebase.google.com/docs/firestore/security/rules-conditions
- https://firebase.google.com/docs/firestore/query-data/queries
