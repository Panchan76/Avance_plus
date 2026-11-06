import 'package:flutter/material.dart';
import '../../../auth/data/auth_service.dart';
import '../../../chatbot/presentation/pages/chatbot_page.dart';
import '../../data/profile_service.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});
  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}
class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  late final _settings = ProfileService.instance.settings.snapshots();
  bool _busy = false;
  Future<void> _change(bool value) async {
    setState(() => _busy = true);
    try { await ProfileService.instance.settings.set({'largeText': value}); }
    catch (_) { if (mounted) _message('Não foi possível salvar a preferência.'); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> _password() async {
    final email = AuthService.instance.auth.currentUser?.email;
    if (email == null) return;
    setState(() => _busy = true);
    try { await AuthService.instance.resetPassword(email); if (mounted) _message('Confira seu e-mail para redefinir a senha.'); }
    catch (error) { if (mounted) _message(authErrorMessage(error)); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Configurações')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      StreamBuilder(stream: _settings, builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Não foi possível carregar as preferências. Confira a conexão.');
        if (!snapshot.hasData) return const LinearProgressIndicator();
        return SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Letras maiores'),
          subtitle: const Text('Aumenta o texto do aplicativo e salva a preferência nesta conta.'),
          value: snapshot.data!.data()?['largeText'] == true, onChanged: _busy ? null : _change);
      }),
      const Divider(),
      if (AuthService.instance.auth.currentUser?.providerData.any((p) => p.providerId == 'password') == true)
        ListTile(leading: const Icon(Icons.lock_reset), title: const Text('Redefinir senha por e-mail'), onTap: _busy ? null : _password)
      else const ListTile(leading: Icon(Icons.account_circle_outlined), title: Text('Acesso com Google'), subtitle: Text('A senha do Google é administrada na sua Conta Google.')),
      const ListTile(leading: Icon(Icons.privacy_tip_outlined), title: Text('Privacidade do currículo'), subtitle: Text('Em Perfil > Currículo, desative o compartilhamento para retirar seus dados da consulta das empresas. Conversas existentes permanecem disponíveis.')),
    ]));
}
class HelpPage extends StatelessWidget {
  const HelpPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Ajuda')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      const ExpansionTile(title: Text('Como enviar meu currículo?'), children: [Padding(padding: EdgeInsets.all(16), child: Text('Crie seu currículo em Perfil > Currículo. Depois, abra Cargos e toque em Enviar currículo. Confirme o compartilhamento. O cargo passará a mostrar Currículo enviado. Você pode escolher até 5 cargos.'))]),
      const ExpansionTile(title: Text('Como conversar e marcar uma entrevista?'), children: [Padding(padding: EdgeInsets.all(16), child: Text('A empresa encontra os currículos na aba Candidatos e inicia a conversa. As mensagens ficam em Conversas. A empresa propõe a entrevista e o candidato responde em Agenda, confirmando, pedindo outra data ou rejeitando.'))]),
      const ExpansionTile(title: Text('O CNPJ da empresa é verificado?'), children: [Padding(padding: EdgeInsets.all(16), child: Text('Não. Nesta versão o CNPJ é informado pela empresa, sem consulta externa. Confira a identidade da empresa antes de compartilhar informações sensíveis.'))]),
      const ExpansionTile(title: Text('Como alterar foto e dados?'), children: [Padding(padding: EdgeInsets.all(16), child: Text('Abra Perfil para escolher uma foto JPG, PNG ou WebP de até 5 MB. Toque em Dados pessoais ou Dados da empresa e contato para editar. A foto é usada no seu perfil; nesta versão ela não é compartilhada nos currículos.'))]),
      const ExpansionTile(title: Text('Cuidados durante a busca de trabalho'), children: [Padding(padding: EdgeInsets.all(16), child: Text('Não envie senhas ou códigos de acesso. Desconfie de cobranças para participar de entrevistas. O cadastro da empresa não comprova a identidade de quem está conversando com você.'))]),
      const SizedBox(height: 16),
      FilledButton.icon(icon: const Icon(Icons.support_agent), label: const Text('Perguntar ao assistente'), onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => Scaffold(appBar: AppBar(title: const Text('Assistente')), body: const ChatbotPage())))),
    ]));
}
