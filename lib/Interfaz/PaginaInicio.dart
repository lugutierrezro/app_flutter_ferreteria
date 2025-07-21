import 'package:flutter/material.dart';
import 'package:proyecto0/Controlador/EmpleadoControll.dart';
import 'package:proyecto0/Interfaz/PantallaCarta.dart'; // PantallaDashboard aquí
import 'package:proyecto0/Entidades/Sesion.dart';
import 'package:proyecto0/Entidades/Empleado.dart';

class PantallaLogin extends StatefulWidget {
  @override
  _PantallaLoginState createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true; // Para mostrar u ocultar la contraseña

  Future<void> _iniciarSesion() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final usuario = _usuarioController.text.trim();
      final password = _passwordController.text;

      if (usuario.isEmpty || password.isEmpty) {
        setState(() {
          _error = 'Ingrese usuario y contraseña.';
        });
        return;
      }

      final data = await EmpleadoController().loginEmpleado(usuario, password);
      final empleado = Empleado.fromJson(data);
      Sesion().empleadoActual = empleado;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PantallaDashboard()),
      );
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color fondo = const Color.fromARGB(255, 103, 209, 110);

    return Scaffold(
      backgroundColor: fondo,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/fuentes/FerreteriaLogo.png", height: 120),
              const SizedBox(height: 20),
              TextField(
                controller: _usuarioController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 10),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _iniciarSesion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                    ),
                    child: const Text("Iniciar Sesión"),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
