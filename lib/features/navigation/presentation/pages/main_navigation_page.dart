import 'package:flutter/material.dart';

import 'package:avance_plus/features/chatbot/presentation/pages/chatbot_page.dart';
import 'package:avance_plus/features/home/presentation/pages/home_page.dart';
import 'package:avance_plus/features/jobs/presentation/pages/jobs_page.dart';
import 'package:avance_plus/features/profile/presentation/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() =>
      _MainNavigationPageState();
}

class _MainNavigationPageState
    extends State<MainNavigationPage> {
  int selectedIndex = 0;

  void changePage(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [
          HomePage(
            onViewJobs: () {
              changePage(1);
            },
          ),

          const JobsPage(),

          const ChatbotPage(),

          const ProfilePage(),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: changePage,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              size: 28,
            ),
            selectedIcon: Icon(
              Icons.home,
              size: 30,
            ),
            label: 'Início',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.work_outline,
              size: 28,
            ),
            selectedIcon: Icon(
              Icons.work,
              size: 30,
            ),
            label: 'Vagas',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.support_agent_outlined,
              size: 28,
            ),
            selectedIcon: Icon(
              Icons.support_agent,
              size: 30,
            ),
            label: 'Assistente',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              size: 28,
            ),
            selectedIcon: Icon(
              Icons.person,
              size: 30,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}