import 'company_catalog_pages.dart';
import 'package:flutter/material.dart';
import '../auth/data/auth_service.dart';
import 'catalog_service.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key, this.company = false});
  final bool company;
  @override
  State<CatalogPage> createState() => _CatalogPageState();
}
class _CatalogPageState extends State<CatalogPage> {
  late final _roles = CatalogService.instance.roles();
  late final _resume = widget.company ? null : CatalogService.instance.watchResume();
  String _search = '';
  String? _sending;
  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> _send(CareerRole role) async {
    if (_sending != null) return;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: Text('Enviar para ${role.title}?'),
      content: const Text('Seu currículo e dados de contato ficarão disponíveis às empresas cadastradas neste cargo e nos demais cargos selecionados no seu currículo. Você pode retirar o compartilhamento em Perfil > Currículo.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enviar currículo'))],
    ));
    if (confirmed != true || !mounted) return;
    setState(() => _sending = role.id);
    try {
      await CatalogService.instance.submitResume(role.id);
      if (mounted) _message('Currículo enviado para ${role.title}.');
    } catch (error) { if (mounted) _message(authErrorMessage(error)); }
    finally { if (mounted) setState(() => _sending = null); }
  }
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Catálogo de cargos', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Text(widget.company ? 'Cargos disponíveis para buscar candidatos. Novos cargos passam por aprovação.' : 'Envie seu currículo para os cargos de interesse. Para criar ou editar, acesse Perfil > Currículo.'),
      if (widget.company) OutlinedButton.icon(icon: const Icon(Icons.add), label: const Text('Solicitar novo cargo / acompanhar pedidos'),
        onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Solicitações de cargos')), body: const RoleRequestsPage())))),
      const SizedBox(height: 12),
      TextField(decoration: const InputDecoration(labelText: 'Buscar cargo', prefixIcon: Icon(Icons.search)),
        onChanged: (value) => setState(() => _search = value.toLowerCase().trim())),
      const SizedBox(height: 16),
      Expanded(child: StreamBuilder(stream: _resume, builder: (context, resumeSnapshot) {
        if (!widget.company && resumeSnapshot.hasError) return Center(child: Text(authErrorMessage(resumeSnapshot.error!)));
        if (!widget.company && !resumeSnapshot.hasData) return const Center(child: CircularProgressIndicator());
        final resume = resumeSnapshot.data?.data();
        final sentIds = resume?['shared'] == true ? List<String>.from(resume?['roleIds'] ?? []) : <String>[];
        return StreamBuilder<List<CareerRole>>(stream: _roles, builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text(authErrorMessage(snapshot.error!)));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final roles = snapshot.data!.where((role) => role.title.toLowerCase().contains(_search)).toList();
          if (roles.isEmpty) return const Center(child: Text('Nenhum cargo encontrado.'));
          return ListView.separated(itemCount: roles.length, separatorBuilder: (_, _) => const SizedBox(height: 12), itemBuilder: (context, i) {
            final role = roles[i], sent = sentIds.contains(roles[i].id);
            return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(role.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8), Text(role.description),
              if (!widget.company) Padding(padding: const EdgeInsets.only(top: 12), child: sent
                ? const Row(children: [Icon(Icons.check_circle_outline), SizedBox(width: 8), Expanded(child: Text('Currículo enviado'))])
                : OutlinedButton(onPressed: _sending != null ? null : () {
                    if (resume == null) { _message('Primeiro crie seu currículo em Perfil > Currículo.'); return; }
                    _send(role);
                  }, child: Text(_sending == role.id ? 'Enviando...' : 'Enviar currículo'))),
            ])));
          });
        });
      })),
    ],
  )));
}
