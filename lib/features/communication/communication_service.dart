import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/data/auth_service.dart';

class Conversation {
  const Conversation(this.id, this.data);
  final String id;
  final Map<String, dynamic> data;
  String get companyId => data['companyId'] as String;
  String get candidateId => data['candidateId'] as String;
  String otherName(bool company) => data[company ? 'candidateName' : 'companyName'] as String;
}
class Interview {
  const Interview(this.id, this.data);
  final String id;
  final Map<String, dynamic> data;
  String get status => data['status'] as String;
  int get revision => data['revision'] as int;
  DateTime get start => (data['startAt'] as Timestamp).toDate().toLocal();
  DateTime? get proposed => (data['proposedAt'] as Timestamp?)?.toDate().toLocal();
  DateTime get agendaDate => status == 'reschedule_requested' ? proposed! : start;
  bool get active => ['pending','confirmed','reschedule_requested'].contains(status);
  String get statusLabel => {
    'pending': 'Aguardando candidato', 'confirmed': 'Confirmada',
    'reschedule_requested': 'Nova data aguardando empresa',
    'rejected': 'Recusada pelo candidato', 'cancelled': 'Cancelada pela empresa',
  }[status] ?? status;
  Conversation get conversation => Conversation(data['conversationId'] as String, data);
}
String formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
String formatMoment(DateTime date) => '${formatDate(date)} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
String communicationError(Object error) {
  if (error is StateError) return error.message;
  if (error is FirebaseException && error.code == 'permission-denied') {
    return 'A operação não foi autorizada. Confira a sessão e as regras do Firestore.';
  }
  return authErrorMessage(error);
}

class CommunicationService {
  static final instance = CommunicationService();
  final db = FirebaseFirestore.instance;
  String get uid => AuthService.instance.auth.currentUser!.uid;

