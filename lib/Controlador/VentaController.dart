import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Entidades/Venta.dart';

class VentaController {
  final String baseUrl =
      'https://api-php-47xm.onrender.com/venta-detalleventa.php';

  Future<List<Venta>> listarVentas() async {
    final response = await http.get(Uri.parse('$baseUrl?action=listar_ventas'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Venta.fromJson(e)).toList();
    } else {
      throw Exception('Error al listar ventas');
    }
  }

  Future<bool> registrarVenta(Map<String, dynamic> ventaData) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=registrar_venta'),
      body: jsonEncode(ventaData),
      headers: {'Content-Type': 'application/json'},
    );

    final Map<String, dynamic> decoded = jsonDecode(response.body);
    print('Respuesta del servidor: $decoded'); 
    return decoded['mensaje'] != null;
  }
  
  Future<List<Venta>> buscarVenta(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl?action=buscar_venta&buscar=$query'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Venta.fromJson(e)).toList();
    } else {
      throw Exception('Error al buscar venta');
    }
  } 

  Future<bool> eliminarVenta(int idVenta) async {
    final response = await http.post(
      Uri.parse('$baseUrl?action=eliminar_venta'),
      body: jsonEncode({'idVenta': idVenta}),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body)['mensaje'] != null;
  }
}
