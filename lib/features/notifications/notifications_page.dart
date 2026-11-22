import 'package:flutter/material.dart';
import 'notification_service.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String _date(DateTime value) {
    final d = value.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} às ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
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
        if (items.isEmpty) return const Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(Icons.notifications_none, size: 56), SizedBox(height: 12),
            Text('Você ainda não tem avisos.'), SizedBox(height: 6),
            Text('As notificações aparecem enquanto o app está aberto.', textAlign: TextAlign.center)],
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
                child: Icon(item.read ? Icons.notifications_none : Icons.notifications_active_outlined),
              ),
              title: Text(item.title, style: TextStyle(fontWeight: item.read ? FontWeight.normal : FontWeight.bold)),
              subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.body), const SizedBox(height: 4),
                Text(_date(item.createdAt), style: Theme.of(context).textTheme.bodySmall),
              ]),
              onTap: () => NotificationService.instance.markRead(item.id),
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
      return Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        child: const Icon(Icons.notifications_outlined),
      );
    },
  );
}
