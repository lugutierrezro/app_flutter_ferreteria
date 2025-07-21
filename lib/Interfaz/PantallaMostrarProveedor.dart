import 'package:flutter/material.dart';
import 'package:proyecto0/Entidades/Proveedor.dart';
import 'package:proyecto0/Controlador/ProveedorController.dart';
import 'package:proyecto0/Interfaz/PantallaRegistrarProveedor.dart';
import 'package:proyecto0/Interfaz/PantallaMenuLateral.dart';

class PantallaListaProveedores extends StatefulWidget {
  const PantallaListaProveedores({super.key});

  @override
  State<PantallaListaProveedores> createState() =>
      _PantallaListaProveedoresState();
}

class _PantallaListaProveedoresState extends State<PantallaListaProveedores> {
  List<Proveedor> _proveedores = [];
  final TextEditingController _buscarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarProveedores();
  }

  Future<void> _cargarProveedores([String buscar = '']) async {
    try {
      final proveedores = await ProveedorApi.obtenerProveedores(buscar);
      setState(() {
        _proveedores = proveedores;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar proveedores: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarProveedor(String idProveedor) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar este proveedor?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmado == true) {
      final exito = await ProveedorApi.eliminarProveedor(idProveedor);
      if (exito) {
        _cargarProveedores();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proveedor eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al eliminar proveedor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editarProveedor(Proveedor proveedor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaProveedor(proveedorExistente: proveedor),
      ),
    ).then((_) => _cargarProveedores());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Proveedores')),
      drawer: const MenuLateral(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _buscarController,
              decoration: InputDecoration(
                labelText: 'Buscar proveedor por nombre',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _buscarController.clear();
                    _cargarProveedores();
                  },
                ),
              ),
              onChanged: (value) {
                _cargarProveedores(value.trim());
              },
            ),
          ),
          Expanded(
            child:
                _proveedores.isEmpty
                    ? const Center(
                      child: Text('No hay proveedores registrados'),
                    )
                    : ListView.builder(
                      itemCount: _proveedores.length,
                      itemBuilder: (context, index) {
                        final proveedor = _proveedores[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          elevation: 4,
                          child: ListTile(
                            leading: const Icon(Icons.store),
                            title: Text(
                              '${proveedor.nombre} ${proveedor.apellido}',
                            ),
                            subtitle: Text(
                              'RUC: ${proveedor.ruc} • Tel: ${proveedor.telefono}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editarProveedor(proveedor),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed:
                                      () => _eliminarProveedor(
                                        proveedor.idProveedor ?? '',
                                      ),
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
            MaterialPageRoute(builder: (context) => const PantallaProveedor()),
          ).then((_) => _cargarProveedores());
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
