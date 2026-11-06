import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/data/auth_service.dart';

class CareerRole {
  const CareerRole(this.id, this.title, this.description);
  final String id, title, description;
}

class CatalogService {
  static final instance = CatalogService();
  final db = FirebaseFirestore.instance;
  String get uid => AuthService.instance.auth.currentUser!.uid;
  static const initialRoles = [
    CareerRole('carpinteiro', 'Carpinteiro', 'Trabalhos com madeira, montagem e reparos.'),
    CareerRole('jardineiro', 'Jardineiro', 'Manutenção de jardins e cuidado com plantas.'),
    CareerRole('cozinheiro', 'Cozinheiro', 'Preparo de refeições e organização da cozinha.'),
    CareerRole('costureiro', 'Costureiro', 'Costura, ajustes e consertos de roupas.'),
    CareerRole('recepcionista', 'Recepcionista', 'Recepção, atendimento e orientação ao público.'),
    CareerRole('artesao', 'Artesão', 'Produção e reparo de peças artesanais.'),
  ];
  Stream<List<CareerRole>> roles() => db.collection('career_roles')
      .where('status', isEqualTo: 'approved').snapshots().map((snapshot) {
    final roles = [...initialRoles, ...snapshot.docs.map((doc) {
      final data = doc.data();
      return CareerRole(doc.id, data['title'] as String, data['description'] as String);
    })];
    roles.sort((a,b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return roles;
  });
  Stream<QuerySnapshot<Map<String, dynamic>>> requests() => db
      .collection('career_roles').where('requestedBy', isEqualTo: uid).snapshots();
  Future<void> requestRole(String title, String description) => db.collection('career_roles').add({
    'title': title.trim(), 'description': description.trim(),
    'requestedBy': uid, 'status': 'pending', 'createdAt': FieldValue.serverTimestamp(),
  }).then((_) {});
  Future<Map<String, dynamic>?> resume() async =>
      (await db.collection('resumes').doc(uid).get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 20))).data();
  Future<void> saveResume(Map<String, dynamic> data) => db.collection('resumes').doc(uid).set({
    ...data, 'uid': uid, 'updatedAt': FieldValue.serverTimestamp(),
  }).timeout(const Duration(seconds: 20));
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchResume() => db.collection('resumes').doc(uid).snapshots();
  Future<void> submitResume(String roleId) async {
    final ref = db.collection('resumes').doc(uid);
    await db.runTransaction((tx) async {
      final doc = await tx.get(ref);
      final data = doc.data();
      if (data == null || (data['name'] as String? ?? '').trim().isEmpty ||
          (data['email'] as String? ?? '').trim().isEmpty || (data['city'] as String? ?? '').trim().isEmpty) {
        throw const FormatException('Primeiro preencha seu currículo em Perfil > Currículo.');
      }
      final ids = List<String>.from(data['roleIds'] ?? []);
      if (!ids.contains(roleId)) {
        if (ids.length >= 5) throw const FormatException('Você já escolheu 5 cargos. Altere os cargos em Perfil > Currículo.');
        ids.add(roleId);
      }
      // The existing Firestore rules validate the role and all resume fields.
      tx.update(ref, {'roleIds': ids, 'shared': true, 'updatedAt': FieldValue.serverTimestamp()});
    });
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> candidates(String roleId) => db
      .collection('resumes').where('shared', isEqualTo: true)
      .where('roleIds', arrayContains: roleId).snapshots();
}
