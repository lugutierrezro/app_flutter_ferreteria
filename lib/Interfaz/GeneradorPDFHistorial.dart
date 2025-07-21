import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../Entidades/HistorialVenta.dart';

class GeneradorPDFHistorial {
  static Future<void> generarPDF(List<Historialventa> ventas) async {
    final pdf = pw.Document();
    final formatoFecha = DateFormat('dd/MM/yyyy');

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Center(
                child: pw.Text(
                  'Historial de Ventas',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Fecha',
                  'Hora',
                  'Cliente',
                  'Vendedor',
                  'Doc',
                  'Total (S/)',
                ],
                data:
                    ventas.map((venta) {
                      return [
                        formatoFecha.format(DateTime.parse(venta.fecha)),
                        venta.hora,
                        venta.nombreCliente,
                        venta.nombreUsuario,
                        '${venta.tipoDocumento} ${venta.numDocumento}',
                        venta.total.toStringAsFixed(2),
                      ];
                    }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
                cellStyle: pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: pw.FixedColumnWidth(60),
                  1: pw.FixedColumnWidth(45),
                  2: pw.FixedColumnWidth(100),
                  3: pw.FixedColumnWidth(100),
                  4: pw.FixedColumnWidth(90),
                  5: pw.FixedColumnWidth(60),
                },
                border: pw.TableBorder.all(color: PdfColors.grey),
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Fecha de generación: ${formatoFecha.format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
            ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
