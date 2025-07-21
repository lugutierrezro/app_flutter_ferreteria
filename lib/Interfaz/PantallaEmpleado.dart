import 'package:flutter/material.dart';
import 'package:proyecto0/Controlador/EmpleadoControll.dart';
import 'package:proyecto0/Entidades/Empleado.dart';
import 'package:proyecto0/Interfaz/PantallaMenuLateral.dart';
import 'package:proyecto0/Interfaz/PantallaCarta.dart';
import 'package:proyecto0/Interfaz/PantallaRegistrarEmpleado.dart';

class PantallaEmpleado extends StatefulWidget {
  const PantallaEmpleado({super.key});

  @override
  State<PantallaEmpleado> createState() => _PantallaEmpleadoState();
}

class _PantallaEmpleadoState extends State<PantallaEmpleado> {
  List<dynamic> _empleados = [];
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
  }

  Future<void> _cargarEmpleados() async {
    try {
      final empleadosJson = await EmpleadoController().buscarEmpleado('');
      final empleados =
          empleadosJson
              .map<Empleado>((json) => Empleado.fromJson(json))
              .toList();

      setState(() {
        _empleados = empleados;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar empleados: $e')));
    }
  }

  Future<void> eliminarEmpleado(int idUsuario) async {
    try {
      await EmpleadoController().eliminarEmpleado(idUsuario);
      await _cargarEmpleados();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Empleado eliminado')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al eliminar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final resultados =
        _empleados.where((emp) {
          final nombre = emp.nombre?.toLowerCase() ?? '';
          final apellido = emp.apellido?.toLowerCase() ?? '';
          final dni = emp.dni?.toLowerCase() ?? '';
          final nombreCompleto = '$nombre $apellido';
          final busq = _busqueda.toLowerCase();
          return nombreCompleto.contains(busq) || dni.contains(busq);
        }).toList();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PantallaDashboard()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gestión de Empleados"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PantallaDashboard(),
                ),
              );
            },
          ),
        ),
        drawer: const MenuLateral(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Buscar por nombre o DNI',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => setState(() => _busqueda = value),
              ),
            ),
            Expanded(
              child:
                  resultados.isEmpty
                      ? const Center(
                        child: Text("No se encontraron empleados."),
                      )
                      : ListView.builder(
                        itemCount: resultados.length,
                        itemBuilder: (context, index) {
                          final emp = resultados[index];
                          final nombre = emp.nombre;
                          final apellido = emp.apellido;
                          final dni = emp.dni;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  nombre.isNotEmpty ? nombre[0] : '?',
                                ),
                              ),
                              title: Text('$nombre $apellido'),
                              subtitle: Text('DNI: $dni'),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'editar') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (
                                              context,
                                            ) => PantallaRegistrarEmpleado(
                                              key: UniqueKey(),
                                              empleado:
                                                  emp.toJson(), // emp es un Empleado, y así debe esperarlo la pantalla
                                            ),
                                      ),
                                    ).then((_) => _cargarEmpleados());
                                  } else if (value == 'eliminar') {
                                    eliminarEmpleado(
                                      int.tryParse(emp.idUsuario) ?? 0,
                                    );
                                  }
                                },
                                itemBuilder:
                                    (context) => const [
                                      PopupMenuItem(
                                        value: 'editar',
                                        child: Text('Editar'),
                                      ),
                                      PopupMenuItem(
                                        value: 'eliminar',
                                        child: Text('Eliminar'),
                                      ),
                                    ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const PantallaRegistrarEmpleado(),
              ),
            ).then((_) => _cargarEmpleados());
          },
          child: const Icon(Icons.person_add),
          tooltip: "Agregar nuevo empleado",
        ),
      ),
    );
  }
}
