import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
// ...otros imports...
import 'package:url_launcher/url_launcher.dart';
import '../config.dart';

class ReporteScreen extends StatefulWidget {
  const ReporteScreen({super.key});

  @override
  State<ReporteScreen> createState() => _ReporteScreenState();
}

class _ReporteScreenState extends State<ReporteScreen> {
  final _formKey = GlobalKey<FormState>();
  String tipo = 'Bache';
  String ubicacion = '';
  String descripcion = '';
  File? imagen;

  final List<String> tiposProblema = [
    'Bache',
    'Luminaria',
    'Basura',
    'Fuga de agua',
    'Otro',
  ];

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.storage,
      Permission.photos,
    ].request();
  }

  Future<void> _pickImage() async {
    await _requestPermissions();
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        imagen = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final ref = FirebaseStorage.instance
          .ref('reportes/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('❌ Error al subir imagen: $e');
      return null;
    }
  }

  Future<void> _enviarReporte() async {
    String? imageUrl;
    if (imagen != null) {
      imageUrl = await _uploadImage(imagen!);
    }

    await FirebaseFirestore.instance.collection('reportes').add({
      'tipo': tipo,
      'ubicacion': ubicacion,
      'descripcion': descripcion,
      'fotoURL': imageUrl ?? '',
      'fecha': DateTime.now(),
      'hash': '#SOYVOLUNTARIOCEFODEH',
    });

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reporte enviado'),
        content: const Text('¿Deseas compartirlo por WhatsApp?'),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Sí'),
            onPressed: () {
              Navigator.pop(context);
              _enviarPorWhatsapp(imageUrl);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _enviarPorWhatsapp(String? imageUrl) async {
    final mensaje = '''
🚨 Nuevo reporte de problema

📌 Tipo: $tipo
📍 Ubicación: $ubicacion
📝 Descripción: $descripcion
${imageUrl != null ? '📷 Imagen: $imageUrl' : ''}
#VecinoSeguro
''';

    // Usamos kWhatsAppNumber desde config.dart en lugar de un número fijo
    final numero = kWhatsAppNumber;
    final url = Uri.parse('https://wa.me/$numero?text=${Uri.encodeComponent(mensaje)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo reporte')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: tipo,
                items: tiposProblema
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => tipo = val!),
                decoration: const InputDecoration(labelText: 'Tipo de problema'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Ubicación'),
                onChanged: (val) => ubicacion = val,
                validator: (val) =>
                val == null || val.isEmpty ? 'Escribe la ubicación' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                onChanged: (val) => descripcion = val,
                validator: (val) =>
                val == null || val.isEmpty ? 'Agrega una descripción' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              imagen != null
                  ? Image.file(imagen!, height: 150)
                  : TextButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Tomar foto (opcional)'),
                onPressed: _pickImage,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _enviarReporte();
                  }
                },
                child: const Text('Enviar reporte'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
