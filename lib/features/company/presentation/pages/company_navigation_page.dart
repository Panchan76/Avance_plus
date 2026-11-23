import 'dart:async';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../communication/conversations_page.dart';
import '../../../communication/agenda_page.dart';
import '../../../notifications/notifications_page.dart';
import '../../../notifications/notification_service.dart';
import '../../../catalog/catalog_page.dart';
import '../../../catalog/company_catalog_pages.dart';
import 'package:flutter/material.dart';

class CompanyNavigationPage extends StatefulWidget {
  const CompanyNavigationPage({super.key});

  @override
  State<CompanyNavigationPage> createState() =>
      _CompanyNavigationPageState();
}

class _CompanyNavigationPageState
    extends State<CompanyNavigationPage> with WidgetsBindingObserver {
  int selectedIndex = 0;
  StreamSubscription<AppNotification>? notificationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    notificationSubscription = NotificationService.instance.events.listen((notification) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
        action: SnackBarAction(label: 'VER', onPressed: () => setState(() => selectedIndex = 5)),
      ));
    });
    NotificationService.instance.start(company: true);
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    NotificationService.instance.setAppActive(state == AppLifecycleState.resumed);
  }
  @override
  void dispose() { WidgetsBinding.instance.removeObserver(this); notificationSubscription?.cancel(); NotificationService.instance.stop(); super.dispose(); }

  final pages = const [
    CatalogPage(company: true),
    CandidatesPage(),
    ConversationsPage(company: true),
    AgendaPage(company: true),
    ProfilePage(),
    NotificationsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Cargos',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Candidatos',
          ),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Conversas'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Agenda'),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Perfil',
          ),
          NavigationDestination(icon: const NotificationBadgeIcon(), label: 'Avisos'),
        ],
      ),
    );
  }
}
