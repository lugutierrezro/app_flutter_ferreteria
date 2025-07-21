import 'package:flutter/material.dart';
import '../Controlador/DetalleCompraController.dart';
import '../Entidades/HistorialCompra.dart';
import '../Interfaz/GeneradorPDFHistorialCompras.dart';

class PantallaHistorialCompras extends StatefulWidget {
  @override
  _PantallaHistorialComprasState createState() =>
      _PantallaHistorialComprasState();
}

class _PantallaHistorialComprasState extends State<PantallaHistorialCompras> {
  final DetalleCompraController controller = DetalleCompraController();
  late Future<List<HistorialCompra>> _futureCompras;

  @override
  void initState() {
    super.initState();
    _futureCompras = controller.historialCompras();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Compras'),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf),
            tooltip: 'Exportar PDF',
            onPressed: () async {
              final compras = await _futureCompras;
              await GeneradorPDFHistorialCompras.generarPDF(compras);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<HistorialCompra>>(
        future: _futureCompras,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay compras registradas.'));
          }

          final compras = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.grey[300]),
                columns: [
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Hora')),
                  DataColumn(label: Text('Doc. Tipo')),
                  DataColumn(label: Text('N° Doc.')),
                  DataColumn(label: Text('Subtotal (S/)')),
                  DataColumn(label: Text('IGV (S/)')),
                  DataColumn(label: Text('Total (S/)')),
                  DataColumn(label: Text('Usuario')),
                  DataColumn(label: Text('Proveedor')),
                ],
                rows:
                    compras.map((compra) {
                      return DataRow(
                        cells: [
                          DataCell(Text(compra.fecha)),
                          DataCell(Text(compra.hora)),
                          DataCell(Text(compra.tipoDocumento)),
                          DataCell(Text(compra.numDocumento)),
                          DataCell(Text(compra.subtotal.toStringAsFixed(2))),
                          DataCell(Text(compra.igv.toStringAsFixed(2))),
                          DataCell(
                            Text(
                              compra.total.toStringAsFixed(2),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                          DataCell(Text(compra.nombreUsuario)),
                          DataCell(Text(compra.nombreProveedor)),
                        ],
                      );
                    }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
