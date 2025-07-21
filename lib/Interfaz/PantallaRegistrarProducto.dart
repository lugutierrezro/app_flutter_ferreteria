import 'package:flutter/material.dart';
import 'package:proyecto0/Entidades/Producto.dart';
import 'package:proyecto0/Entidades/Categoria.dart';
import 'package:proyecto0/Entidades/Marca.dart';
import 'package:proyecto0/Controlador/CategoriaController.dart';
import 'package:proyecto0/Controlador/MarcaController.dart';
import 'package:proyecto0/Controlador/ProductoController.dart';
import 'package:proyecto0/Interfaz/PantallaCarta.dart';
import 'package:proyecto0/Interfaz/PantallMostrarProducto.dart';

class PantallaRegistrarProducto extends StatefulWidget {
  const PantallaRegistrarProducto({Key? key}) : super(key: key);

  @override
  State<PantallaRegistrarProducto> createState() =>
      _PantallaRegistrarProductoState();
}

class _PantallaRegistrarProductoState extends State<PantallaRegistrarProducto> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _precioCompraCtrl = TextEditingController();
  final _precioVentaCtrl = TextEditingController();

  DateTime? _fechaIngreso;
  DateTime? _fechaVencimiento;

  List<Categoria> _categorias = [];
  List<Marca> _marcas = [];
  Categoria? _categoriaSeleccionada;
  Marca? _marcaSeleccionada;

  final productoController = ProductoController();
  final categoriaController = CategoriaController();
  final marcaController = MarcaController();

  @override
  void initState() {
    super.initState();
    _idCtrl.text = _generarIdProducto(); // ← genera el ID automáticamente
    _cargarDatosIniciales();
  }

  String _generarIdProducto() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final numero = now % 100000;
    final numeroFormateado = numero.toString().padLeft(5, '0');
    return numeroFormateado;
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      final categorias = await categoriaController.obtenerCategorias();
      final marcas = await marcaController.obtenerMarca();
      setState(() {
        _categorias = categorias;
        _marcas = marcas;
      });
    } catch (e) {
      print('Error al cargar categorías o marcas: $e');
    }
  }

  Future<void> _pickDate(bool esIngreso) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (fechaSeleccionada != null) {
      setState(() {
        if (esIngreso) {
          _fechaIngreso = fechaSeleccionada;
        } else {
          _fechaVencimiento = fechaSeleccionada;
        }
      });
    }
  }

  Future<void> _guardarProducto() async {
    if (_formKey.currentState!.validate() &&
        _fechaIngreso != null &&
        _fechaVencimiento != null &&
        _categoriaSeleccionada != null &&
        _marcaSeleccionada != null) {
      final producto = Producto(
        idProducto: _idCtrl.text,
        nombre: _nombreCtrl.text,
        fechaIngreso: _fechaIngreso!,
        fechaVencimiento: _fechaVencimiento!,
        precioCompra: double.parse(_precioCompraCtrl.text),
        precioVenta: double.parse(_precioVentaCtrl.text),
        idCategoria: _categoriaSeleccionada!.id,
        idMarca: _marcaSeleccionada!.id,
        cantidad: 0,
      );

      final exito = await productoController.guardarProducto(producto);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exito
                ? 'Producto guardado correctamente'
                : 'Error al guardar el producto',
          ),
        ),
      );

      if (exito) {
        // Navega a PantallaMostrarProducto después de mostrar el mensaje
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Producto guardado correctamente')),
        );

        // Espera breve antes de navegar para que se vea el mensaje
        await Future.delayed(Duration(milliseconds: 800));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PantallaMostrarProducto()),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Completa todos los campos')));
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Producto'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PantallaDashboard()),
              ),
        ),
      ),
      body:
          _categorias.isEmpty || _marcas.isEmpty
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Formulario de Registro',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _idCtrl,
                        decoration: _inputDecoration('ID Producto'),
                        readOnly: true,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _nombreCtrl,
                        decoration: _inputDecoration('Nombre'),
                        validator:
                            (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(true),
                              child: InputDecorator(
                                decoration: _inputDecoration('Fecha Ingreso'),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _fechaIngreso == null
                                          ? 'Seleccionar'
                                          : _fechaIngreso!
                                              .toIso8601String()
                                              .substring(0, 10),
                                    ),
                                    Icon(Icons.calendar_today, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _pickDate(false),
                              child: InputDecorator(
                                decoration: _inputDecoration(
                                  'Fecha Vencimiento',
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _fechaVencimiento == null
                                          ? 'Seleccionar'
                                          : _fechaVencimiento!
                                              .toIso8601String()
                                              .substring(0, 10),
                                    ),
                                    Icon(Icons.calendar_today, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _precioCompraCtrl,
                        decoration: _inputDecoration('Precio Compra'),
                        keyboardType: TextInputType.number,
                        validator:
                            (v) =>
                                v == null || double.tryParse(v) == null
                                    ? 'Número inválido'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _precioVentaCtrl,
                        decoration: _inputDecoration('Precio Venta'),
                        keyboardType: TextInputType.number,
                        validator:
                            (v) =>
                                v == null || double.tryParse(v) == null
                                    ? 'Número inválido'
                                    : null,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<Categoria>(
                        decoration: _inputDecoration('Categoría'),
                        items:
                            _categorias.map((cat) {
                              return DropdownMenuItem(
                                value: cat,
                                child: Text(cat.nombre),
                              );
                            }).toList(),
                        value: _categoriaSeleccionada,
                        onChanged:
                            (cat) =>
                                setState(() => _categoriaSeleccionada = cat),
                        validator:
                            (v) =>
                                v == null ? 'Seleccione una categoría' : null,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<Marca>(
                        decoration: _inputDecoration('Marca'),
                        items:
                            _marcas.map((m) {
                              return DropdownMenuItem(
                                value: m,
                                child: Text(m.nombre),
                              );
                            }).toList(),
                        value: _marcaSeleccionada,
                        onChanged:
                            (m) => setState(() => _marcaSeleccionada = m),
                        validator:
                            (v) => v == null ? 'Seleccione una marca' : null,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _guardarProducto,
                        icon: Icon(Icons.save),
                        label: Text('Guardar Producto'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
