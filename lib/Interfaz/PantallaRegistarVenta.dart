import 'package:flutter/material.dart';
import '../Controlador/VentaController.dart';
import '../Entidades/Venta.dart';
import '../Controlador/ClienteController.dart';
import '../Entidades/Cliente.dart';
import '../Controlador/ProductoController.dart';
import '../Entidades/Producto.dart';
import '../Interfaz/PantallaVenta.dart';
import '../Interfaz/GenerarBoleta.dart';
import 'package:proyecto0/Entidades/Empleado.dart';
import 'package:proyecto0/Entidades/Sesion.dart';

class RegistrarVentaScreen extends StatefulWidget {
  @override
  _RegistrarVentaScreenState createState() => _RegistrarVentaScreenState();
}

class _RegistrarVentaScreenState extends State<RegistrarVentaScreen> {
  final VentaController _ventaController = VentaController();
  final _formKey = GlobalKey<FormState>();
  final ProductoController _productoController = ProductoController();
  final empleado = Sesion().empleadoActual;

  Cliente? _selectedCliente;
  String? _selectedProducto;
  int _selectedCantidad = 1;
  List<Map<String, dynamic>> _productos = [];
  List<Map<String, dynamic>> _productosDisponibles = [];

  double _igv = 0.0;
  double _total = 0.0;
  List<Cliente> _clientes = [];

  final TextEditingController _igvController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarClientes();
    _cargarProductos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrar Venta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildClienteDropdown(),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildProductoDropdown()),
                    SizedBox(width: 10),
                    _buildCantidadSelector(),
                    SizedBox(width: 10),
                    _buildAgregarProductoButton(),
                  ],
                ),
                SizedBox(height: 16),
                _buildProductosList(),
                SizedBox(height: 16),
                _buildIgvField(),
                SizedBox(height: 16),
                _buildTotalField(),
                SizedBox(height: 16),
                _buildRegistrarButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cargarClientes() async {
    try {
      List<Cliente> clientes = await ClienteApi.obtenerClientes();
      setState(() {
        _clientes = clientes;
      });
    } catch (e) {
      print('Error al cargar clientes: $e');
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
                    'precio': p.precioVenta,
                    'cantidad': p.cantidad ?? 0,
                  },
                )
                .toList();
      });
    } catch (e) {
      print('Error al cargar productos: $e');
    }
  }

  Widget _buildClienteDropdown() {
    return DropdownButtonFormField<Cliente>(
      decoration: InputDecoration(
        labelText: 'Seleccionar Cliente',
        border: OutlineInputBorder(),
      ),
      value: _selectedCliente,
      items:
          _clientes.map((cliente) {
            return DropdownMenuItem<Cliente>(
              value: cliente,
              child: Text(cliente.nombre),
            );
          }).toList(),
      onChanged: (Cliente? value) {
        setState(() {
          _selectedCliente = value;
        });
      },
      validator: (value) => value == null ? 'Seleccione un cliente' : null,
    );
  }

  Widget _buildProductoDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Producto',
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
        ),
        SizedBox(height: 8),
        _buildProductoInfoCard(),
      ],
    );
  }

  Widget _buildProductoInfoCard() {
    if (_selectedProducto == null || _selectedProducto!.isEmpty) {
      return SizedBox();
    }

    final producto = _productosDisponibles.firstWhere(
      (p) => p['nombre'] == _selectedProducto,
      orElse: () => <String, Object>{},
    );

    if (producto.isEmpty) return SizedBox();

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Precio: S/. ${producto['precio']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              if (producto.containsKey('cantidad'))
                Text(
                  'Stock: ${producto['cantidad']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCantidadSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () {
            if (_selectedCantidad > 1) {
              setState(() {
                _selectedCantidad--;
              });
            }
          },
        ),
        Text('$_selectedCantidad'),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            setState(() {
              _selectedCantidad++;
            });
          },
        ),
      ],
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
      onPressed: _registrarVenta,
      icon: Icon(Icons.check),
      label: Text('Registrar Venta'),
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

      final stockDisponible = productoSeleccionado['cantidad'] ?? 0;

      if (_selectedCantidad > stockDisponible) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              stockDisponible == 0
                  ? 'Producto agotado.'
                  : 'No hay suficiente stock. Disponible: $stockDisponible',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      double subtotal = productoSeleccionado['precio'] * _selectedCantidad;

      setState(() {
        _productos.add({
          'idProducto': productoSeleccionado['idProducto'],
          'nombre': _selectedProducto,
          'cantidad': _selectedCantidad,
          'precio': productoSeleccionado['precio'],
          'subtotal': subtotal,
        });
        _selectedProducto = null;
        _selectedCantidad = 1;
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
    return numero.toString().padLeft(5, '0');
  }

  Future<void> _registrarVenta() async {
    if (_formKey.currentState!.validate() && _productos.isNotEmpty) {
      final ahora = DateTime.now();

      final ventaData = {
        'fecha':
            '${ahora.year}-${ahora.month.toString().padLeft(2, '0')}-${ahora.day.toString().padLeft(2, '0')}',
        'hora':
            '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}:${ahora.second.toString().padLeft(2, '0')}',
        'serie': 'F001',
        'num_documento': 'DOC${_generarIdDocumento()}',
        'tipo_documento': 'BOLETA',
        'idUsuario': int.tryParse(empleado?.idEmpleado ?? '') ?? 0,
        'idCliente': _selectedCliente!.idCliente,
        'productos': _productos.map((p) => p['idProducto'].toString()).toList(),
        'cantidades': _productos.map((p) => p['cantidad'].toString()).toList(),
        'precios': _productos.map((p) => p['precio'].toString()).toList(),
      };

      try {
        final ok = await _ventaController.registrarVenta(ventaData);
        if (ok) {
          await GenerarBoleta.generar(
            clienteNombre: _selectedCliente!.nombre,
            productos: _productos,
            igv: _igv,
            total: _total,
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Pantallaventa()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo registrar la venta')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la venta: $e')),
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
