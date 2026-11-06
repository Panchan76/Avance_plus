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
    _CompanyHomePage(),
    _CompanyPublishPage(),
    _CompanyCandidatesPage(),
    _CompanyProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
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
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Publicar',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Candidatos',
          ),
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

class _CompanyHomePage extends StatelessWidget {
  const _CompanyHomePage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Painel da empresa',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 10),
            Text(
              'Gerencie suas oportunidades e acompanhe os candidatos.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyPublishPage extends StatelessWidget {
  const _CompanyPublishPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Criar publicação',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CompanyCandidatesPage extends StatelessWidget {
  const _CompanyCandidatesPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Candidatos',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CompanyProfilePage extends StatelessWidget {
  const _CompanyProfilePage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Perfil da empresa',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}