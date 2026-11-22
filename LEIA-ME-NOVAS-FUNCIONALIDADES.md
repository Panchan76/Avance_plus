# Atualização Avance+ — público 60+, avisos locais e área da empresa

## Alterações
- Removido o atalho de assistente/IA da área de Perfil da empresa e da tela de Ajuda da empresa. A área de candidato continua com o assistente.
- Cadastro de candidato exige data de nascimento e idade mínima de 60 anos. A validação é feita no formulário, no serviço de autenticação e nas regras do Firestore.
- Criada a aba **Avisos** para empresas e candidatos, com contador de avisos não lidos e ação para marcar como lidos.
- Os avisos são recebidos em tempo real por listeners do Firestore enquanto o aplicativo está aberto. Não utilizam Firebase Cloud Messaging nem Cloud Functions.

## Situações com aviso
- Empresa inicia uma conversa com candidato.
- Chega uma nova mensagem de outra pessoa.
- É criado ou atualizado um convite de entrevista.
- Um candidato disponibiliza o currículo para as empresas.
- Um cargo selecionado pelo candidato é aprovado e disponibilizado.
- Uma solicitação de cargo feita pela empresa é aprovada ou recusada.

## Limitações
- A lista de avisos é mantida em memória e reinicia quando o aplicativo é fechado.
- Não há notificações push, alertas do sistema operacional ou avisos com o app fechado/em segundo plano.
- Não é necessário cadastrar cartão, ativar o plano Blaze ou publicar Cloud Functions para esses avisos.

## Aplicar e testar
1. Faça backup do projeto e mescle os arquivos deste pacote na raiz do projeto Flutter.
2. Execute `flutter pub get`.
3. Execute `flutter analyze` e `flutter run`.
4. Entre com uma conta de candidato e outra de empresa em dois dispositivos/navegadores e mantenha ambos os aplicativos abertos.
5. Teste uma nova conversa, uma mensagem, um convite/alteração de entrevista e o compartilhamento de currículo. Confira os popups e a aba Avisos.

A validação de idade usa a data de nascimento informada e não substitui verificação documental de identidade. Os avisos não criam documentos na coleção `users/{uid}/notifications`; eles são locais à sessão do aplicativo.
