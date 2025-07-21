import 'package:flutter/material.dart';
import '../Controlador/suministro-controller.dart';
import '../Entidades/Suministro.dart';
import 'PantallaRegistrarCompra.dart'; // Asegúrate de crear esta pantalla
import 'PantallaDetalleCompra.dart'; // Asegúrate de crear esta pantalla

class PantallaCompra extends StatefulWidget {
  @override
  _PantallaCompraState createState() => _PantallaCompraState();
}

class _PantallaCompraState extends State<PantallaCompra> {
  late SuministroController _suministroController;
  List<Suministro> _suministros = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _suministroController = SuministroController();
    _listarSuministros();
  }

  Future<void> _listarSuministros() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final suministros = await _suministroController.listarSuministros();
      setState(() {
        _suministros = suministros;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '❌ Error al cargar las compras.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _buscarCompra() async {
    if (_searchQuery.isNotEmpty) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final resultado = await _suministroController.buscarSuministro(
          _searchQuery,
        );
        setState(() {
          _suministros = resultado;
        });
      } catch (e) {
        setState(() {
          _errorMessage = '❌ Error al buscar la compra.';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _listarSuministros();
    }
  }

  void _registrarCompra() {
    Navigator.pushNamed(context, '/RegistrarCompra');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Compras'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Registrar nueva compra',
            onPressed: _registrarCompra,
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
                        labelText: 'Buscar por proveedor o documento',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        _searchQuery = value;
                      },
                      onSubmitted: (_) => _buscarCompra(),
                    ),
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Expanded(
                    child:
                        _suministros.isEmpty
                            ? const Center(
                              child: Text('No se encontraron compras.'),
                            )
                            : ListView.builder(
                              itemCount: _suministros.length,
                              itemBuilder: (context, index) {
                                final suministro = _suministros[index];
                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.shopping_cart_outlined,
                                      color: Colors.deepPurple,
                                    ),
                                    title: Text(
                                      'Compra #${suministro.idSuministro}',
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Proveedor: ${suministro.proveedor}',
                                        ),
                                        Text(
                                          'Fecha: ${suministro.fecha} - Total: S/. ${suministro.total.toStringAsFixed(2)}',
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
                                              (_) => DetalleCompraScreen(
                                                suministro: suministro,
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
