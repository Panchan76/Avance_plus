import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/user_profile_scope.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/auth_service.dart';
import '../widgets/sign_out_button.dart';
import 'welcome_page.dart';
import 'verify_email_page.dart';
import 'complete_profile_page.dart';
import '../../../company/presentation/pages/company_navigation_page.dart';
import '../../../navigation/presentation/pages/main_navigation_page.dart';

void openAuthenticatedRoot(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const AuthGate()), (_) => false);
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}
class _AuthGateState extends State<AuthGate> {
  late final Stream<User?> _changes = AuthService.instance.auth.authStateChanges();
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: _changes,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Scaffold(body: Center(
        child: Text('Não foi possível recuperar a sessão. Reinicie o aplicativo.')));
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final user = snapshot.data;
      if (user == null) return const WelcomePage();
      return _VerifiedAccountRouter(key: ValueKey(user.uid), user: user);
    },
  );
}
/// Libera somente endereços confirmados pelo Firebase Authentication.
class _VerifiedAccountRouter extends StatefulWidget {
  const _VerifiedAccountRouter({super.key, required this.user});
  final User user;
  @override
  State<_VerifiedAccountRouter> createState() => _VerifiedAccountRouterState();
}

class _VerifiedAccountRouterState extends State<_VerifiedAccountRouter> {
  bool _verified = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      await widget.user.reload();
      // Atualiza o token usado pelas regras de segurança do Firebase.
      await FirebaseAuth.instance.currentUser?.getIdToken(true);
    } on FirebaseAuthException {
      // The verification screen still provides a retry option.
    } catch (_) {
      // Network failure: do not bypass verification.
    }
    if (!mounted) return;
    final current = FirebaseAuth.instance.currentUser;
    final sameUser = current != null && current.uid == widget.user.uid;
    setState(() {
      _verified = sameUser && current.emailVerified;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!_verified) {
      return VerifyEmailPage(user: widget.user, onVerified: _refresh);
    }
    return _ProfileRouter(user: widget.user);
  }
}

class _ProfileRouter extends StatefulWidget {
  const _ProfileRouter({super.key, required this.user});
  final User user;
  @override
  State<_ProfileRouter> createState() => _ProfileRouterState();
}
class _ProfileRouterState extends State<_ProfileRouter> {
  late Stream<DocumentSnapshot<Map<String, dynamic>>> _profile;
  @override
  void initState() {
    super.initState();
    _profile = FirebaseFirestore.instance.collection('users').doc(widget.user.uid).snapshots();
  }
  void _reload() => setState(() {
    _profile = FirebaseFirestore.instance.collection('users').doc(widget.user.uid).snapshots();
  });
  @override
  Widget build(BuildContext context) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: _profile,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) return _problem(authErrorMessage(snapshot.error!));
      final profile = snapshot.data?.data();
      if (profile == null) return CompleteProfilePage(user: widget.user, onSaved: _reload);
      switch (profile['role']) {
        case 'candidate': return UserProfileScope(data: profile, child: const MainNavigationPage());
        case 'company':
          return UserProfileScope(data: profile, child: const CompanyNavigationPage());
        default: return _problem('O tipo de perfil é inválido. Entre em contato com o suporte.');
      }
    },
  );
  Widget _problem(String message) => Scaffold(body: SafeArea(child: Center(
    child: Padding(padding: const EdgeInsets.all(24), child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _reload, child: const Text('Tentar novamente')),
        const SignOutButton(),
      ],
    )),
  )));
}
