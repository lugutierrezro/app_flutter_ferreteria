import 'package:flutter/material.dart';
import 'package:proyecto0/Entidades/Marca.dart';
import 'package:proyecto0/Controlador/MarcaController.dart';
import 'package:proyecto0/Interfaz/PantallaCarta.dart';

class PantallaMarca extends StatefulWidget {
  const PantallaMarca({super.key});

  @override
  State<PantallaMarca> createState() => _PantallaMarcaState();
}

class _PantallaMarcaState extends State<PantallaMarca> {
  final MarcaController _api = MarcaController();
  final TextEditingController _txtNombre = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Marca> _marcas = [];
  bool _editando = false;
  int? _idEditando;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      _marcas = await _api.obtenerMarca();
      setState(() {});
    } catch (e) {
      _mostrarSnackbar('Error al cargar marcas');
    }
  }

  Future<void> _guardarMarca() async {
    if (!_formKey.currentState!.validate()) return;

    String nombre = _txtNombre.text.trim();

    try {
      if (_editando && _idEditando != null) {
        await _api.editarMarca(Marca(id: _idEditando!, nombre: nombre));
        _mostrarSnackbar('Marca actualizada exitosamente');
      } else {
        await _api.guardarMarca(Marca(id: 0, nombre: nombre));
        _mostrarSnackbar('Marca registrada exitosamente');
      }

      _txtNombre.clear();
      _editando = false;
      _idEditando = null;
      await _cargar();
    } catch (e) {
      _mostrarSnackbar('Ocurrió un error: $e');
    }
  }

  void _prepararEdicion(Marca marca) {
    setState(() {
      _txtNombre.text = marca.nombre;
      _editando = true;
      _idEditando = marca.id;
    });
  }

  Future<void> _eliminarMarca(int id) async {
    final confirmado = await _confirmarEliminacion();
    if (confirmado) {
      try {
        await _api.eliminarMarca(id);
        await _cargar();
        _mostrarSnackbar('Marca eliminada');
      } catch (e) {
        _mostrarSnackbar('Error al eliminar marca');
      }
    }
  }

  Future<bool> _confirmarEliminacion() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirmar eliminación'),
                content: const Text('¿Estás seguro de eliminar esta marca?'),
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
          title: const Text('Gestión de Marcas'),
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
                    labelText: 'Nombre de la marca',
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
                onPressed: _guardarMarca,
                icon: Icon(_editando ? Icons.save : Icons.add),
                label: Text(_editando ? 'Guardar Cambios' : 'Registrar Marca'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
              ),
              const Divider(height: 30),
              Expanded(
                child:
                    _marcas.isEmpty
                        ? const Center(child: Text('No hay marcas registradas'))
                        : ListView.builder(
                          itemCount: _marcas.length,
                          itemBuilder: (context, index) {
                            final m = _marcas[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(m.id.toString()),
                                ),
                                title: Text(m.nombre),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _prepararEdicion(m),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _eliminarMarca(m.id),
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
