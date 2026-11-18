import '../../../profile/presentation/pages/profile_page.dart';
import '../../../communication/conversations_page.dart';
import '../../../communication/agenda_page.dart';
import '../../../catalog/catalog_page.dart';
import '../../../catalog/company_catalog_pages.dart';
import '../../../notifications/notifications_page.dart';
import 'package:flutter/material.dart';

class CompanyNavigationPage extends StatefulWidget {
  const CompanyNavigationPage({super.key});

  @override
  State<CompanyNavigationPage> createState() =>
      _CompanyNavigationPageState();
}

class _CompanyNavigationPageState
    extends State<CompanyNavigationPage> {
  int selectedIndex = 0;

  final pages = const [
    CatalogPage(company: true),
    CandidatesPage(),
    ConversationsPage(company: true),
    AgendaPage(company: true),
    NotificationsPage(company: true),
    ProfilePage(),
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
          NavigationDestination(icon: Icon(Icons.notifications_outlined), label: 'Avisos'),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
