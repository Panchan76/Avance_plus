import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_service.dart';
import '../../data/cnpj_validator.dart';
import '../widgets/sign_out_button.dart';

int _ageOn(DateTime birth, DateTime today) => today.year - birth.year -
    ((today.month < birth.month || (today.month == birth.month && today.day < birth.day)) ? 1 : 0);

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({super.key, required this.user, required this.onSaved});
  final User user;
  final VoidCallback onSaved;
  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}
class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _cnpj = TextEditingController();
  String _role = 'candidate';
  DateTime? _birthDate;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _name.text = widget.user.displayName ?? '';
  }
  @override
  void dispose() { _name.dispose(); _cnpj.dispose(); super.dispose(); }
  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await AuthService.instance.saveProfile(widget.user,
        name: _name.text, role: _role, cnpj: _cnpj.text, birthDate: _birthDate);
      if (mounted) widget.onSaved();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authErrorMessage(error))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Concluir cadastro')),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24),
      child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Sua conta ${widget.user.email ?? ""} está conectada. Escolha o tipo de conta e complete seu perfil para continuar.'),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Tipo de conta'),
            items: const [DropdownMenuItem(value: 'candidate', child: Text('Candidato')),
              DropdownMenuItem(value: 'company', child: Text('Empresa'))],
            onChanged: _busy ? null : (value) => setState(() => _role = value!),
          ),
          const SizedBox(height: 16),
          TextFormField(controller: _name, enabled: !_busy, maxLength: 120,
            decoration: InputDecoration(labelText: _role == 'company' ? 'Nome da empresa' : 'Nome completo'),
            validator: (value) => (value ?? '').trim().length < 3 ? 'Informe o nome.' : null),
          if (_role == 'company') TextFormField(controller: _cnpj, enabled: !_busy, maxLength: 32,
            decoration: const InputDecoration(labelText: 'CNPJ'),
            validator: validateCnpjField),
          if (_role == 'candidate') ...[
            const SizedBox(height: 16),
            FormField<DateTime>(
              validator: (_) => _birthDate == null
                ? 'Informe sua data de nascimento.'
                : (_ageOn(_birthDate!, DateTime.now()) < 60
                    ? 'O cadastro é exclusivo para pessoas com 60 anos ou mais.' : null),
              builder: (field) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(context: context,
                      initialDate: DateTime(now.year - 60, now.month, now.day),
                      firstDate: DateTime(1900), lastDate: now,
                      helpText: 'Selecione sua data de nascimento');
                    if (picked != null) { setState(() => _birthDate = picked); field.didChange(picked); }
                  },
                  icon: const Icon(Icons.cake_outlined),
                  label: Text(_birthDate == null ? 'Data de nascimento' :
                    'Nascimento: ${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'),
                ),
                if (field.hasError) Text(field.errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                const Text('O cadastro de candidato exige idade mínima de 60 anos.'),
              ]),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _busy ? null : _save,
            child: Text(_busy ? 'Salvando...' : 'Salvar perfil')),
          if (!_busy) const SignOutButton(),
        ],
      )),
    )),
  );
}
