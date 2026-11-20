
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaEnterpriseProvider(
        const String.fromEnvironment(
          'RECAPTCHA_SITE_KEY',
          defaultValue: 'SUBSTITUA_PELA_CHAVE_REAL',
        ),
      ),
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode
          ? AppleProvider.debug
          : AppleProvider.appAttest,
    );

    debugPrint('Firebase inicializado com sucesso!');
    runApp(const AvanceApp());
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
  }
}
