import 'package:flutter/material.dart';
import '../../../jobs/presentation/pages/jobs_page.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../communication/conversations_page.dart';
import '../../../communication/agenda_page.dart';
import '../../../notifications/notifications_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});
  @override
  State<MainNavigationPage> createState()=>_MainNavigationPageState();
}
class _MainNavigationPageState extends State<MainNavigationPage> {
  int _index=0;
  final _pages=const [JobsPage(),ConversationsPage(company:false),AgendaPage(company:false),NotificationsPage(company: false),ChatbotPage(),ProfilePage()];
  @override
  Widget build(BuildContext context)=>Scaffold(
    body:_pages[_index],
    bottomNavigationBar:NavigationBar(selectedIndex:_index,onDestinationSelected:(index)=>setState(()=>_index=index),destinations:const [
      NavigationDestination(icon:Icon(Icons.work_outline),label:'Cargos'),
      NavigationDestination(icon:Icon(Icons.chat_bubble_outline),label:'Conversas'),
      NavigationDestination(icon:Icon(Icons.calendar_month),label:'Agenda'),
      NavigationDestination(icon:Icon(Icons.notifications_outlined),label:'Avisos'),
      NavigationDestination(icon:Icon(Icons.support_agent),label:'Assistente'),
      NavigationDestination(icon:Icon(Icons.person_outline),label:'Perfil'),
    ]),
  );
}
