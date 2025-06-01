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
            onChanged: (valor) {
              if (valor != null) {
                setState(() => _estadoSeleccionado = valor);
              }
            },
            items: ['todos', 'pendiente', 'resuelto']
                .map((estado) => DropdownMenuItem(
              value: estado,
              child: Text(estado[0].toUpperCase() + estado.substring(1)),
            ))
                .toList(),
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

          // Filtramos documentos según el estado
          final reportes = snapshot.data!.docs.where((doc) {
            // Obtenemos el Map de datos
            final data = doc.data() as Map<String, dynamic>;

            // Si el campo 'estado' no existe, asumimos 'pendiente'
            final estado = data.containsKey('estado') ? data['estado'] as String : 'pendiente';

            return _estadoSeleccionado == 'todos' || estado == _estadoSeleccionado;
          }).toList();

          if (reportes.isEmpty) {
            return const Center(child: Text('No hay reportes'));
          }

          return ListView.builder(
            itemCount: reportes.length,
            itemBuilder: (context, index) {
              final doc = reportes[index];
              final data = doc.data() as Map<String, dynamic>;

              final tipo = data['tipo'] ?? 'Desconocido';
              final ubicacion = data['ubicacion'] ?? 'Sin ubicación';

              // Aquí hacemos la comprobación de existencia de 'estado'
              final estado = data.containsKey('estado') ? data['estado'] as String : 'pendiente';

              // Convertimos la marca de tiempo a DateTime y lo formateamos
              final fecha = (data['fecha'] as Timestamp?)?.toDate();
              final fechaTexto = fecha != null
                  ? DateFormat('dd/MM/yyyy HH:mm').format(fecha)
                  : 'Sin fecha';

              final imagenURL = data['fotoURL'] as String?;

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
                      // Mostramos la imagen solo si la URL existe y no está vacía
                      if (imagenURL != null && imagenURL.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.network(
                            imagenURL,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('No se pudo cargar imagen');
                            },
                          ),
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
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );

                      if (confirmar == true) {
                        await FirebaseFirestore.instance
                            .collection('reportes')
                            .doc(doc.id)
                            .delete();

                        // Solo mostramos el SnackBar si el widget sigue montado
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reporte eliminado')),
                          );
                        }
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
