
import 'package:flutter/material.dart';
import 'notification_service.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({
    super.key,
    required this.company,
  });

  final bool company;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: StreamBuilder<List<AppNotification>>(
      stream: NotificationRepository.instance.watchNotifications(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Não foi possível carregar os avisos. ${snapshot.error}',
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final notifications = snapshot.data!;
        final unread = notifications.where((item) => !item.isRead).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Avisos',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  if (unread.isNotEmpty)
                    TextButton(
                      onPressed: () => NotificationRepository.instance
                          .markAllRead(unread.map((item) => item.id).toList()),
                      child: const Text('Marcar todas como lidas'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Text(
                        company
                            ? 'Você ainda não recebeu avisos sobre candidatos ou entrevistas.'
                            : 'Você ainda não recebeu avisos sobre mensagens ou entrevistas.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        final date = item.createdAt?.toLocal();

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.isRead
                                ? Theme.of(context).colorScheme.surfaceContainerHighest
                                : Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              _iconFor(item.data['type'] as String?),
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                          subtitle: Text([
                            if (item.body.isNotEmpty) item.body,
                            if (date != null)
                              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                          ].join('\n')),
                          isThreeLine: item.body.isNotEmpty && date != null,
                          trailing: item.isRead
                              ? null
                              : const Icon(Icons.circle, size: 10),
                          onTap: item.isRead
                              ? null
                              : () => NotificationRepository.instance.markRead(item.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    ),
  );

  IconData _iconFor(String? type) {
    switch (type) {
      case 'message':
        return Icons.chat_bubble_outline;
      case 'interview':
      case 'interview_update':
        return Icons.calendar_month_outlined;
      case 'job_approved':
        return Icons.work_outline;
      default:
        return Icons.notifications_none;
    }
  }
}
