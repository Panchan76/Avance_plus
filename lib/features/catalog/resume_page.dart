import 'package:flutter/material.dart';
import '../auth/data/auth_service.dart';
import 'catalog_service.dart';

class ResumePage extends StatefulWidget {
  const ResumePage({super.key, this.selectRoleId});
  final String? selectRoleId;
  @override
  State<ResumePage> createState() => _ResumePageState();
}
class _ResumePageState extends State<ResumePage> {
  final _form = GlobalKey<FormState>();
  final _fields = {for (final key in ['name','email','phone','city','summary','experience','education','skills']) key: TextEditingController()};
  final _selected = <String>{};
  late final _roles = CatalogService.instance.roles();
  bool _loading = true, _busy = false, _shared = false;
  String? _error;
  String _search = '';
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await CatalogService.instance.resume();
      if (!mounted) return;
      for (final entry in _fields.entries) { entry.value.text = data?[entry.key] as String? ?? ''; }
      if (data == null) {
        final profile = await AuthService.instance.profile(CatalogService.instance.uid);
        if (!mounted) return;
        _fields['name']!.text = profile?['name'] as String? ?? '';
        _fields['email']!.text = profile?['email'] as String? ?? '';
      }
      _selected..clear()..addAll(List<String>.from(data?['roleIds'] ?? []));
      _shared = data?['shared'] == true;
      if (widget.selectRoleId != null && _selected.length < 5) _selected.add(widget.selectRoleId!);
    } catch (error) { if (mounted) _error = authErrorMessage(error); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  @override
  void dispose() { for (final field in _fields.values) { field.dispose(); } super.dispose(); }
  Future<void> _save(List<CareerRole> roles) async {
    if (_busy || !_form.currentState!.validate()) return;
    if (_shared && _selected.isEmpty) { _message('Selecione ao menos um cargo para divulgar seu currículo.'); return; }
    setState(() => _busy = true);
    try {
      await CatalogService.instance.saveResume({
        for (final field in _fields.entries) field.key: field.value.text.trim(),
        'roleIds': _selected.toList(), 'shared': _shared,
      });
      if (mounted) { _message(_shared ? 'Currículo salvo e disponível para empresas.' : 'Currículo salvo como privado.'); Navigator.pop(context); }
    } catch (error) { if (mounted) _message(authErrorMessage(error)); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  @override
  Widget build(BuildContext context) => PopScope(canPop: !_busy, child: Scaffold(
    appBar: AppBar(title: const Text('Meu currículo')),
    body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null
      ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!), TextButton(onPressed: _load, child: const Text('Tentar novamente'))]))
      : StreamBuilder<List<CareerRole>>(stream: _roles, builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(authErrorMessage(snapshot.error!))));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final roles = snapshot.data!;
        return SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Conte sua experiência e escolha até 5 cargos. Você pode editar este currículo quando quiser.'),
            const SizedBox(height: 20),
            _field('name', 'Nome completo', 120, required: true),
            _field('email', 'E-mail para contato', 200, required: true, keyboard: TextInputType.emailAddress),
            _field('phone', 'Telefone para contato (opcional)', 32, keyboard: TextInputType.phone),
            _field('city', 'Cidade / Estado', 120, required: true),
            _field('summary', 'Apresentação', 1000, lines: 3),
            _field('experience', 'Experiência profissional', 4000, lines: 5),
            _field('education', 'Formação e cursos', 2000, lines: 3),
            _field('skills', 'Habilidades', 2000, lines: 3),
            Text('Cargos de interesse (${_selected.length}/5)', style: Theme.of(context).textTheme.titleLarge),
            TextField(decoration: const InputDecoration(labelText: 'Buscar cargos disponíveis', prefixIcon: Icon(Icons.search)), onChanged: (value) => setState(() => _search = value.toLowerCase().trim())),
            if (roles.isEmpty) const Text('Nenhuma empresa oferece cargos no momento.'),
            for (final role in roles.where((r) => _selected.contains(r.id) || r.title.toLowerCase().contains(_search))) CheckboxListTile(contentPadding: EdgeInsets.zero,
              title: Text(role.title), value: _selected.contains(role.id),
              onChanged: _busy ? null : (checked) {
                if (checked == true && _selected.length >= 5) { _message('Você pode escolher até 5 cargos.'); return; }
                setState(() { checked == true ? _selected.add(role.id) : _selected.remove(role.id); });
              }),
            for (final id in _selected.where((id) => !roles.any((role) => role.id == id)).toList())
              ListTile(title: Text('Cargo sem oferta atual: $id'), trailing: TextButton(
                onPressed: _busy ? null : () => setState(() => _selected.remove(id)), child: const Text('Remover'))),
            SwitchListTile(contentPadding: EdgeInsets.zero,
              title: const Text('Disponibilizar meu currículo às empresas'),
              subtitle: const Text('Empresas cadastradas poderão ver estes dados e entrar em contato. Desative para retirar seu currículo da consulta.'),
              value: _shared, onChanged: _busy ? null : (value) => setState(() => _shared = value)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _busy ? null : () => _save(roles), child: Text(_busy ? 'Salvando...' : 'Salvar currículo')),
          ])));
      }),
  ));
  Widget _field(String key, String label, int max, {bool required = false, int lines = 1, TextInputType? keyboard}) => Padding(
    padding: const EdgeInsets.only(bottom: 16), child: TextFormField(
      controller: _fields[key], enabled: !_busy, maxLength: max, maxLines: lines,
      keyboardType: keyboard ?? (lines > 1 ? TextInputType.multiline : TextInputType.text),
      decoration: InputDecoration(labelText: label, alignLabelWithHint: lines > 1),
      validator: (value) {
        if (required && (value ?? '').trim().isEmpty) return 'Preencha este campo.';
        if (key == 'email' && !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((value ?? '').trim())) return 'Informe um e-mail válido.';
        return null;
      },
    ));
}
