import 'package:cloud_firestore/cloud_firestore.dart';

class Ocorrencia {
  final String id;
  final String titulo;
  final String local;
  final String descricao;
  final String autorId;
  final String autorNome;
  final bool resolvido;
  final DateTime? criadoEm;

  const Ocorrencia({required this.id, required this.titulo, required this.local,
    required this.descricao, required this.autorId, required this.autorNome,
    required this.resolvido, required this.criadoEm});

  factory Ocorrencia.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Ocorrencia(id: doc.id, titulo: d['titulo'] as String? ?? '',
      local: d['local'] as String? ?? '', descricao: d['descricao'] as String? ?? '',
      autorId: d['autorId'] as String? ?? '', autorNome: d['autorNome'] as String? ?? 'Anônimo',
      resolvido: d['resolvido'] as bool? ?? false,
      criadoEm: (d['criadoEm'] as Timestamp?)?.toDate());
  }
}