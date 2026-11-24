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
  Stream<List<CareerRole>> roles({bool company = false}) {
    final query = company
        ? db.collection('company_roles').where('companyId', isEqualTo: uid)
        : db.collection('company_roles').where('active', isEqualTo: true);
    return query.snapshots().map((snapshot) {
      final byId = <String, CareerRole>{};
      for (final doc in snapshot.docs) {
        final d = doc.data();
        if (d['active'] != true) continue;
        final id = d['roleId'] as String;
        byId[id] = CareerRole(id, d['title'] as String, d['description'] as String);
      }
      return byId.values.toList()..sort((a,b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    });
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> requests() => db
      .collection('company_roles').where('companyId', isEqualTo: uid).snapshots();
  Future<void> requestRole(String title, String description) async {
    final normalized = title.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    final legacy = initialRoles.where((r) => r.title.toLowerCase() == normalized);
    final id = legacy.isNotEmpty ? legacy.first.id : 'custom_${Uri.encodeComponent(normalized)}';
    final role = db.collection('career_roles').doc(id);
    final link = db.collection('company_roles').doc('${uid}_$id');
    await db.runTransaction((tx) async {
      if (legacy.isEmpty) {
        final existing = await tx.get(role);
        if (!existing.exists) {
          tx.set(role, {'title': title.trim(), 'description': description.trim(),
            'requestedBy': uid, 'status': 'approved', 'createdAt': FieldValue.serverTimestamp()});
        }
      }
      tx.set(link, {'companyId': uid, 'roleId': id, 'title': title.trim(),
        'description': description.trim(), 'active': true, 'createdAt': FieldValue.serverTimestamp()});
    });
  }
  Future<void> setRoleActive(String id, bool active) => db.collection('company_roles').doc(id).update({'active': active});
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
