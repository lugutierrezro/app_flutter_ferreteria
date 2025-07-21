import 'package:flutter/material.dart';
import '../Controlador/suministro-controller.dart';
import '../Controlador/ProductoController.dart';
import '../Controlador/ProveedorController.dart';
import '../Entidades/Proveedor.dart';
import '../Entidades/Producto.dart';
import '../Interfaz/GenerarBoletaCompra.dart';
import 'package:proyecto0/Entidades/Empleado.dart';
import 'package:proyecto0/Entidades/Sesion.dart';

class RegistrarSuministroScreen extends StatefulWidget {
  @override
  _RegistrarSuministroScreenState createState() =>
      _RegistrarSuministroScreenState();
}

class _RegistrarSuministroScreenState extends State<RegistrarSuministroScreen> {
  final SuministroController _suministroController = SuministroController();
  final ProveedorApi _proveedorController = ProveedorApi();
  final ProductoController _productoController = ProductoController();
  final _formKey = GlobalKey<FormState>();
  final empleado = Sesion().empleadoActual;

  Proveedor? _selectedProveedor;
  String? _selectedProducto;
  int _selectedCantidad = 1;
  List<Map<String, dynamic>> _productos = [];
  List<Map<String, dynamic>> _productosDisponibles = [];
  List<Proveedor> _proveedores = [];

  double _igv = 0.0;
  double _total = 0.0;

  final TextEditingController _igvController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController(
    text: '1',
  );

