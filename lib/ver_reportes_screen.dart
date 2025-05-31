import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VerReportesScreen extends StatefulWidget {
  const VerReportesScreen({super.key});

  @override
  State<VerReportesScreen> createState() => _VerReportesScreenState();
}

class _VerReportesScreenState extends State<VerReportesScreen> {
  String _estadoSeleccionado = 'todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis reportes'),
        actions: [
          DropdownButton<String>(
            value: _estadoSeleccionado,
            items: ['todos', 'pendiente', 'resuelto']
                .map((estado) => DropdownMenuItem(
              value: estado,
              child: Text(estado[0].toUpperCase() + estado.substring(1)),
            ))
                .toList(),
            onChanged: (valor) {
              setState(() {
                _estadoSeleccionado = valor!;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reportes')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar reportes'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs.where((doc) {
            if (_estadoSeleccionado == 'todos') return true;
            final estado = doc['estado'] ?? 'pendiente';
            return estado == _estadoSeleccionado;
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No hay reportes'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final tipo = data['tipo'] ?? 'Desconocido';
              final ubicacion = data['ubicacion'] ?? 'Sin ubicación';
              final estado = data['estado'] ?? 'pendiente';
              final fecha = (data['fecha'] as Timestamp).toDate();
              final fechaTexto = DateFormat('dd/MM/yyyy HH:mm').format(fecha);
              final imagenURL = data['fotoURL'];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: const Icon(Icons.report),
                  title: Text('$tipo - $estado'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ubicacion),
                      Text(fechaTexto),
                      if (imagenURL != null && imagenURL != '')
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.network(imagenURL, height: 100),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirmar = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('¿Eliminar reporte?'),
                          content: const Text('Esta acción no se puede deshacer.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
                          ],
                        ),
                      );

                      if (confirmar == true) {
                        await FirebaseFirestore.instance.collection('reportes').doc(doc.id).delete();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte eliminado')));
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
