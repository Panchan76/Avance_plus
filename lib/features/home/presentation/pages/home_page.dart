import 'package:flutter/material.dart';
import '../../../catalog/resume_page.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onViewJobs});
  final VoidCallback onViewJobs;
  @override
  Widget build(BuildContext context) => SafeArea(child: SingleChildScrollView(
    padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Sua experiência tem valor', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 16),
      const Text('Escolha os cargos em que deseja trabalhar e apresente suas experiências. As empresas poderão encontrar seu currículo e entrar em contato.'),
      const SizedBox(height: 24),
      ElevatedButton.icon(onPressed: onViewJobs, icon: const Icon(Icons.work_outline), label: const Text('Conhecer os cargos')),
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const ResumePage())),
        icon: const Icon(Icons.description_outlined), label: const Text('Meu currículo')),
      const SizedBox(height: 24),
      const Text('Você decide se seu currículo fica disponível às empresas. Altere essa opção na tela Meu currículo.'),
    ]),
  ));
}
