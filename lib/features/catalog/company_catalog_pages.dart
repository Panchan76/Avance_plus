import '../communication/conversations_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/data/auth_service.dart';
import 'catalog_service.dart';

class RoleRequestsPage extends StatefulWidget {
  const RoleRequestsPage({super.key});
  @override
  State<RoleRequestsPage> createState() => _RoleRequestsPageState();
}
class _RoleRequestsPageState extends State<RoleRequestsPage> {
  late final _requests = CatalogService.instance.requests();
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController(), _description = TextEditingController();
  bool _busy = false;
  @override
  void dispose() { _title.dispose(); _description.dispose(); super.dispose(); }
  Future<void> _send() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await CatalogService.instance.requestRole(_title.text, _description.text);
      if (!mounted) return;
      _title.clear(); _description.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitação enviada para aprovação.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authErrorMessage(error))));
    } finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) => SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Solicitar novo cargo', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 12),
      const Text('Confira primeiro o catálogo. Se o cargo ainda não existir, solicite a inclusão. Ele aparecerá para todos somente após aprovação.'),
      const SizedBox(height: 20),
      Form(key: _form, child: Column(children: [
        TextFormField(controller: _title, enabled: !_busy, maxLength: 80,
          decoration: const InputDecoration(labelText: 'Nome do cargo'),
          validator: (value) => (value ?? '').trim().length < 3 ? 'Informe um nome com pelo menos 3 caracteres.' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _description, enabled: !_busy, maxLength: 1000, maxLines: 4,
          decoration: const InputDecoration(labelText: 'Descreva as atividades', alignLabelWithHint: true),
          validator: (value) => (value ?? '').trim().length < 10 ? 'Descreva as atividades com pelo menos 10 caracteres.' : null),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _busy ? null : _send, child: Text(_busy ? 'Enviando...' : 'Enviar para aprovação'))),
      ])),
      const SizedBox(height: 28),
      Text('Minhas solicitações', style: Theme.of(context).textTheme.titleLarge),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: _requests, builder: (context, snapshot) {
        if (snapshot.hasError) return Text(authErrorMessage(snapshot.error!));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = [...snapshot.data!.docs]..sort((a,b) => ((b.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0).compareTo((a.data()['createdAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0));
        if (docs.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text('Você ainda não enviou solicitações.'));
        return Column(children: docs.map((doc) {
          final d = doc.data();
          final label = {'pending': 'Aguardando aprovação', 'approved': 'Aprovado', 'rejected': 'Não aprovado'}[d['status']] ?? 'Em análise';
          return Card(child: ListTile(title: Text(d['title'] as String), subtitle: Text('$label${d['reviewNote'] == null ? "" : "\n${d['reviewNote']}"}')));
        }).toList());
      }),
    ],
  )));
}

class CandidatesPage extends StatefulWidget {
  const CandidatesPage({super.key});
  @override
  State<CandidatesPage> createState() => _CandidatesPageState();
}
class _CandidatesPageState extends State<CandidatesPage> {
  late final _roles = CatalogService.instance.roles();
  String? _roleId;
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Encontrar candidatos', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 12),
      const Text('Selecione um cargo para consultar os currículos disponibilizados pelos candidatos.'),
      const SizedBox(height: 20),
      Expanded(child: StreamBuilder<List<CareerRole>>(stream: _roles, builder: (context, snapshot) {
        if (snapshot.hasError) return Text(authErrorMessage(snapshot.error!));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final roles = snapshot.data!;
        final selected = roles.any((r) => r.id == _roleId) ? _roleId : null;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          DropdownButtonFormField<String>(key: ValueKey(selected), initialValue: selected,
            isExpanded: true, decoration: const InputDecoration(labelText: 'Cargo'),
            items: roles.map((r) => DropdownMenuItem(value: r.id, child: Text(r.title))).toList(),
            onChanged: (value) => setState(() => _roleId = value)),
          const SizedBox(height: 20),
          Expanded(child: selected == null ? const Center(child: Text('Escolha um cargo acima.'))
            : _CandidateList(key: ValueKey(selected), roleId: selected)),
        ]);
      })),
    ],
  )));
}
class _CandidateList extends StatefulWidget {
  const _CandidateList({super.key, required this.roleId});
  final String roleId;
  @override
  State<_CandidateList> createState() => _CandidateListState();
}
class _CandidateListState extends State<_CandidateList> {
  late final _stream = CatalogService.instance.candidates(widget.roleId);
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(stream: _stream,
    builder: (context, snapshot) {
      if (snapshot.hasError) return Text(authErrorMessage(snapshot.error!));
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final docs = snapshot.data!.docs;
      if (docs.isEmpty) return const Center(child: Text('Ainda não há currículos disponíveis neste cargo.'));
      return ListView.separated(itemCount: docs.length, separatorBuilder: (_, _) => const SizedBox(height: 12), itemBuilder: (context, i) {
        final d = docs[i].data();
        return Card(child: ExpansionTile(key: ValueKey(docs[i].id), title: Text(d['name'] as String),
          subtitle: Text(d['city'] as String), childrenPadding: const EdgeInsets.all(16), children: [
            for (final entry in {'summary':'Apresentação','experience':'Experiência','education':'Formação e cursos','skills':'Habilidades','email':'E-mail','phone':'Telefone'}.entries)
              if ((d[entry.key] as String? ?? '').isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 16),
                child: Align(alignment: Alignment.centerLeft, child: SelectableText('${entry.value}\n${d[entry.key]}'))),
            StartConversationButton(candidateId: docs[i].id),
            const SizedBox(height: 8),
            OutlinedButton.icon(icon: const Icon(Icons.copy), label: const Text('Copiar contatos'), onPressed: () async {
              try {
                await Clipboard.setData(ClipboardData(text: '${d['name']}\n${d['email']}\n${d['phone']}'));
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contatos copiados. Entre em contato para combinar a entrevista.')));
              } catch (_) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não foi possível copiar. Selecione o contato exibido acima.')));
              }
            }),
          ]));
      });
    });
}
