# Avance+ — conversas e agenda de entrevistas

Esta atualização deve ser aplicada sobre a versão que já funciona com cargos, currículos, aprovação de cargos e login por e-mail/Google. O ZIP contém os arquivos novos/alterados; não é um projeto Flutter completo.

## Instalação

1. Faça uma cópia de segurança do projeto.
2. Copie o conteúdo da pasta `avance_plus` deste ZIP para a raiz do projeto existente, mesclando as pastas e substituindo os arquivos correspondentes. Não apague a pasta `lib` inteira.
3. Publique as regras atualizadas no Firebase. As regras anteriores ainda não permitem conversas e entrevistas.

Na raiz do projeto, com Firebase CLI instalado e autenticado:

```bash
firebase deploy --only firestore:rules --project avanceplus-36d4d
flutter analyze
flutter run
```

Alternativa: abra Firebase → Firestore Database → Regras, copie o conteúdo completo de `firestore.rules` e publique. O arquivo preserva as regras de usuários, cargos e currículos da entrega anterior.

Não há nova dependência Flutter. Não são necessários novos índices compostos para conversas e entrevistas: as consultas usam o UID do participante, e as listas são ordenadas no app. O índice de `resumes` continua sendo o mesmo já configurado; o arquivo de índices incluído é usado também pelos testes locais.

Se você tiver alterado regras ou arquivos por conta própria desde a última versão, compare as alterações antes de substituí-los. Não precisa criar coleções manualmente: elas surgem ao usar os recursos.

## Navegação

Para manter cinco opções na barra inferior:

| Candidato | Empresa |
| --- | --- |
| Cargos | Cargos |
| Conversas | Candidatos |
| Agenda | Conversas |
| Assistente | Agenda |
| Perfil | Perfil |

A tela inicial do candidato passa a ser o catálogo de cargos. A solicitação de cargos da empresa fica no botão **Solicitar novo cargo / acompanhar pedidos**, dentro de Cargos. A aprovação administrativa continua no console, como antes.

## Conversas

1. A empresa abre **Candidatos**, escolhe um cargo e expande um currículo.
2. Toca em **Conversar** para abrir o chat.
3. O candidato encontra essa empresa na aba **Conversas** e pode responder.
4. Mensagens aparecem em tempo real quando as telas estão abertas e conectadas.

Cada par empresa/candidato usa uma única conversa, independentemente do cargo em que se encontraram. A lista é ordenada pela atividade recente. O histórico começa pelas últimas 50 mensagens, com a opção de carregar anteriores.

Somente os dois participantes podem ler a conversa e enviar mensagens. O remetente precisa ser o usuário autenticado. Mensagens não podem ser editadas ou apagadas pelo cliente nesta versão.

Novas conversas só podem ser iniciadas com candidatos que disponibilizaram o currículo. Retirar a divulgação impede novos contatos pelo catálogo, mas preserva conversas e entrevistas já existentes. Esta versão não inclui bloqueio de contatos, anexos, confirmação de leitura nem notificação push de mensagens.

## Marcar entrevista

Dentro da conversa, a empresa toca em **Marcar entrevista** e informa:

- Título ou cargo da entrevista.
- Endereço presencial ou link de reunião.
- Data e horário futuros.
- Duração estimada.

Ao tocar **Enviar convite**, a entrevista aparece na Agenda de ambos como **Aguardando candidato**. Não é criada uma confirmação automática de presença.

O botão **Ver entrevistas** mostra apenas as entrevistas daquela conversa. A aba Agenda mostra as entrevistas de todas as conversas do usuário.

## Respostas e mudanças de horário

| Ação | Resultado |
| --- | --- |
| Candidato confirma um convite pendente | Entrevista confirmada |
| Candidato pede alteração e escolhe outra data/hora | Nova data aguardando empresa |
| Empresa confirma a data sugerida | A nova data passa a ser a data confirmada |
| Empresa propõe outro horário | Volta a aguardar a confirmação do candidato |
| Candidato recusa ou avisa que não poderá comparecer | Recusada pelo candidato |
| Empresa cancela | Cancelada pela empresa |

A empresa não pode confirmar um convite inicial em nome do candidato. O candidato não pode confirmar sozinho a própria proposta de remarcação. Se a empresa mudar o horário de uma entrevista já confirmada, será necessário confirmar a presença novamente.

