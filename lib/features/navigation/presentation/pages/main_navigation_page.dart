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
  State<MainNavigationPage> createState()=>_MainNavigationPageState();
}
class _MainNavigationPageState extends State<MainNavigationPage> with WidgetsBindingObserver {
  int _index=0;
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
        action: SnackBarAction(label: 'VER', onPressed: () => setState(() => _index = 5)),
      ));
    });
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    NotificationService.instance.setAppActive(state == AppLifecycleState.resumed);
  }
  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); _notificationSubscription?.cancel(); NotificationService.instance.stop(); super.dispose(); }
  final _pages=const [JobsPage(),ConversationsPage(company:false),AgendaPage(company:false),ChatbotPage(),ProfilePage(),NotificationsPage()];
  @override
  Widget build(BuildContext context)=>Scaffold(
    body:_pages[_index],
    bottomNavigationBar:NavigationBar(selectedIndex:_index,onDestinationSelected:(index)=>setState(()=>_index=index),destinations:const [
      NavigationDestination(icon:Icon(Icons.work_outline),label:'Cargos'),
      NavigationDestination(icon:Icon(Icons.chat_bubble_outline),label:'Conversas'),
      NavigationDestination(icon:Icon(Icons.calendar_month),label:'Agenda'),
      NavigationDestination(icon:Icon(Icons.support_agent),label:'Assistente'),
      NavigationDestination(icon:Icon(Icons.person_outline),label:'Perfil'),
      NavigationDestination(icon:const NotificationBadgeIcon(),label:'Avisos'),
    ]),
  );
}