  @override
  void initState() {
    super.initState();
    _cargarProveedores();
    _cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrar Suministro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Información del Proveedor',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildProveedorDropdown(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Agregar Productos',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildProductoDropdown()),
                          const SizedBox(width: 10),
                          _buildCantidadSelector(),
                          const SizedBox(width: 10),
                          _buildAgregarProductoButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Productos Agregados',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildProductosList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Detalle del Monto',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildIgvField(),
                      const SizedBox(height: 10),
                      _buildTotalField(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildRegistrarButton(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cargarProveedores() async {
    try {
      List<Proveedor> proveedores = await ProveedorApi.obtenerProveedores();
      setState(() {
        _proveedores = proveedores;
      });
    } catch (e) {
      print('Error al cargar proveedores: $e');
    }
  }

  Future<void> _cargarProductos() async {
    try {
      List<Producto> productos = await _productoController.listarProductos();
      setState(() {
        _productosDisponibles =
            productos
                .map(
                  (p) => {
                    'idProducto': p.idProducto,
                    'nombre': p.nombre,
                    'precio': p.precioCompra,
                  },
                )
                .toList();
      });
    } catch (e) {
      print('Error al cargar productos: $e');
    }
  }

  Widget _buildProveedorDropdown() {
    return DropdownButtonFormField<Proveedor>(
      decoration: InputDecoration(
        labelText: 'Seleccionar Proveedor',
        border: OutlineInputBorder(),
      ),
      value: _selectedProveedor,
      items:
          _proveedores.map((proveedor) {
            return DropdownMenuItem<Proveedor>(
              value: proveedor,
              child: Text(proveedor.nombre),
            );
          }).toList(),
      onChanged: (Proveedor? value) {
        setState(() {
          _selectedProveedor = value;
        });
      },
      validator: (value) => value == null ? 'Seleccione un proveedor' : null,
    );
  }

  Widget _buildProductoDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Seleccionar Producto',
        border: OutlineInputBorder(),
      ),
      value: _selectedProducto,
      items:
          _productosDisponibles.map<DropdownMenuItem<String>>((producto) {
            return DropdownMenuItem<String>(
              value: producto['nombre'],
              child: Text(producto['nombre']),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedProducto = value;
        });
      },
      validator: (value) {
        if (_productos.isEmpty && (value == null || value.isEmpty)) {
          return 'Seleccione un producto';
        }
        return null;
      },
    );
  }

  Widget _buildCantidadSelector() {
    return SizedBox(
      width: 130,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () {
              int cantidad = int.tryParse(_cantidadController.text) ?? 1;
              if (cantidad > 1) {
                cantidad--;
                setState(() {
                  _cantidadController.text = cantidad.toString();
                });
              }
            },
          ),
          Expanded(
            child: TextFormField(
              controller: _cantidadController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 6,
                ),
                border: OutlineInputBorder(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              int cantidad = int.tryParse(_cantidadController.text) ?? 1;
              cantidad++;
              setState(() {
                _cantidadController.text = cantidad.toString();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAgregarProductoButton() {
    return ElevatedButton(
      onPressed: _agregarProducto,
      child: Icon(Icons.add_shopping_cart),
    );
  }

  Widget _buildProductosList() {
    return _productos.isNotEmpty
        ? Column(
          children:
              _productos.map((producto) {
                int index = _productos.indexOf(producto);
                return Card(
                  child: ListTile(
                    title: Text(producto['nombre']),
                    subtitle: Text(
                      'Cantidad: ${producto['cantidad']} - Subtotal: S/. ${producto['subtotal'].toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarProducto(index),
                    ),
                  ),
                );
              }).toList(),
        )
        : Text('No hay productos agregados.');
  }

  Widget _buildIgvField() {
    return TextFormField(
      controller: _igvController,
      decoration: InputDecoration(
        labelText: 'IGV',
        border: OutlineInputBorder(),
        suffixText: 'S/.',
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        _igv = double.tryParse(value) ?? 0.0;
        _calcularTotal();
      },
      validator:
          (value) => value == null || value.isEmpty ? 'Ingrese el IGV' : null,
    );
  }

  Widget _buildTotalField() {
    _totalController.text = _total.toStringAsFixed(2);
    return TextFormField(
      controller: _totalController,
      decoration: InputDecoration(
        labelText: 'Total',
        border: OutlineInputBorder(),
      ),
      enabled: false,
    );
  }

  Widget _buildRegistrarButton() {
    return ElevatedButton.icon(
      onPressed: _registrarSuministro,
      icon: Icon(Icons.check),
      label: Text('Registrar Suministro'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  void _agregarProducto() {
    if (_selectedProducto != null && _selectedProducto!.isNotEmpty) {
      final productoSeleccionado = _productosDisponibles.firstWhere(
        (producto) => producto['nombre'] == _selectedProducto,
      );
      int cantidad = int.tryParse(_cantidadController.text) ?? 1;
      double subtotal = productoSeleccionado['precio'] * cantidad;

      setState(() {
        _productos.add({
          'idProducto': productoSeleccionado['idProducto'],
          'nombre': _selectedProducto,
          'cantidad': cantidad,
          'precio': productoSeleccionado['precio'],
          'subtotal': subtotal,
        });
        _selectedProducto = null;
        _selectedCantidad = 1;
        _cantidadController.text = '1';
        _calcularTotal();
      });
    }
  }

  void _eliminarProducto(int index) {
    setState(() {
      _productos.removeAt(index);
      _calcularTotal();
    });
  }

  void _calcularTotal() {
    double totalProductos = _productos.fold(
      0.0,
      (sum, item) => sum + item['subtotal'],
    );
    setState(() {
      _total = totalProductos + _igv;
    });
  }

  String _generarIdDocumento() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final numero = now % 100000;
    final numeroFormateado = numero.toString().padLeft(5, '0');
    return numeroFormateado;
  }

  Future<void> _registrarSuministro() async {
    if (_formKey.currentState!.validate() && _productos.isNotEmpty) {
      final ahora = DateTime.now();

      final suministroData = {
        'fecha':
            '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}',
        'hora':
            '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}:${ahora.second.toString().padLeft(2, '0')}',
        'num_documento':
            'DOC${_generarIdDocumento()}', // Cambiar según sea necesario
        'tipo_documento': 'COMPRA', // Cambiar según sea necesario
        'subtotal': _total - _igv,
        'igv': _igv,
        'total': _total,
        'estado': 'Registrado',
        'idUsuario':
            int.tryParse(empleado?.idEmpleado ?? '') ??
            0, // Cambiar según el usuario actual
        'idProveedor': _selectedProveedor!.idProveedor,
        'productos': _productos.map((p) => p['idProducto'].toString()).toList(),
        'cantidades': _productos.map((p) => p['cantidad'].toString()).toList(),
        'precios': _productos.map((p) => p['precio'].toString()).toList(),
      };

      try {
        final ok = await _suministroController.registrarSuministroCompleto(
          suministroData,
        );
        if (ok) {
          await GenerarBoletaCompra.generar(
            proveedor: _selectedProveedor!, // ← CORREGIDO
            productos: _productos, // ← CORREGIDO
            igv: _igv,
            total: _total,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Suministro registrado exitosamente')),
          );
          Navigator.pop(context); // Regresar a la pantalla anterior
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo registrar el suministro')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar el suministro: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Complete todos los campos y agregue productos.'),
        ),
      );
    }
  }
}
