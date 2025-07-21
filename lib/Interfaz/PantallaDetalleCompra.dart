import 'package:flutter/material.dart';
import '../Entidades/Suministro.dart';
import '../Controlador/ProveedorController.dart';
import '../Entidades/DetalleCompra.dart';
import '../Entidades/Proveedor.dart';
import '../Controlador/DetalleCompraController.dart';
import '../Interfaz/GenerarBoletaCompra.dart'; // Asegúrate de importar correctamente tu clase de PDF

class DetalleCompraScreen extends StatelessWidget {
  final Suministro suministro;

  const DetalleCompraScreen({Key? key, required this.suministro})
    : super(key: key);

  Future<Proveedor> _obtenerProveedor() async {
    final proveedorApi = ProveedorApi();
    print('🔎 ID recibido del suministro: ${suministro.proveedor}');
    return await proveedorApi.obtenerProveedorPorNombre(suministro.proveedor);
  }

  @override
  Widget build(BuildContext context) {
    final detalleCompraController = DetalleCompraController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DETALLE DE COMPRA'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: ListView(
          children: [
            _buildProveedorHeader(),
            const SizedBox(height: 16),
            _buildDivider(),
            _buildSectionTitle('Información del Proveedor'),
            _buildTwoColumnInfo('Proveedor:', suministro.proveedor),
            _buildTwoColumnInfo('Fecha:', suministro.fecha),
            const SizedBox(height: 24),
            _buildSectionTitle('Detalle de Productos'),
            FutureBuilder<List<MDetalleCompra>>(
              future: detalleCompraController.listarDetalle(
                suministro.idSuministro,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error al cargar detalles: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No hay detalles para esta compra.');
                }

                final detalles = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductTable(detalles),
                    const SizedBox(height: 20),
                    _buildTotals(suministro),
                    const SizedBox(height: 20),

                    // ✅ BOTÓN EMITIR BOLETA
                    ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final proveedor = await _obtenerProveedor();
                          final productos =
                              detalles.map((d) {
                                return {
                                  'nombre':
                                      'Producto ${d.idProducto}', // Cambiar si tienes nombre real
                                  'cantidad': d.cantidad,
                                  'precio': d.precio,
                                  'subtotal': d.total,
                                };
                              }).toList();

                          await GenerarBoletaCompra.generar(
                            proveedor: proveedor,
                            productos: productos,
                            subtotal: suministro.subtotal,
                            igv: suministro.igv,
                            total: suministro.total,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ Error al generar boleta: $e'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Emitir Boleta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
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

  Widget _buildProveedorHeader() {
    return FutureBuilder<Proveedor>(
      future: _obtenerProveedor(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('❌ Error al cargar proveedor: ${snapshot.error}');
        } else if (!snapshot.hasData) {
          return const Text('❌ Proveedor no encontrado');
        }

        final proveedorData = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PROVEEDOR:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Nombre: ${proveedorData.nombre} ${proveedorData.apellido}'),
            Text('DNI: ${proveedorData.dni}'),
            Text('RUC: ${proveedorData.ruc}'),
            Text('Dirección: ${proveedorData.direccion}'),
            Text('Teléfono: ${proveedorData.telefono}'),
          ],
        );
      },
    );
  }

  Widget _buildTwoColumnInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, textAlign: TextAlign.right)),
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
        color: Colors.indigo,
      ),
    );
  }

  Widget _buildProductTable(List<MDetalleCompra> detalles) {
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
      decoration: BoxDecoration(color: Color(0xFFE8EAF6)),
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

  TableRow _buildTableRow(MDetalleCompra d) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(d.idProducto.toString()),
        ),
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

  Widget _buildTotals(Suministro suministro) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.indigo),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalRow('Subtotal:', suministro.subtotal),
            _buildTotalRow('IGV (18%):', suministro.igv),
            const Divider(),
            _buildTotalRow('TOTAL:', suministro.total, isBold: true),
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
