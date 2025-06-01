import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'reporte_screen.dart';
import 'ver_reportes_screen.dart';
import 'acerca_cefodeh_screen.dart';

Future<void> autenticarAnonimamente() async {
  final auth = FirebaseAuth.instance;

  if (auth.currentUser == null) {
    try {
      await auth.signInAnonymously().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('FirebaseAuth timeout');
        },
      );
    } catch (e) {
      debugPrint('❌ Error al autenticar anónimamente: $e');
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await autenticarAnonimamente();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vecino Seguro',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icon/icono.png', height: 120),
            const SizedBox(height: 20),
            const Text(
              'CEFODEH',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Centro de Formación para el Desarrollo Humano'),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vecino Seguro')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReporteScreen()),
              ),
              child: const Text('Crear reporte'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VerReportesScreen()),
              ),
              child: const Text('Ver reportes'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AcercaCefodehScreen()),
              ),
              child: const Text('Acerca de CEFODEH'),
            ),
          ],
        ),
      ),
    );
  }
}
