import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    runApp(const AvanceApp());
  } catch (error) {
    debugPrint('Falha na inicialização do Firebase: $error');
    runApp(const MaterialApp(home: Scaffold(body: SafeArea(child: Center(
      child: Padding(padding: EdgeInsets.all(24), child: Text(
        'Não foi possível iniciar o Avance+. Verifique a conexão e a configuração do Firebase e abra o aplicativo novamente.',
        textAlign: TextAlign.center,
      )),
    )))));
  }
}
