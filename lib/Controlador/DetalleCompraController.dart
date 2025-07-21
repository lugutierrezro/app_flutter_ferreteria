import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Entidades/DetalleCompra.dart';
import '../Entidades/HistorialCompra.dart';

class DetalleCompraController {
  final String baseUrl =
      'https://api-php-47xm.onrender.com/suministro-detalleSuministro.php';

  Future<List<MDetalleCompra>> listarDetalle(int idSuministro) async {
    final response = await http.get(
      Uri.parse('$baseUrl?id=$idSuministro&action=listar_detalle'),
    );
    print('Respuesta del servidor: ${response.body}');

    final data = jsonDecode(response.body);

    if (data is List) {
      return data.map((item) => MDetalleCompra.fromJson(item)).toList();
    } else {
      throw Exception('Respuesta inválida del servidor');
    }
  }

  Future<List<HistorialCompra>> historialCompras() async {
    final response = await http.get(
      Uri.parse('$baseUrl?action=historial_compras'),
    );
    print('Historial compras: ${response.body}');
    final data = jsonDecode(response.body);
    if (data is List) {
      return data.map((item) => HistorialCompra.fromJson(item)).toList();
    } else {
      throw Exception('Error al obtener historial de compras');
    }
  }
}
