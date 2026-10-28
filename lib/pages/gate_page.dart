import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'central_page.dart';

class GatePage extends StatelessWidget {
  const GatePage({super.key});
  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasData) return const CentralPage();
      return Scaffold(
        appBar: AppBar(title: const Text('Central de Achados e Perdidos')),
        body: Center(child: FilledButton.icon(
          icon: const Icon(Icons.login), label: const Text('Entrar com Google'),
          onPressed: () async {
            try {
              final provider = GoogleAuthProvider();
              await FirebaseAuth.instance.signInWithPopup(provider);
            } catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Falha no login: $e')));
            }
          },
        )),
      );
    },
  );
}
