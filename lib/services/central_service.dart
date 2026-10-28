import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ocorrencia.dart';

class CentralService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Ocorrencia>> acompanhar() => _db.collection('ocorrencias')
      .orderBy('criadoEm', descending: true).snapshots()
      .map((s) => s.docs.map(Ocorrencia.fromDoc).toList());

  Future<void> registrar({required String titulo, required String local,
      required String descricao}) async {
    final u = FirebaseAuth.instance.currentUser!;
    await _db.collection('ocorrencias').add({
      'titulo': titulo.trim(), 'local': local.trim(), 'descricao': descricao.trim(),
      'autorId': u.uid, 'autorNome': u.displayName ?? u.email ?? 'Anônimo',
      'resolvido': false, 'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> alterarStatus(Ocorrencia item) async {
    final u = FirebaseAuth.instance.currentUser!;
    if (u.uid != item.autorId) throw StateError('Apenas o dono pode alterar o status.');
    await _db.collection('ocorrencias').doc(item.id).update({'resolvido': !item.resolvido});
  }

  Future<void> enviarPista(String ocorrenciaId, String mensagem) async {
    final u = FirebaseAuth.instance.currentUser!;
    final texto = mensagem.trim();
    if (texto.isEmpty) throw ArgumentError('A pista não pode estar vazia.');
    await _db.collection('ocorrencias').doc(ocorrenciaId).collection('pistas').add({
      'mensagem': texto, 'autorId': u.uid,
      'autorNome': u.displayName ?? u.email ?? 'Anônimo',
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> pistas(String id) =>
      _db.collection('ocorrencias').doc(id).collection('pistas')
      .orderBy('criadoEm', descending: false).snapshots();
}