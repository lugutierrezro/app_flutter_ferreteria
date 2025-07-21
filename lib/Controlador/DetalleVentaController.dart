import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Entidades/DetalleVenta.dart';
import '../Entidades/HistorialVenta.dart';

class DetalleVentaController {
  final String baseUrl =
      'https://api-php-47xm.onrender.com/venta-detalleventa.php';

  Future<List<DetalleVenta>> listarDetalle(int idVenta) async {
    final response = await http.get(
      Uri.parse('$baseUrl?action=listar_detalle_venta&idVenta=$idVenta'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => DetalleVenta.fromJson(e)).toList();
    } else {
      throw Exception('Error al listar detalle de venta');
    }
  }

  Future<List<Historialventa>> historialVentas() async {
    final url = Uri.parse('$baseUrl?action=historial_ventas');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data is List) {
        return data.map((json) => Historialventa.fromJson(json)).toList();
      } else {
        throw Exception('Respuesta no válida del servidor.');
      }
    } else {
      throw Exception('Error al conectar con el servidor.');
    }
  }
}
