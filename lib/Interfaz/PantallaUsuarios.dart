import 'package:flutter/material.dart';
import '../Controlador/UsuarioController.dart';
import '../Entidades/Empleado.dart';

class PantallaUsuarios extends StatefulWidget {
  @override
  _PantallaUsuariosState createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  final UsuarioController _controller = UsuarioController();
  late Future<List<Empleado>> _futureUsuarios;

  @override
  void initState() {
    super.initState();
    _futureUsuarios = _controller.listarUsuarios();
  }

  Future<void> _actualizarEstado(Empleado emp) async {
    final nuevoEstado = emp.estadoCuenta == '1' ? 2 : 1;

    try {
      final result = await _controller.cambiarEstadoUsuario(
        idUsuario: int.parse(emp.idUsuario),
        estado: nuevoEstado,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['mensaje'] ?? 'Estado actualizado')),
      );

      setState(() {
        _futureUsuarios = _controller.listarUsuarios();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Usuarios del Sistema')),
      body: FutureBuilder<List<Empleado>>(
        future: _futureUsuarios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));

          final usuarios = snapshot.data ?? [];

          if (usuarios.isEmpty)
            return Center(child: Text('No hay usuarios registrados.'));

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final emp = usuarios[index];
              final esHabilitado = emp.estadoCuenta == '1';

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    '${emp.nombre} ${emp.apellido}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Usuario: ${emp.usuario}'),
                        Text('Rol: ${emp.rol}'),
                        Text(
                          'Estado: ${esHabilitado ? 'Habilitado' : 'Deshabilitado'}',
                        ),
                      ],
                    ),
                  ),
                  trailing: Switch(
                    value: esHabilitado,
                    onChanged: (_) => _actualizarEstado(emp),
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
