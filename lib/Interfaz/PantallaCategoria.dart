import 'package:flutter/material.dart';
import 'package:proyecto0/Entidades/Categoria.dart';
import 'package:proyecto0/Controlador/CategoriaController.dart';
import 'package:proyecto0/Interfaz/PantallaCarta.dart';

class PantallaCategoria extends StatefulWidget {
  const PantallaCategoria({super.key});

  @override
  State<PantallaCategoria> createState() => _PantallaCategoriaState();
}

class _PantallaCategoriaState extends State<PantallaCategoria> {
  final CategoriaController _controller = CategoriaController();
  final TextEditingController _txtNombre = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Categoria> _categorias = [];
  bool _editando = false;
  int? _idEditando;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      _categorias = await _controller.obtenerCategorias();
      setState(() {});
    } catch (e) {
      _mostrarSnackbar('Error al cargar categorías');
    }
  }

  Future<void> _guardarCategoria() async {
    if (!_formKey.currentState!.validate()) return;

    String nombre = _txtNombre.text.trim();

    try {
      if (_editando && _idEditando != null) {
        await _controller.editarCategoria(
          Categoria(id: _idEditando!, nombre: nombre),
        );
        _mostrarSnackbar('Categoría actualizada exitosamente');
      } else {
        await _controller.guardarCategoria(Categoria(id: 0, nombre: nombre));
        _mostrarSnackbar('Categoría registrada exitosamente');
      }

      _txtNombre.clear();
      _editando = false;
      _idEditando = null;
      await _cargar();
    } catch (e) {
      _mostrarSnackbar('Ocurrió un error: $e');
    }
  }

  void _prepararEdicion(Categoria categoria) {
    setState(() {
      _txtNombre.text = categoria.nombre;
      _editando = true;
      _idEditando = categoria.id;
    });
  }

  Future<void> _eliminarCategoria(int id) async {
    final confirmado = await _confirmarEliminacion();
    if (confirmado) {
      try {
        await _controller.eliminarCategoria(id);
        await _cargar();
        _mostrarSnackbar('Categoría eliminada');
      } catch (e) {
        _mostrarSnackbar('Error al eliminar categoría');
      }
    }
  }

  Future<bool> _confirmarEliminacion() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirmar eliminación'),
                content: const Text(
                  '¿Estás seguro de eliminar esta categoría?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _mostrarSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 2)),
    );
  }

  void _irAtras() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PantallaDashboard()),
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
          title: const Text('Gestión de Categorías'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _irAtras,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _txtNombre,
                  decoration: InputDecoration(
                    labelText: 'Nombre de la categoría',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator:
                      (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Este campo es obligatorio'
                              : null,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _guardarCategoria,
                icon: Icon(_editando ? Icons.save : Icons.add),
                label: Text(
                  _editando ? 'Guardar Cambios' : 'Registrar Categoría',
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
              const Divider(height: 30),
              Expanded(
                child:
                    _categorias.isEmpty
                        ? const Center(
                          child: Text('No hay categorías registradas'),
                        )
                        : ListView.builder(
                          itemCount: _categorias.length,
                          itemBuilder: (context, index) {
                            final c = _categorias[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(c.id.toString()),
                                ),
                                title: Text(c.nombre),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _prepararEdicion(c),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _eliminarCategoria(c.id),
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
        ),
      ),
    );
  }
}
