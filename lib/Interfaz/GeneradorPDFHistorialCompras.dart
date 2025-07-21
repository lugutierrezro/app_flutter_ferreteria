import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import '../Entidades/HistorialCompra.dart';

class GeneradorPDFHistorialCompras {
  static Future<void> generarPDF(List<HistorialCompra> compras) async {
    final pdf = pw.Document();
    final formato = DateFormat('dd/MM/yyyy HH:mm');

    pdf.addPage(
      pw.MultiPage(
        build:
            (context) => [
              pw.Center(
                child: pw.Text(
                  'Historial de Compras',
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
                  'Doc. Tipo',
                  'N° Documento',
                  'Subtotal (S/)',
                  'IGV (S/)',
                  'Total (S/)',
                  'Usuario',
                  'Proveedor',
                ],
                data:
                    compras.map((compra) {
                      return [
                        compra.fecha,
                        compra.hora,
                        compra.tipoDocumento,
                        compra.numDocumento,
                        compra.subtotal.toStringAsFixed(2),
                        compra.igv.toStringAsFixed(2),
                        compra.total.toStringAsFixed(2),
                        compra.nombreUsuario,
                        compra.nombreProveedor,
                      ];
                    }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                ),
                cellStyle: pw.TextStyle(fontSize: 8),
                border: pw.TableBorder.all(color: PdfColors.grey),
                cellAlignment: pw.Alignment.centerLeft,
              ),
              pw.SizedBox(height: 20),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'Fecha de generación: ${formato.format(DateTime.now())}',
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
