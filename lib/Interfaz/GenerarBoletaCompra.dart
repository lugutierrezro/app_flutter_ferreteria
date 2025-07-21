import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:proyecto0/Entidades/Proveedor.dart'; // Asegúrate de tener esta importación

class GenerarBoletaCompra {
  static Future<void> generar({
    required Proveedor proveedor,
    required List<Map<String, dynamic>> productos,
    required double igv,
    required double total,
    double? subtotal, // Se calcula si no se pasa
  }) async {
    final pdf = pw.Document();

    // Carga el logo
    final ByteData data = await rootBundle.load(
      'assets/fuentes/FerreteriaLogo.png',
    );
    final Uint8List logoBytes = data.buffer.asUint8List();

    // Calcular subtotal si no se pasa como parámetro
    final double calculatedSubtotal =
        subtotal ??
        productos.fold(0.0, (sum, item) => sum + (item['subtotal'] as double));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado con proveedor
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Container(
                    width: 90,
                    height: 90,
                    child: pw.Image(pw.MemoryImage(logoBytes)),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          proveedor.nombre.toUpperCase(),
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text('Dirección: ${proveedor.direccion}'),
                        pw.Text('R.U.C.: ${proveedor.ruc}'),
                        pw.Text('Teléfono: ${proveedor.telefono}'),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Divider(),

              // Título
              pw.Center(
                child: pw.Text(
                  'BOLETA DE COMPRA',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),

              pw.SizedBox(height: 16),

              // Datos del comprador (ferretería)
              pw.Text('Comprador: FERRETERÍA PINOTELLO S.A.C'),
              pw.Text('Dirección: MZA. D LOTE.17 ASOC. VIV RES. LOS PINOS'),
              pw.Text('R.U.C.: 20478051809'),
              pw.Text(
                'Fecha: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              ),

              pw.SizedBox(height: 20),

              // Detalle de productos
              pw.Text(
                'Detalle de productos:',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Table.fromTextArray(
                border: pw.TableBorder.all(
                  width: 0.5,
                  color: PdfColors.grey700,
                ),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 11),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(2),
                  3: const pw.FlexColumnWidth(2),
                },
                headers: ['Producto', 'Cantidad', 'Precio', 'Subtotal'],
                data:
                    productos.map((producto) {
                      return [
                        producto['nombre'],
                        producto['cantidad'].toString(),
                        'S/. ${producto['precio'].toStringAsFixed(2)}',
                        'S/. ${producto['subtotal'].toStringAsFixed(2)}',
                      ];
                    }).toList(),
              ),

              pw.SizedBox(height: 24),

              // Totales
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Container(
                    width: 200,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey700),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Subtotal:'),
                            pw.Text(
                              'S/. ${calculatedSubtotal.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('IGV (18%):'),
                            pw.Text('S/. ${igv.toStringAsFixed(2)}'),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'TOTAL:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              'S/. ${total.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Mostrar PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
