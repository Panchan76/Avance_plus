import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/presentation/widgets/sign_out_button.dart';
import '../../../catalog/resume_page.dart';
import '../../data/profile_service.dart';
import 'profile_settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}
class _ProfilePageState extends State<ProfilePage> {
  late final _profile = ProfileService.instance.profile.snapshots();
  Uint8List? _photo;
  bool _photoBusy = false;
  String? _photoError;
  @override
  void initState() { super.initState(); _loadPhoto(); _recoverPhoto(); }
  Future<void> _loadPhoto() async {
    try {
      final bytes = await ProfileService.instance.loadPhoto();
      if (mounted) setState(() { _photo = bytes; _photoError = null; });
    } catch (_) { if (mounted) setState(() => _photoError = 'Não foi possível carregar a foto.'); }
  }
  Future<void> _recoverPhoto() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      final data = await ImagePicker().retrieveLostData();
      if (data.files?.isNotEmpty == true) {
        await ProfileService.instance.uploadPhoto(data.files!.first);
        await _loadPhoto();
      }
    } catch (_) { if (mounted) _message('Não foi possível recuperar a foto selecionada. Escolha novamente.'); }
  }
  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> _changePhoto({bool remove = false}) async {
    if (_photoBusy) return;
    setState(() => _photoBusy = true);
    try {
      if (remove) { await ProfileService.instance.removePhoto(); }
      else {
        final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
        if (file == null || !mounted) return;
        await ProfileService.instance.uploadPhoto(file);
      }
      await _loadPhoto();
      if (mounted) _message(remove ? 'Foto removida.' : 'Foto atualizada.');
    } catch (error) { if (mounted) _message(error is FormatException ? error.message : 'Não foi possível salvar a foto. Confira a conexão e tente novamente.'); }
    finally { if (mounted) setState(() => _photoBusy = false); }
  }
  void _open(Widget page) => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  @override
  Widget build(BuildContext context) => SafeArea(child: StreamBuilder(
    stream: _profile, builder: (context, snapshot) {
      if (snapshot.hasError) return Center(child: Text(authErrorMessage(snapshot.error!)));
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final data = snapshot.data!.data();
      if (data == null) return const Center(child: Text('Perfil não encontrado.'));
      final company = data['role'] == 'company';
      return ListView(padding: const EdgeInsets.all(24), children: [
        Text(company ? 'Perfil da empresa' : 'Meu perfil', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        Center(child: ClipOval(child: _photo == null
          ? CircleAvatar(radius: 52, child: Icon(company ? Icons.business : Icons.person, size: 56))
          : Image.memory(_photo!, width: 104, height: 104, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const CircleAvatar(radius: 52, child: Icon(Icons.broken_image_outlined))))),
        Wrap(alignment: WrapAlignment.center, spacing: 8, children: [
          TextButton.icon(onPressed: _photoBusy ? null : () => _changePhoto(), icon: const Icon(Icons.add_a_photo_outlined), label: Text(_photoBusy ? 'Aguarde...' : 'Escolher foto')),
          if (_photo != null) TextButton(onPressed: _photoBusy ? null : () => _changePhoto(remove: true), child: const Text('Remover foto')),
        ]),
        if (_photoError != null) TextButton(onPressed: _loadPhoto, child: Text('$_photoError Tentar novamente')),
        Center(child: Text(data['name'] as String? ?? '', style: Theme.of(context).textTheme.titleLarge)),
        const SizedBox(height: 12),
        Text(data['email'] as String? ?? ''),
        if (company) ...[
          Text('CNPJ: ${data['cnpj'] ?? ""}'),
          const Text('CNPJ informado pela empresa, sem consulta de situação cadastral.'),
        ],
        const SizedBox(height: 20),
        ListTile(leading: const Icon(Icons.person_outline), title: Text(company ? 'Dados da empresa e contato' : 'Dados pessoais'), trailing: const Icon(Icons.chevron_right), onTap: () => _open(EditProfilePage(data: data))),
        if (!company) ListTile(leading: const Icon(Icons.description_outlined), title: const Text('Currículo'), trailing: const Icon(Icons.chevron_right), onTap: () => _open(const ResumePage())),
        ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Configurações'), trailing: const Icon(Icons.chevron_right), onTap: () => _open(const ProfileSettingsPage())),
        ListTile(leading: const Icon(Icons.help_outline), title: const Text('Ajuda'), trailing: const Icon(Icons.chevron_right), onTap: () => _open(HelpPage(company: company))),
        const SizedBox(height: 20), const SignOutButton(),
      ]);
    },
  ));
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.data});
  final Map<String, dynamic> data;
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}
class _EditProfilePageState extends State<EditProfilePage> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.data['name'] as String? ?? '');
  late final _phone = TextEditingController(text: widget.data['phone'] as String? ?? '');
  late final _city = TextEditingController(text: widget.data['city'] as String? ?? '');
  late final _email = TextEditingController(text: widget.data['contactEmail'] as String? ?? widget.data['email'] as String? ?? '');
  bool _busy = false;
  @override
  void dispose() { _name.dispose(); _phone.dispose(); _city.dispose(); _email.dispose(); super.dispose(); }
  Future<void> _save() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ProfileService.instance.save(name: _name.text, phone: _phone.text, city: _city.text, contactEmail: _email.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dados atualizados. O currículo é editado separadamente em Perfil > Currículo.')));
      Navigator.pop(context);
    } catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(authErrorMessage(error)))); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) => PopScope(canPop: !_busy, child: Scaffold(
    appBar: AppBar(title: const Text('Editar dados')),
    body: ListView(padding: const EdgeInsets.all(24), children: [Form(key: _form, child: Column(children: [
      TextFormField(controller: _name, enabled: !_busy, maxLength: 120, decoration: const InputDecoration(labelText: 'Nome de exibição'), validator: (v) => (v ?? '').trim().length < 2 ? 'Informe pelo menos 2 caracteres.' : null),
      TextFormField(controller: _phone, enabled: !_busy, maxLength: 32, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Telefone de contato (opcional)')),
      TextFormField(controller: _city, enabled: !_busy, maxLength: 120, decoration: const InputDecoration(labelText: 'Cidade / Estado (opcional)')),
      TextFormField(controller: _email, enabled: !_busy, maxLength: 200, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail para contato'), validator: (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((v ?? '').trim()) ? null : 'Informe um e-mail válido.'),
      const Text('O e-mail para entrar na conta permanece o mesmo. Seus dados de currículo e o histórico das conversas são mantidos separadamente.'),
      const SizedBox(height: 20),
      FilledButton(onPressed: _busy ? null : _save, child: Text(_busy ? 'Salvando...' : 'Salvar alterações')),
    ]))]),
  ));
}
