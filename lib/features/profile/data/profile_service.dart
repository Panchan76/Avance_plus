import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:image_picker/image_picker.dart';

class ProfileService {
  static final instance = ProfileService();
  String get uid => FirebaseAuth.instance.currentUser!.uid;
  DocumentReference<Map<String, dynamic>> get profile => FirebaseFirestore.instance.collection('users').doc(uid);
  DocumentReference<Map<String, dynamic>> get settings => profile.collection('settings').doc('accessibility');
  DocumentReference<Map<String, dynamic>> get photo => profile.collection('avatar').doc('current');
  Future<void> save({required String name, required String phone, required String city, required String contactEmail}) => profile.update({
    'name': name.trim(), 'phone': phone.trim(), 'city': city.trim(), 'contactEmail': contactEmail.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  Future<Uint8List?> loadPhoto() async {
    final data = (await photo.get()).data();
    final encoded = data?['base64'] as String?;
    return encoded == null ? null : base64Decode(encoded);
  }
  Future<void> uploadPhoto(XFile file) async {
    if (await file.length() > 10 * 1024 * 1024) {
      throw const FormatException('Escolha uma foto de até 10 MB.');
    }
    final bytes = await file.readAsBytes();
    String? encoded;
    for (final size in [256, 192, 128]) {
      final codec = await ui.instantiateImageCodec(bytes,
          targetWidth: size, targetHeight: size, allowUpscaling: false);
      try {
        final frame = await codec.getNextFrame();
        try {
          final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
          if (data != null) {
            final value = base64Encode(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
            if (value.length <= 280000) { encoded = value; break; }
          }
        } finally { frame.image.dispose(); }
      } finally { codec.dispose(); }
    }
    if (encoded == null) throw const FormatException('Não foi possível reduzir a foto. Escolha outra imagem.');
    await photo.set({'base64': encoded, 'updatedAt': FieldValue.serverTimestamp()});
  }
  Future<void> removePhoto() => photo.delete();
}
