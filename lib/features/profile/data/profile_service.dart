import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  static final instance = ProfileService();
  String get uid => FirebaseAuth.instance.currentUser!.uid;
  DocumentReference<Map<String, dynamic>> get profile => FirebaseFirestore.instance.collection('users').doc(uid);
  DocumentReference<Map<String, dynamic>> get settings => profile.collection('settings').doc('accessibility');
  Reference get photo => FirebaseStorage.instance.ref('profilePhotos/$uid/avatar');
  Future<void> save({required String name, required String phone, required String city, required String contactEmail}) => profile.update({
    'name': name.trim(), 'phone': phone.trim(), 'city': city.trim(), 'contactEmail': contactEmail.trim(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
  Future<Uint8List?> loadPhoto() async {
    try { return await photo.getData(5 * 1024 * 1024); }
    on FirebaseException catch (error) { if (error.code == 'object-not-found') return null; rethrow; }
  }
  Future<void> uploadPhoto(XFile file) async {
    if (await file.length() > 5 * 1024 * 1024) throw const FormatException('Escolha uma foto de até 5 MB.');
    final bytes = await file.readAsBytes();
    String? type;
    if (bytes.length >= 12) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) type = 'image/jpeg';
      if (bytes[0] == 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) type = 'image/png';
      if (String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' && String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') type = 'image/webp';
    }
    if (type == null) throw const FormatException('Use uma foto JPG, PNG ou WebP.');
    await photo.putData(bytes, SettableMetadata(contentType: type));
  }
  Future<void> removePhoto() async {
    try { await photo.delete(); }
    on FirebaseException catch (error) { if (error.code != 'object-not-found') rethrow; }
  }
}
