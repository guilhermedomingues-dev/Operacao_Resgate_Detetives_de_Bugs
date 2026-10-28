import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'pages/gate_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(DevicePreview(builder: (context) => const CentralApp()));
}

class CentralApp extends StatelessWidget {
  const CentralApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Central de Achados',
    debugShowCheckedModeBanner: false,
    locale: DevicePreview.locale(context),
    builder: DevicePreview.appBuilder,
    theme: ThemeData(colorSchemeSeed: Colors.deepOrange, useMaterial3: true),
    home: const GatePage(),
  );
}
