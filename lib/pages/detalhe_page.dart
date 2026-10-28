import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/ocorrencia.dart';
import '../services/central_service.dart';

class DetalhePage extends StatefulWidget {
  final Ocorrencia ocorrencia;
  const DetalhePage({super.key, required this.ocorrencia});
  @override
  State<DetalhePage> createState() => _DetalhePageState();
}

class _DetalhePageState extends State<DetalhePage> {
  final service = CentralService();
  final pista = TextEditingController();

  @override
  void dispose() { pista.dispose(); super.dispose(); }

  Future<void> enviar() async {
    if (pista.text.trim().isEmpty) return;
    try {
      await service.enviarPista(widget.ocorrencia.id, pista.text);
      pista.clear();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar pista: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.ocorrencia;
    final dono = FirebaseAuth.instance.currentUser?.uid == o.autorId;
    return Scaffold(
      appBar: AppBar(title: const Text('Investigação')),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(o.titulo, style: Theme.of(context).textTheme.headlineSmall),
          Text('Local: ${o.local}'),
          Text('Registrado por: ${o.autorNome}'),
          Text(o.descricao.isEmpty ? 'Sem descrição' : o.descricao),
          const SizedBox(height: 8),
          if (dono) OutlinedButton.icon(
            onPressed: () async {
              try {
                await service.alterarStatus(o);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$e')));
              }
            },
            icon: const Icon(Icons.task_alt),
            label: Text(o.resolvido ? 'Reabrir' : 'Marcar como resolvido'),
          ),
          const Divider(),
          const Text('Pistas da comunidade', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: StreamBuilder(
            stream: service.pistas(o.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text('Erro: ${snapshot.error}');
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return const Center(child: Text('Nenhuma pista ainda.'));
              return ListView.builder(itemCount: docs.length, itemBuilder: (context, i) {
                final d = docs[i].data();
                return ListTile(title: Text(d['mensagem'] as String? ?? ''),
                  subtitle: Text(d['autorNome'] as String? ?? 'Anônimo'));
              });
            },
          )),
          Row(children: [
            Expanded(child: TextField(controller: pista,
              decoration: const InputDecoration(hintText: 'Compartilhe uma pista...'))),
            IconButton(onPressed: enviar, icon: const Icon(Icons.send)),
          ]),
        ],
      )),
    );
  }
}