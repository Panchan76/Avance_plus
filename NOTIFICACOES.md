# Notificações do Avance+

O Avance+ utiliza notificações em tempo real dentro do próprio aplicativo, sem Firebase Cloud Messaging, Cloud Functions ou plano Blaze.

## Como funciona

- O aplicativo acompanha as conversas e mensagens do usuário enquanto a sessão está aberta.
- Novas mensagens recebidas geram um aviso flutuante com o nome de quem enviou e um resumo da mensagem.
- Convites e alterações de entrevistas geram avisos.
- Empresas recebem avisos quando um currículo é disponibilizado.
- Candidatos recebem avisos quando um cargo que selecionaram é aprovado e disponibilizado.
- Empresas recebem o resultado da análise de cargos que solicitaram.
- A aba **Avisos** reúne os avisos recebidos durante a sessão e permite marcá-los como lidos.

## Limitações intencionais

- Os avisos são mantidos em memória. Ao fechar ou reiniciar o aplicativo, a lista local é reiniciada.
- Não há popup quando o aplicativo está fechado ou em segundo plano.
- Não há notificações push, som ou alerta nativo do sistema operacional.
- Não é necessário cadastrar cartão, ativar o plano Blaze ou fazer deploy de Cloud Functions.

## Executar

Na pasta do projeto Flutter:

```bash
flutter pub get
flutter run
```

Não execute `firebase deploy --only functions`: esta versão não utiliza Cloud Functions.
