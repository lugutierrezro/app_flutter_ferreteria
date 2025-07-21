import 'package:flutter/material.dart';
import 'package:proyecto0/Entidades/Producto.dart';
import 'package:proyecto0/Controlador/ProductoController.dart';
import 'package:proyecto0/Interfaz/PantallaCarta.dart';

class PantallaMostrarProducto extends StatefulWidget {
  const PantallaMostrarProducto({Key? key}) : super(key: key);

  @override
  _PantallaMostrarProductoState createState() =>
      _PantallaMostrarProductoState();
}

class _PantallaMostrarProductoState extends State<PantallaMostrarProducto> {
  final ProductoController _productoController = ProductoController();
  List<Producto> _productos = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    try {
      final productos = await ProductoController().listarProductos();
      setState(() => _productos = productos);
    } catch (e) {
      print('Error al cargar productos: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar productos')));
    }
  }

  void _irAtras() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PantallaDashboard()),
    );
  }

  void _mostrarOpciones(Producto producto) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar'),
                onTap: () {
                  Navigator.pop(context);
                  _editarProducto(producto);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Eliminar'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmarEliminar(producto.idProducto);
                },
              ),
            ],
          ),
    );
  }

  void _confirmarEliminar(String idProducto) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar Producto'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar este producto?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _productoController.eliminarProducto(idProducto);
                  Navigator.pop(context);
                  _cargarProductos();
                },
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }

  void _editarProducto(Producto producto) {
    final nombreCtrl = TextEditingController(text: producto.nombre);
    final precioCtrl = TextEditingController(
      text: producto.precioVenta.toString(),
    );
    final cantidadCtrl = TextEditingController(
      text: producto.cantidad.toString(),
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Editar Producto'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: precioCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Precio Venta',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: cantidadCtrl,
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  producto.nombre = nombreCtrl.text;
                  producto.precioVenta = double.tryParse(precioCtrl.text) ?? 0;
                  producto.cantidad = int.tryParse(cantidadCtrl.text) ?? 0;
                  await _productoController.editarProducto(producto);
                  Navigator.pop(context);
                  _cargarProductos();
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _irAtras();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lista de Productos'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _irAtras,
          ),
        ),
        body:
            _productos.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: _productos.length,
                  itemBuilder: (context, index) {
                    final p = _productos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        onLongPress: () => _mostrarOpciones(p),
                        title: Text(p.nombre),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${p.idProducto}'),
                            Text(
                              'Precio Venta: S/ ${p.precioVenta.toStringAsFixed(2)}',
                            ),
                            Text('Cantidad: ${p.cantidad}'),
                            Text(
                              'Ingreso: ${p.fechaIngreso.toIso8601String().split('T').first}',
                            ),
                            Text(
                              'Vencimiento: ${p.fechaVencimiento.toIso8601String().split('T').first}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
