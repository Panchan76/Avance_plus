import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'app/app.dart';
import 'firebase_options.dart';

const _placeholderKey = 'SUBSTITUA_PELA_CHAVE_REAL';

Future<void> _activateAppCheck() async {
  const recaptchaKey = String.fromEnvironment(
    'RECAPTCHA_SITE_KEY',
    defaultValue: _placeholderKey,
  );
  if (kIsWeb && recaptchaKey == _placeholderKey) {
    debugPrint('App Check ignorado na web: rode com '
        '--dart-define=RECAPTCHA_SITE_KEY=sua_chave');
    return;
  }
  await FirebaseAppCheck.instance.activate(
    webProvider: kIsWeb ? ReCaptchaEnterpriseProvider(recaptchaKey) : null,
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: kDebugMode ? AppleProvider.debug : AppleProvider.appAttest,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    debugPrint('Falha na inicialização: $error');
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Não foi possível iniciar o Avance+. '
                  'Verifique a conexão e a configuração do Firebase.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return;
  }

  // App Check isolado: se falhar, o app abre e o erro aparece no console.
  try {
    await _activateAppCheck();
  } catch (error) {
    debugPrint('App Check falhou (o app continua): $error');
  }

  debugPrint('Firebase inicializado com sucesso!');
  runApp(const AvanceApp());
}
