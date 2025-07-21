import 'package:flutter/material.dart';
import '../Controlador/VentaController.dart';
import '../Entidades/Venta.dart';
import '../Interfaz/RegistarVenta.dart';
import 'PantallaDetalleVenta.dart';

class Pantallaventa extends StatefulWidget {
  @override
  _PantallaventaState createState() => _PantallaventaState();
}

class _PantallaventaState extends State<Pantallaventa> {
  late VentaController _ventaController;
  List<Venta> _ventas = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ventaController = VentaController();
    _listarVentas();
  }

  Future<void> _listarVentas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final ventas = await _ventaController.listarVentas();
      setState(() {
        _ventas = ventas;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar las ventas. Intente nuevamente.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _buscarVenta() async {
    if (_searchQuery.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final ventas = await _ventaController.buscarVenta(_searchQuery);
        setState(() {
          _ventas = ventas;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Error al buscar la venta.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _listarVentas();
    }
  }

  void _registrarVenta() {
    Navigator.pushNamed(context, '/RegistarVenta');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Registrar nueva venta',
            onPressed: _registrarVenta,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Buscar por cliente o ID',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                      },
                      onSubmitted: (_) => _buscarVenta(),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  Expanded(
                    child:
                        _ventas.isEmpty
                            ? const Center(
                              child: Text(
                                'No se encontraron ventas.',
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                            : ListView.builder(
                              itemCount: _ventas.length,
                              itemBuilder: (context, index) {
                                final venta = _ventas[index];
                                return Card(
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(12),
                                    leading: const Icon(
                                      Icons.receipt_long,
                                      color: Colors.blueAccent,
                                      size: 32,
                                    ),
                                    title: Text(
                                      'Venta #${venta.idVenta}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text('Fecha: ${venta.fecha}'),
                                        Text(
                                          'Total: S/. ${venta.total.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => DetalleVentaScreen(
                                                venta: venta,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
