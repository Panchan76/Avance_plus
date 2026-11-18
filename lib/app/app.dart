import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avance_plus/core/theme/app_theme.dart';
import 'package:avance_plus/features/auth/presentation/pages/auth_gate.dart';

final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class AvanceApp extends StatelessWidget {
  const AvanceApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Avance+', debugShowCheckedModeBanner: false, theme: AppTheme.lightTheme,
    home: const AuthGate(), scaffoldMessengerKey: appScaffoldMessengerKey,
    builder: (context, child) => _AccountTextScale(child: child ?? const SizedBox.shrink()),
  );
}
class _AccountTextScale extends StatefulWidget {
  const _AccountTextScale({required this.child});
  final Widget child;
  @override
  State<_AccountTextScale> createState() => _AccountTextScaleState();
}
class _AccountTextScaleState extends State<_AccountTextScale> {
  late final _auth = FirebaseAuth.instance.authStateChanges();
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(stream: _auth,
    builder: (context, snapshot) => _TextPreference(key: ValueKey(snapshot.data?.uid), uid: snapshot.data?.uid, child: widget.child));
}
class _TextPreference extends StatefulWidget {
  const _TextPreference({super.key, this.uid, required this.child});
  final String? uid;
  final Widget child;
  @override
  State<_TextPreference> createState() => _TextPreferenceState();
}
class _TextPreferenceState extends State<_TextPreference> {
  late final _settings = widget.uid == null ? null : FirebaseFirestore.instance
    .collection('users').doc(widget.uid).collection('settings').doc('accessibility').snapshots();
  @override
  Widget build(BuildContext context) => StreamBuilder(stream: _settings, builder: (context, snapshot) {
    final scale = MediaQuery.textScalerOf(context);
    final large = snapshot.data?.data()?['largeText'] == true;
    return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: large ? _LargerText(scale) : scale), child: widget.child);
  });
}
class _LargerText extends TextScaler {
  const _LargerText(this.system);
  final TextScaler system;
  @override
  double scale(double fontSize) => system.scale(fontSize) * 1.2;
  @override
  double get textScaleFactor => system.textScaleFactor * 1.2;
}
