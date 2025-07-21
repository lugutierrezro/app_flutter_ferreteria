import 'package:flutter/material.dart';
import '../Controlador/DetalleVentaController.dart';
import '../Entidades/HistorialVenta.dart';
import 'package:intl/intl.dart';
import '../Interfaz/GeneradorPDFHistorial.dart'; // <- Asegúrate que la ruta esté bien

class PantallaHistorialVentas extends StatefulWidget {
  @override
  _PantallaHistorialVentasState createState() =>
      _PantallaHistorialVentasState();
}

class _PantallaHistorialVentasState extends State<PantallaHistorialVentas> {
  final DetalleVentaController controller = DetalleVentaController();
  late Future<List<Historialventa>> _futureVentas;

  @override
  void initState() {
    super.initState();
    _futureVentas = controller.historialVentas();
  }

  String formatFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Ventas'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar PDF',
            onPressed: () async {
              final ventas = await _futureVentas;
              await GeneradorPDFHistorial.generarPDF(ventas);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Historialventa>>(
        future: _futureVentas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay ventas registradas.'));
          }

          final ventas = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: ventas.length,
            itemBuilder: (context, index) {
              final venta = ventas[index];

              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${venta.tipoDocumento} - ${venta.numDocumento}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            'S/ ${venta.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.grey[700]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Cliente: ${venta.nombreCliente}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_pin_circle_outlined,
                            color: Colors.grey[700],
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Vendedor: ${venta.nombreUsuario}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey[700]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Fecha: ${formatFecha(venta.fecha)} ${venta.hora}',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
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