  Stream<List<Conversation>> conversations(bool company) => db.collection('conversations')
    .where(company ? 'companyId' : 'candidateId', isEqualTo: uid).snapshots().map((snapshot) {
      final docs = snapshot.docs.map((d) => Conversation(d.id, d.data())).toList();
      docs.sort((a,b) => ((b.data['updatedAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0)
        .compareTo((a.data['updatedAt'] as Timestamp?)?.millisecondsSinceEpoch ?? 0));
      return docs;
    });

  Future<Conversation> openConversation(String candidateId) async {
    final companyId = uid;
    final id = '${companyId.length}_${companyId}_$candidateId';
    final ref = db.collection('conversations').doc(id);
    return db.runTransaction((transaction) async {
      final old = await transaction.get(ref);
      if (old.exists) return Conversation(id, old.data()!);
      final profile = await transaction.get(db.collection('users').doc(companyId));
      final resume = await transaction.get(db.collection('resumes').doc(candidateId));
      if (resume.data()?['shared'] != true) throw StateError('Este candidato não está mais disponível para novos contatos.');
      final data = <String,dynamic>{
        'companyId': companyId, 'candidateId': candidateId,
        'companyName': profile.data()!['name'], 'candidateName': resume.data()!['name'],
        'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
      };
      transaction.set(ref, data);
      return Conversation(id, data);
    });
  }

  Stream<QuerySnapshot<Map<String,dynamic>>> messages(String conversationId, int limit) => db
    .collection('conversations').doc(conversationId).collection('messages')
    .orderBy('createdAt', descending: true).limit(limit).snapshots();

  Future<void> sendMessage(String conversationId, String messageId, String text) async {
    final chat = db.collection('conversations').doc(conversationId);
    final message = chat.collection('messages').doc(messageId);
    final sender = uid;
    await db.runTransaction((transaction) async {
      final old = await transaction.get(message);
      if (old.exists) {
        if (old.data()?['senderId'] == sender && old.data()?['text'] == text.trim()) return;
        throw StateError('Esta mensagem já foi enviada. Abra a conversa novamente.');
      }
      transaction.set(message, {'senderId': sender, 'text': text.trim(), 'createdAt': FieldValue.serverTimestamp()});
      transaction.update(chat, {'updatedAt': FieldValue.serverTimestamp()});
    });
  }
  String newMessageId(String conversationId) => db.collection('conversations').doc(conversationId).collection('messages').doc().id;
  String newInterviewId() => db.collection('interviews').doc().id;

  Stream<List<Interview>> interviews(bool company, {String? conversationId}) => db.collection('interviews')
    .where(company ? 'companyId' : 'candidateId', isEqualTo: uid).snapshots().map((snapshot) {
      final all = snapshot.docs.map((d) => Interview(d.id,d.data()))
        .where((i) => conversationId == null || i.data['conversationId'] == conversationId).toList();
      all.sort((a,b) => a.agendaDate.compareTo(b.agendaDate));
      return all;
    });
  Stream<DocumentSnapshot<Map<String,dynamic>>> interview(String id) => db.collection('interviews').doc(id).snapshots();

  Future<void> invite({required String id, required Conversation conversation,
    required String title, required String location, required DateTime start, required int duration}) async {
    if (!start.isAfter(DateTime.now())) throw StateError('Escolha uma data e um horário futuros.');
    final ref = db.collection('interviews').doc(id);
    await db.runTransaction((transaction) async {
      final existing = await transaction.get(ref);
      if (existing.exists) {
        final old = existing.data()!;
        if (old['conversationId'] == conversation.id && old['title'] == title.trim()
            && old['location'] == location.trim() && old['durationMinutes'] == duration
            && (old['startAt'] as Timestamp).toDate().isAtSameMomentAs(start)) {
          return;
        }
        throw StateError('Este convite já foi enviado com outros dados. Confira a Agenda antes de enviar outro.');
      }
      transaction.set(ref, {
        'conversationId': conversation.id, 'companyId': conversation.companyId,
        'candidateId': conversation.candidateId, 'companyName': conversation.data['companyName'],
        'candidateName': conversation.data['candidateName'], 'title': title.trim(),
        'location': location.trim(), 'startAt': Timestamp.fromDate(start.toUtc()),
        'durationMinutes': duration, 'status': 'pending', 'proposedAt': null,
        'responseNote': '', 'revision': 0, 'updatedBy': uid,
        'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> respond(Interview expected, String action, {DateTime? date, String note = ''}) async {
    final actor = uid;
    await db.runTransaction((transaction) async {
      final ref = db.collection('interviews').doc(expected.id);
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw StateError('Entrevista não encontrada.');
      final current = Interview(snapshot.id, snapshot.data()!);
      if (current.revision != expected.revision) throw StateError('O convite foi atualizado. Confira os dados e tente novamente.');
      if (!current.active) throw StateError('Esta entrevista já foi encerrada.');
      final candidate = actor == current.data['candidateId'];
      final company = actor == current.data['companyId'];
      final changes = <String,dynamic>{'revision': current.revision + 1,
        'updatedBy': actor, 'updatedAt': FieldValue.serverTimestamp(), 'responseNote': note.trim()};
      switch (action) {
        case 'confirm':
          if (!candidate || current.status != 'pending' || !current.start.isAfter(DateTime.now())) throw StateError('Este convite não pode ser confirmado.');
          changes['status'] = 'confirmed';
          break;
        case 'reject':
          if (!candidate) throw StateError('Somente o candidato pode recusar.');
          changes.addAll({'status':'rejected','proposedAt':null});
          break;
        case 'propose':
          if (!candidate || !['pending','confirmed'].contains(current.status) || date == null || !date.isAfter(DateTime.now())) throw StateError('Escolha um novo horário futuro.');
          changes.addAll({'status':'reschedule_requested','proposedAt':Timestamp.fromDate(date.toUtc())});
          break;
        case 'acceptProposal':
          if (!company || current.status != 'reschedule_requested' || !current.proposed!.isAfter(DateTime.now())) throw StateError('A data sugerida não pode ser confirmada.');
          changes.addAll({'status':'confirmed','startAt':Timestamp.fromDate(current.proposed!.toUtc()),'proposedAt':null});
          break;
        case 'offer':
          if (!company || date == null || !date.isAfter(DateTime.now())) throw StateError('Escolha um novo horário futuro.');
          changes.addAll({'status':'pending','startAt':Timestamp.fromDate(date.toUtc()),'proposedAt':null});
          break;
        case 'cancel':
          if (!company) throw StateError('Somente a empresa pode cancelar o convite.');
          changes.addAll({'status':'cancelled','proposedAt':null});
          break;
        default: throw StateError('Ação desconhecida.');
      }
      transaction.update(ref, changes);
    });
  }
}
