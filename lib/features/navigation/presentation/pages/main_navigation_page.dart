import 'dart:async';
import 'package:flutter/material.dart';
import '../../../jobs/presentation/pages/jobs_page.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../communication/conversations_page.dart';
import '../../../communication/agenda_page.dart';
import '../../../notifications/notifications_page.dart';
import '../../../notifications/notification_service.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});
  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> with WidgetsBindingObserver {
  static const _chatIndex = 3;
  int _index = 0;
  // O assistente fica vivo depois da primeira visita, para a conversa não
  // sumir quando a pessoa troca de aba.
  bool _chatOpened = false;
  StreamSubscription<AppNotification>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService.instance.start(company: false);
    _notificationSubscription = NotificationService.instance.events.listen((notification) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
        action: SnackBarAction(label: 'VER', onPressed: () { if (mounted) openNotificationTarget(context, notification); }),
      ));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    NotificationService.instance.setAppActive(state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notificationSubscription?.cancel();
    NotificationService.instance.stop();
    super.dispose();
  }

  // A posição 3 (Assistente) é desenhada à parte, por isso o espaço vazio.
  final _pages = const [
    JobsPage(),
    ConversationsPage(company: false),
    AgendaPage(company: false),
    SizedBox.shrink(),
    ProfilePage(),
  ];

  Widget _body() => Stack(
    fit: StackFit.expand,
    children: [
      if (_chatOpened)
        Offstage(
          key: const ValueKey('assistente'),
          offstage: _index != _chatIndex,
          child: TickerMode(enabled: _index == _chatIndex, child: const ChatbotPage()),
        ),
      if (_index != _chatIndex)
        KeyedSubtree(key: ValueKey('aba$_index'), child: _pages[_index]),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Avance+'),
      actions: const [NotificationBellButton(), SizedBox(width: 8)],
    ),
    body: _body(),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (index) {
        FocusScope.of(context).unfocus();
        setState(() {
          _index = index;
          if (index == _chatIndex) _chatOpened = true;
        });
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.work_outline), label: 'Cargos'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Conversas'),
        NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Agenda'),
        NavigationDestination(icon: Icon(Icons.support_agent), label: 'Assistente'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
      ],
    ),
  );
}
