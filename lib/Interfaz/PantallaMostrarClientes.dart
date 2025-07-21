import 'package:flutter/material.dart';
import 'package:proyecto0/Interfaz/PantallaMenuLateral.dart';
import 'package:proyecto0/Entidades/Cliente.dart';
import 'package:proyecto0/Controlador/ClienteController.dart';
import 'package:proyecto0/Interfaz/Pantallacliente.dart';
import 'package:proyecto0/Interfaz/PantallaCarta.dart';

class Pantallamostrarclientes extends StatefulWidget {
  const Pantallamostrarclientes({super.key});

  @override
  State<Pantallamostrarclientes> createState() =>
      _PantallamostrarclientesState();
}

class _PantallamostrarclientesState extends State<Pantallamostrarclientes> {
  List<Cliente> _clientes = [];
  List<Cliente> _clientesFiltrados = [];
  bool _cargando = true;
  final TextEditingController _busquedaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarClientes();
    _busquedaController.addListener(_filtrarClientes);
  }

  Future<void> _cargarClientes() async {
    try {
      final datos = await ClienteApi.obtenerClientes();
      setState(() {
        _clientes = datos;
        _clientesFiltrados = datos;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _cargando = false;
      });
      print('Error al cargar clientes: $e');
      _mostrarError("Error: $e");
    }
  }

  void _filtrarClientes() async {
    String query = _busquedaController.text.trim();
    try {
      final filtrados = await ClienteApi.obtenerClientes(query);
      setState(() {
        _clientesFiltrados = filtrados;
      });
    } catch (e) {
      _mostrarError("Error al filtrar");
    }
  }

  Future<void> _eliminarCliente(String? idCliente) async {
    if (idCliente == null || idCliente.isEmpty) {
      _mostrarError("ID de cliente no válido");
      return;
    }

    try {
      bool exito = await ClienteApi.eliminarCliente(idCliente);
      if (exito) {
        _mostrarError("Cliente eliminado correctamente");
        await _cargarClientes();
      } else {
        _mostrarError("No se pudo eliminar el cliente");
      }
    } catch (e) {
      _mostrarError("Error al eliminar: $e");
    }
  }

  void _editarCliente(Cliente cliente) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Pantallacliente(clienteExistente: cliente),
      ),
    );
    await _cargarClientes();
  }

  void _eliminarTodo() async {
    final confirmacion = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Confirmar"),
            content: const Text(
              "¿Estás seguro de eliminar todos los clientes?",
            ),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton(
                child: const Text("Eliminar"),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmacion == true) {
      for (var cliente in _clientes) {
        await ClienteApi.eliminarCliente(cliente.idCliente);
      }
      _cargarClientes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PantallaDashboard()),
        );
        return false;
      },
      child: Scaffold(
        drawer: const MenuLateral(),
        appBar: AppBar(
          title: const Text("Clientes"),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: "Eliminar todos",
              onPressed: _clientes.isEmpty ? null : _eliminarTodo,
            ),
          ],
        ),
        body:
            _cargando
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: _busquedaController,
                        decoration: InputDecoration(
                          hintText: "Buscar por nombre, apellido o DNI",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                          _clientesFiltrados.isEmpty
                              ? const Center(
                                child: Text("No se encontraron clientes"),
                              )
                              : ListView.builder(
                                itemCount: _clientesFiltrados.length,
                                itemBuilder: (context, index) {
                                  final cliente = _clientesFiltrados[index];
                                  return Card(
                                    elevation: 3,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        "${cliente.nombre} ${cliente.apellido}",
                                      ),
                                      subtitle: Text("DNI: ${cliente.dni}"),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.orange,
                                            ),
                                            onPressed:
                                                () => _editarCliente(cliente),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => _eliminarCliente(
                                                  cliente.idCliente,
                                                ),
                                          ),
                                        ],
                                      ),
                                      onTap: () => _mostrarDetalle(cliente),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
      ),
    );
  }

  void _mostrarDetalle(Cliente cliente) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${cliente.nombre} ${cliente.apellido}",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Hoja de vida del cliente",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const Divider(height: 30, thickness: 1),
                  _infoItem(Icons.badge, "DNI", cliente.dni),
                  _infoItem(Icons.business, "RUC", cliente.ruc),
                  _infoItem(Icons.phone, "Teléfono", cliente.telefono),
                  _infoItem(Icons.location_on, "Dirección", cliente.direccion),
                ],
              ),
            ),
          ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.green),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }
}
