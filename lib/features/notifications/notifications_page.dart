import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../communication/agenda_page.dart';
import '../communication/communication_service.dart';
import '../communication/conversations_page.dart';
import 'notification_service.dart';

bool _avisosAbertos = false;

/// Abre a tela de Avisos por cima da tela atual (o sino fica no topo do app).
Future<void> openNotifications(BuildContext context) async {
  if (_avisosAbertos) return;
  _avisosAbertos = true;
  try {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const NotificationsPage()),
    );
  } finally {
    _avisosAbertos = false;
  }
}

/// Leva a pessoa até o assunto do aviso: conversa, agenda ou, se não houver
/// destino específico, a lista de avisos.
Future<void> openNotificationTarget(BuildContext context, AppNotification item) async {
  NotificationService.instance.markRead(item.id);
  final company = NotificationService.instance.isCompany;
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  try {
    if ((item.type == 'conversation' || item.type == 'message') && item.conversationId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('conversations').doc(item.conversationId).get();
      final data = doc.data();
      if (data == null) throw StateError('conversa não encontrada');
      await navigator.push(MaterialPageRoute<void>(
        builder: (_) => ChatPage(conversation: Conversation(doc.id, data), company: company)));
      return;
    }
    if (item.type == 'interview') {
      await navigator.push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Agenda')),
          body: AgendaPage(company: company))));
      return;
    }
  } catch (_) {
    messenger.showSnackBar(const SnackBar(
      content: Text('Não foi possível abrir este aviso. Tente pela aba Conversas ou Agenda.')));
    return;
  }
  // Currículo ou cargo: não há uma tela só para isso, então mostra os avisos.
  if (context.mounted) await openNotifications(context);
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String _date(DateTime value) {
    final d = value.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  bool _hasTarget(AppNotification item) =>
      item.type == 'interview' ||
      ((item.type == 'conversation' || item.type == 'message') && item.conversationId != null);

  IconData _icon(AppNotification item) {
    switch (item.type) {
      case 'conversation':
      case 'message':
        return Icons.chat_bubble_outline;
      case 'interview':
        return Icons.event_available_outlined;
      case 'resume':
        return Icons.description_outlined;
      case 'career_role':
        return Icons.work_outline;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Avisos'),
      actions: [
        StreamBuilder<List<AppNotification>>(
          stream: NotificationService.instance.notifications,
          initialData: NotificationService.instance.current,
          builder: (context, snapshot) {
            final unread = (snapshot.data ?? const <AppNotification>[]).any((item) => !item.read);
            return TextButton(
              onPressed: unread ? NotificationService.instance.markAllRead : null,
              child: const Text('Marcar todas como lidas'),
            );
          },
        ),
      ],
    ),
    body: StreamBuilder<List<AppNotification>>(
      stream: NotificationService.instance.notifications,
      initialData: NotificationService.instance.current,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <AppNotification>[];
        if (items.isEmpty) return const Center(child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(Icons.notifications_none, size: 56), SizedBox(height: 12),
              Text('Você ainda não tem avisos.'), SizedBox(height: 6),
              Text('As notificações aparecem enquanto o app está aberto.', textAlign: TextAlign.center)],
          ),
        ));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: item.read ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : Theme.of(context).colorScheme.primaryContainer,
                child: Icon(_icon(item)),
              ),
              title: Text(item.title, style: TextStyle(fontWeight: item.read ? FontWeight.normal : FontWeight.bold)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.body), const SizedBox(height: 4),
                Text(_date(item.createdAt), style: Theme.of(context).textTheme.bodySmall),
              ]),
              trailing: _hasTarget(item) ? const Icon(Icons.chevron_right) : null,
              onTap: () {
                if (_hasTarget(item)) {
                  openNotificationTarget(context, item);
                } else {
                  NotificationService.instance.markRead(item.id);
                }
              },
            );
          },
        );
      },
    ),
  );
}

class NotificationBadgeIcon extends StatelessWidget {
  const NotificationBadgeIcon({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<List<AppNotification>>(
    stream: NotificationService.instance.notifications,
    initialData: NotificationService.instance.current,
    builder: (context, snapshot) {
      final count = (snapshot.data ?? const <AppNotification>[]).where((item) => !item.read).length;
      return Semantics(
        label: count > 0 ? '$count avisos novos' : 'Nenhum aviso novo',
        child: Badge(
          isLabelVisible: count > 0,
          label: Text(count > 99 ? '99+' : '$count'),
          child: const Icon(Icons.notifications_outlined),
        ),
      );
    },
  );
}

/// Sino de Avisos para a barra do topo do app.
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Avisos',
    iconSize: 30,
    onPressed: () => openNotifications(context),
    icon: const NotificationBadgeIcon(),
  );
}
