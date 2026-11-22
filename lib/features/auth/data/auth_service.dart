import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final instance = AuthService();
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  Future<void>? _googleInitialization;
  bool _googleBusy = false;

  static bool get supportsGoogleSignIn => kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Future<bool> signInWithGoogle() async {
    if (_googleBusy) return false;
    _googleBusy = true;
    try {
      if (kIsWeb) {
        // Call the popup directly from the click handler; do not await setup first.
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        await auth.signInWithPopup(provider);
      } else {
        if (!supportsGoogleSignIn) {
          throw UnsupportedError('Use o navegador ou um dispositivo Android/iOS para entrar com Google.');
        }
        final google = GoogleSignIn.instance;
        await (_googleInitialization ??= google.initialize());
        final account = await google.authenticate();
        final idToken = account.authentication.idToken;
        if (idToken == null) {
          throw FirebaseAuthException(code: 'google-token-missing',
            message: 'O Google não retornou o token de autenticação.');
        }
        await auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
      }
      // AuthGate loads the existing UID profile or asks to complete a new one.
      return true;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) return false;
      rethrow;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'popup-closed-by-user' ||
          error.code == 'cancelled-popup-request' || error.code == 'web-context-canceled') {
        return false;
      }
      rethrow;
    } finally {
      _googleBusy = false;
    }
  }

  Future<void> signIn(String email, String password) async {
    await auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  Future<void> register({required String email, required String password,
    required String name, required String role, String? cnpj, DateTime? birthDate}) async {
    final result = await auth.createUserWithEmailAndPassword(
      email: email.trim(), password: password);
    // Authentication and Firestore are separate services. If this write fails,
    // keep the account: AuthGate offers profile completion on the next login.
    await saveProfile(result.user!, name: name, role: role, cnpj: cnpj, birthDate: birthDate);
  }

  Future<void> saveProfile(User user, {required String name,
    required String role, String? cnpj, DateTime? birthDate}) async {
    if (!['candidate', 'company'].contains(role) || name.trim().length < 2 ||
        name.trim().length > 120 ||
        (role == 'company' && ((cnpj ?? '').trim().isEmpty || cnpj!.trim().length > 32))) {
      throw const FormatException('Confira o nome e os dados do perfil.');
    }
    if (role == 'candidate' && (birthDate == null || _ageOn(birthDate, DateTime.now()) < 60)) {
      throw const FormatException('O cadastro de candidato é exclusivo para pessoas com 60 anos ou mais.');
    }
    final ref = db.collection('users').doc(user.uid);
    // Idempotent: retries cannot overwrite a profile or change its role.
    await db.runTransaction((transaction) async {
      final existing = await transaction.get(ref);
      if (!existing.exists) {
        transaction.set(ref, {
          'uid': user.uid, 'email': user.email,
          'name': name.trim(), 'role': role,
          if (role == 'company') 'cnpj': cnpj!.trim(),
          if (role == 'candidate') 'birthDate': Timestamp.fromDate(birthDate!),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }).timeout(const Duration(seconds: 20));
  }

  Future<Map<String, dynamic>?> profile(String uid) async {
    final doc = await db.collection('users').doc(uid)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 20));
    return doc.data();
  }

  Future<void> resetPassword(String email) =>
      auth.sendPasswordResetEmail(email: email.trim());
  Future<void> signOut() async {
    if (!kIsWeb && _googleInitialization != null) {
      try {
        await _googleInitialization;
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // A provider cleanup failure must not prevent Firebase logout.
        debugPrint('Não foi possível limpar a sessão local do Google.');
      }
    }
    await auth.signOut();
  }
}

int _ageOn(DateTime birth, DateTime today) => today.year - birth.year -
    ((today.month < birth.month || (today.month == birth.month && today.day < birth.day)) ? 1 : 0);

String authErrorMessage(Object error) {
  if (error is UnsupportedError) return error.message ?? 'Plataforma não suportada.';
  if (error is GoogleSignInException) {
    if (error.code == GoogleSignInExceptionCode.clientConfigurationError) {
      return 'Confira a configuração do Google: identificadores OAuth, arquivo de configuração e assinatura do app.';
    }
    return 'Não foi possível entrar com Google. Confira a conexão e tente novamente.';
  }
  if (error is TimeoutException) {
    return 'A conexão demorou. Confira a internet e tente novamente.';
  }
  if (error is FormatException) return error.message;
  if (error is FirebaseException) {
    switch (error.code) {
      case 'invalid-email': return 'Digite um e-mail válido.';
      case 'email-already-in-use': return 'Este e-mail já tem uma conta. Entre ou recupere sua senha.';
      case 'weak-password': case 'password-does-not-meet-requirements':
        return 'Escolha uma senha mais forte, conforme a política do aplicativo.';
      case 'invalid-credential': case 'wrong-password': case 'user-not-found':
        return 'E-mail ou senha incorretos.';
      case 'user-disabled': return 'Esta conta foi desativada. Entre em contato com o suporte.';
      case 'too-many-requests': return 'Muitas tentativas. Aguarde um pouco e tente novamente.';
      case 'network-request-failed': case 'unavailable':
        return 'Não foi possível conectar. Confira sua internet.';
      case 'operation-not-allowed': return 'Ative este método de login em Authentication no Firebase.';
      case 'popup-blocked': return 'Permita a janela de login do Google no navegador e tente novamente.';
      case 'unauthorized-domain': return 'Adicione o domínio do site aos domínios autorizados no Firebase Authentication.';
      case 'account-exists-with-different-credential':
        return 'Este e-mail já usa outro método de acesso. Entre com o método original; será necessário vincular o Google à conta existente.';
      case 'google-token-missing': return 'Confira os identificadores OAuth na configuração do Google.';
      case 'permission-denied': return 'Não foi possível acessar o perfil. Verifique as regras do Firestore e a configuração do App Check.';
      default: return 'Não foi possível concluir (${error.code}). Tente novamente.';
    }
  }
  return 'Não foi possível concluir. Tente novamente.';
}
