import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/ocorrencia.dart';
import '../services/central_service.dart';
import 'detalhe_page.dart';

class CentralPage extends StatefulWidget {
  const CentralPage({super.key});
  @override
  State<CentralPage> createState() => _CentralPageState();
}

class _CentralPageState extends State<CentralPage> {
  final service = CentralService();
  final titulo = TextEditingController();
  final local = TextEditingController();
  final descricao = TextEditingController();
  bool somenteAbertos = false;

  @override
  void dispose() {
    titulo.dispose(); local.dispose(); descricao.dispose(); super.dispose();
  }

  Future<void> cadastrar() async {
    if (titulo.text.trim().isEmpty || local.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe título e local.')));
      return;
    }
    try {
      await service.registrar(titulo: titulo.text, local: local.text,
          descricao: descricao.text);
      titulo.clear(); local.clear(); descricao.clear();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível registrar: $e')));
    }
  }

  void mostrarFormulario() => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Nova ocorrência'),
      content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titulo, decoration: const InputDecoration(labelText: 'Objeto')),
        TextField(controller: local, decoration: const InputDecoration(labelText: 'Local')),
        TextField(controller: descricao, decoration: const InputDecoration(labelText: 'Descrição')),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
        FilledButton(onPressed: cadastrar, child: const Text('Registrar')),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Central de Achados'), actions: [
      IconButton(tooltip: 'Sair', onPressed: () => FirebaseAuth.instance.signOut(),
        icon: const Icon(Icons.logout)),
    ]),
    floatingActionButton: FloatingActionButton.extended(onPressed: mostrarFormulario,
      label: const Text('Registrar'), icon: const Icon(Icons.add)),
    body: Column(children: [
      SwitchListTile(title: const Text('Somente não resolvidos'), value: somenteAbertos,
        onChanged: (value) => setState(() => somenteAbertos = value)),
      Expanded(child: StreamBuilder<List<Ocorrencia>>(
        stream: service.acompanhar(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final todos = snapshot.data!;
          final itens = somenteAbertos ? todos.where((o) => !o.resolvido).toList() : todos;
          if (itens.isEmpty) return const Center(child: Text('Nenhuma ocorrência encontrada.'));
          return ListView.builder(itemCount: itens.length, itemBuilder: (context, index) {
            final o = itens[index];
            return Card(child: ListTile(
              title: Text(o.titulo),
              subtitle: Text('${o.local} • ${o.resolvido ? "Resolvido" : "Em aberto"}\nPor ${o.autorNome}'),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => DetalhePage(ocorrencia: o))),
            ));
          });
        },
      )),
    ]),
  );
}