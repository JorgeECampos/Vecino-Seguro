import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AcercaCefodehScreen extends StatelessWidget {
  const AcercaCefodehScreen({super.key});

  void _abrirWhatsApp() async {
    final url = Uri.parse("https://wa.me/524626214305");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _enviarCorreo() async {
    final Uri email = Uri(
      scheme: 'mailto',
      path: 'contacto@cefodeh.org',
      query: 'subject=Contacto desde la app Vecino Seguro',
    );
    if (await canLaunchUrl(email)) {
      await launchUrl(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acerca de CEFODEH')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CEFODEH',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'El Centro de Formación para el Desarrollo Humano (CEFODEH) es una organización dedicada a impulsar la participación ciudadana, la formación comunitaria y la mejora del entorno urbano y social.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Esta aplicación es una herramienta desarrollada por y para ciudadanos comprometidos, con el objetivo de reportar y dar seguimiento a problemas en su comunidad.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const Text(
              'Gracias por ser parte del cambio. 💪',
              style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            const Text(
              'Contacto:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('WhatsApp: +52 1 55 4583 4548'),
              onTap: _abrirWhatsApp,
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('Correo: cefodeh@cefodeh.org'),
              onTap: _enviarCorreo,
            ),
          ],
        ),
      ),
    );
  }
}