Convites recusados ou cancelados permanecem no histórico e não podem ser reabertos. Se necessário, a empresa pode criar um novo convite na conversa.

As atualizações usam transações e uma revisão incremental: se o convite for alterado enquanto outra pessoa responde, a resposta baseada na versão antiga é recusada e o app pede para conferir os dados atuais.

## Calendário

O calendário está em português. Dias com entrevistas ativas têm uma marcação. Toque no dia para filtrar, ou em **Todas as datas** para listar sem esse filtro.

Por padrão, aparecem as entrevistas ativas de hoje em diante. Ative **Incluir histórico** para consultar convites passados, recusados ou cancelados.

Enquanto houver uma nova data sugerida pelo candidato, o calendário mostra essa data como proposta. Os detalhes também mostram a data anterior e deixam claro que a empresa ainda precisa responder.

Datas são armazenadas como timestamps e exibidas no fuso local do dispositivo. Dois usuários em fusos diferentes verão horários locais equivalentes. Confira o fuso do aparelho ao testar.

Nesta etapa, a agenda não bloqueia automaticamente horários sobrepostos. Não há sincronização com Google Calendar, notificações push, alarmes com o app fechado ou análise automática da agenda por IA. O assistente local recebeu orientações de uso das novas telas; esses outros recursos permanecem para a próxima etapa.

## Teste com duas contas

Use, por exemplo, um navegador normal e uma janela anônima, ou dois dispositivos:

1. Como candidato, disponibilize um currículo em um cargo.
2. Como empresa, abra esse currículo e toque Conversar. Envie uma mensagem.
3. No candidato, abra Conversas e responda. Confira que as mensagens aparecem nos dois lados.
4. Na empresa, marque uma entrevista futura. No candidato, confira o convite na Agenda.
5. Confirme presença. Confira o status Confirmada na empresa.
6. No candidato, peça alteração e sugira outro dia/horário.
7. Na empresa, confirme a sugestão. Confira a nova data nos dois calendários.
8. Proponha outro horário como empresa. O candidato deve precisar confirmar novamente.
9. Teste Recusar em outro convite e Cancelar como empresa.
10. Saia e entre de novo; confira a persistência das conversas e entrevistas.
11. Confira que outra empresa ou outro candidato não tem acesso a essas conversas.
12. Confira que cadastro, login, catálogo e aprovação de cargos continuam funcionando.

## Arquivos principais

- `lib/features/communication/communication_service.dart`: dados, chat e transições de entrevistas.
- `lib/features/communication/conversations_page.dart`: lista de conversas, chat e botão para iniciar contato.
- `lib/features/communication/calendar_grid.dart`: calendário e escolha de data/hora.
- `lib/features/communication/agenda_page.dart`: agenda, detalhes e respostas.
- `lib/features/communication/interview_editor.dart`: convite e proposta de novo horário.
- Navegação do candidato e da empresa: novas abas.
- Catálogo da empresa: acesso às solicitações e botão Conversar no currículo.
- Assistente local: orientações sobre conversas e agenda.
- `firestore.rules`: privacidade e permissões das ações.

As coleções novas são `conversations`, `conversations/{id}/messages` e `interviews`. Os nomes de empresa e candidato são registrados como identificação da conversa; mudanças posteriores no currículo não renomeiam conversas antigas automaticamente.

## Verificação e testes locais

As regras de cargos/currículos e de comunicação foram testadas no emulador Firestore. A suíte inclui privacidade entre contas, identidade do remetente, bloqueio de autoaprovação de cargos, criação de convites, confirmação, remarcação, contraproposta, recusa, cancelamento, versões antigas e estados encerrados.

Para repetir, com Node e Java instalados:

```bash
cd tests
npm install
npm test
```

O teste usa apenas o projeto fictício `demo-avance-catalog`, na porta local 8089. Não publica regras nem grava dados no projeto real. As dependências de teste não são dependências do app.

Os arquivos Dart foram verificados sintaticamente e os imports locais conferidos. Flutter não está instalado neste ambiente: a análise de tipos, a compilação, a aparência e a operação do app ainda precisam ser verificadas no seu computador. Nenhuma regra foi publicada remotamente nesta entrega.
