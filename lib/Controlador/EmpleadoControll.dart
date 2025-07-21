import 'dart:convert';
import 'package:http/http.dart' as http;

class EmpleadoController {
  // Dirección del API PHP local (cambia según entorno)
  final String baseUrl = "https://api-php-47xm.onrender.com/EmpleadoApi.php";

  /// Buscar empleados por nombre, apellido o usuario
  Future<List<dynamic>> buscarEmpleado(String buscar) async {
    final url = Uri.parse("$baseUrl?action=buscar_empleado&buscar=$buscar");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Error al buscar empleados");
    }
  }

  /// Guardar nuevo empleado (incluye datos personales y de usuario)
  Future<String> guardarEmpleado(Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl?action=guardar_empleado");

    print("ENVIANDO DATOS: ${json.encode(data)}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    print("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      return res['mensaje'] ?? "Empleado guardado correctamente.";
    } else {
      throw Exception("Error al guardar empleado");
    }
  }

  
  Future<String> eliminarEmpleado(int idUsuario) async {
    final url = Uri.parse("$baseUrl?action=eliminar_empleado");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'idUsuario': idUsuario}),
    );

    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      return res['mensaje'] ?? "Empleado eliminado correctamente.";
    } else {
      throw Exception("Error al eliminar empleado");
    }
  }

  /// Iniciar sesión (verificación contra sp_login)
  Future<Map<String, dynamic>> loginEmpleado(
    String usuario,
    String password,
  ) async {
    // Forzar autenticación sin verificar base de datos
    if (usuario == "admin" && password == "123456") {
      return {
        "usuario": "admin",
        "rol": "administrador",
        "mensaje": "Inicio forzado sin verificación",
      };
    }

    // Aquí iría el login real si no es modo forzado
    final url = Uri.parse("$baseUrl?action=login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({'usuario': usuario, 'password': password}),
    );

    if (response.statusCode == 200) {
      final res = json.decode(response.body);
      if (res is Map && res.containsKey("error")) {
        throw Exception(res["error"]);
      }
      return res;
    } else {
      throw Exception("Error al iniciar sesión");
    }
  }
}
