import 'package:flutter/material.dart';
import '../Entidades/Venta.dart';
import '../Entidades/DetalleVenta.dart';
import '../Controlador/DetalleVentaController.dart';
import '../Interfaz/GenerarBoleta.dart';

class DetalleVentaScreen extends StatelessWidget {
  final Venta venta;

  const DetalleVentaScreen({Key? key, required this.venta}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DetalleVentaController detalleVentaController =
        DetalleVentaController();

    return Scaffold(
      appBar: AppBar(
        title: Text('BOLETA DE VENTA'),
        backgroundColor: Colors.teal[700],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: ListView(
          children: [
            // Encabezado Empresa
            _buildEmpresaHeader(),

            const SizedBox(height: 16),
            _buildDivider(),

            // Info de la venta
            _buildSectionTitle('Información del Cliente'),
            _buildTwoColumnInfo('Cliente:', venta.cliente),
            _buildTwoColumnInfo('Fecha:', venta.fecha),

            const SizedBox(height: 24),
            _buildSectionTitle('Detalle de Productos'),

            FutureBuilder<List<DetalleVenta>>(
              future: detalleVentaController.listarDetalle(venta.idVenta),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error al cargar detalles: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay detalles para esta venta.');
                }

                final detalles = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductTable(detalles),
                    const SizedBox(height: 20),
                    _buildTotals(venta),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Emitir Boleta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        final detalles = await detalleVentaController
                            .listarDetalle(venta.idVenta);

                        final productos =
                            detalles.map((d) {
                              return {
                                'nombre': d.producto,
                                'cantidad': d.cantidad,
                                'precio': d.precio,
                                'subtotal': d.total,
                              };
                            }).toList();

                        final double subtotal = venta.subtotal;
                        final double igv = venta.igv;
                        final double total = venta.total;

                        await GenerarBoleta.generar(
                          clienteNombre: venta.cliente ?? '---',
                          productos: productos,
                          subtotal: subtotal,
                          igv: igv,
                          total: total,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpresaHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'FERRETERIA PINOTELLO S.A.C.',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text('MZA. D LOTE.17 ASOC. VIV RES. LOS PINOS'),
        Text('LIMA - LIMA - SANTA ANITA'),
        Text('Telf: 3543113 / 999891320 / 994136039'),
        Text('Correo: pinotellosac@hotmail.com'),
        Text('R.U.C.: 20478051809'),
      ],
    );
  }

  Widget _buildTwoColumnInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }

  Widget _buildProductTable(List<DetalleVenta> detalles) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        _buildTableHeader(),
        ...detalles.map((d) => _buildTableRow(d)).toList(),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return const TableRow(
      decoration: BoxDecoration(color: Color(0xFFE0F2F1)),
      children: [
        Padding(
          padding: EdgeInsets.all(6),
          child: Text(
            'Producto',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(6),
          child: Text(
            'Cantidad',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(6),
          child: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(6),
          child: Text(
            'Subtotal',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRow(DetalleVenta d) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(6), child: Text(d.producto)),
        Padding(padding: const EdgeInsets.all(6), child: Text('${d.cantidad}')),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text('S/. ${d.precio.toStringAsFixed(2)}'),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text('S/. ${d.total.toStringAsFixed(2)}'),
        ),
      ],
    );
  }

  Widget _buildTotals(Venta venta) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.teal),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalRow('Subtotal:', venta.subtotal),
            _buildTotalRow('IGV (18%):', venta.igv),
            const Divider(),
            _buildTotalRow('TOTAL:', venta.total, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'S/. ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(thickness: 1.5);
  }
}
