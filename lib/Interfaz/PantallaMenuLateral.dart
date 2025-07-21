import 'package:flutter/material.dart';

// Importa tus pantallas aquí
import 'package:proyecto0/Interfaz/PantallaCarta.dart';
import 'package:proyecto0/Interfaz/PantallaCategoria.dart';
import 'package:proyecto0/Interfaz/PantallaCliente.dart';
import 'package:proyecto0/Interfaz/PantallaCompra.dart';
import 'package:proyecto0/Interfaz/PantallaVenta.dart';
import 'package:proyecto0/Interfaz/PantallaMostrarClientes.dart';
import 'package:proyecto0/Interfaz/PantallaEmpleado.dart';
import 'package:proyecto0/Interfaz/PantallaRegistrarEmpleado.dart';
import 'package:proyecto0/Interfaz/PantallaRegistrarProducto.dart';
import 'package:proyecto0/Interfaz/PantallMostrarProducto.dart';
import 'package:proyecto0/Interfaz/PantallaMarca.dart';
import 'package:proyecto0/Interfaz/PantallaRegistrarProveedor.dart';
import 'package:proyecto0/Interfaz/PantallaMostrarProveedor.dart';
import 'package:proyecto0/Interfaz/RegistarVenta.dart';
import 'package:proyecto0/Interfaz/PantallaRegistrarCompra.dart';
import 'package:proyecto0/Entidades/Sesion.dart';
import 'package:proyecto0/Entidades/Empleado.dart';
import 'package:proyecto0/Interfaz/PaginaInicio.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});
  static const Color _primary = Color(0xFF1B4332);
  static const Color _accent = Color(0xFF74C69D);
  static const Color _bgColor = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    final empleado = Sesion().empleadoActual;
    return Drawer(
      child: Container(
        color: _bgColor,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 8),
                children: [
                  _crearOpcion(
                    context,
                    icono: Icons.dashboard,
                    texto: "Inicio",
                    destino: PantallaDashboard(),
                  ),

                  // Clientes (disponible para todos)
                  _ExpansionTileConAnimacion(
                    icono: Icons.people,
                    titulo: "Clientes",
                    opciones: [
                      _crearOpcion(
                        context,
                        texto: "Registrar Cliente",
                        icono: Icons.person_add,
                        destino: Pantallacliente(),
                        interno: true,
                      ),
                      _crearOpcion(
                        context,
                        texto: "Mostrar Clientes",
                        icono: Icons.list_alt,
                        destino: Pantallamostrarclientes(),
                        interno: true,
                      ),
                    ],
                  ),
                  if (empleado?.rol == 'administrador')
                    _ExpansionTileConAnimacion(
                      icono: Icons.badge,
                      titulo: "Empleados",
                      opciones: [
                        _crearOpcion(
                          context,
                          texto: "Registrar",
                          icono: Icons.person_add,
                          destino: PantallaRegistrarEmpleado(),
                          interno: true,
                        ),
                        _crearOpcion(
                          context,
                          texto: "Lista",
                          icono: Icons.list,
                          destino: PantallaEmpleado(),
                          interno: true,
                        ),
                      ],
                    ),

                  // Empleados (solo para Administrador)
                  if (empleado?.rol == 'Administrador')
                    _ExpansionTileConAnimacion(
                      icono: Icons.badge,
                      titulo: "Empleados",
                      opciones: [
                        _crearOpcion(
                          context,
                          texto: "Registrar",
                          icono: Icons.person_add,
                          destino: PantallaRegistrarEmpleado(),
                          interno: true,
                        ),
                        _crearOpcion(
                          context,
                          texto: "Lista",
                          icono: Icons.list,
                          destino: PantallaEmpleado(),
                          interno: true,
                        ),
                      ],
                    ),

                  // Productos (para Admin y Almacenero)
                  if (empleado?.rol == 'Administrador' ||
                      empleado?.rol == 'Empleado')
                    _ExpansionTileConAnimacion(
                      icono: Icons.inventory_2_outlined,
                      titulo: "Productos",
                      opciones: [
                        _crearOpcion(
                          context,
                          texto: "Mostrar Productos",
                          icono: Icons.view_list,
                          destino: PantallaMostrarProducto(),
                          interno: true,
                        ),
                        _crearOpcion(
                          context,
                          texto: "Registrar Producto",
                          icono: Icons.add_box,
                          destino: PantallaRegistrarProducto(),
                          interno: true,
                        ),
                        _crearOpcion(
                          context,
                          texto: "Categorías",
                          icono: Icons.category,
                          destino: PantallaCategoria(),
                          interno: true,
                        ),
                        _crearOpcion(
                          context,
                          texto: "Marcas",
                          icono: Icons.branding_watermark,
                          destino: PantallaMarca(),
                          interno: true,
                        ),
                      ],
                    ),

                  // Ventas y Compras (para Vendedor o Admin)
                  if (empleado?.rol == 'Empleado' ||
                      empleado?.rol == 'Administrador')
                    _ExpansionTileConAnimacion(
                      icono: Icons.point_of_sale,
                      titulo: "Ventas y Compras",
                      opciones: [
                        _crearOpcion(
                          context,
                          texto: "Registrar Venta",
                          icono: Icons.shopping_cart_checkout,
                          destino: RegistrarVentaScreen(),
                          interno: true,
                        ),
                        _crearOpcion(
                          context,
                          texto: "Ventas",
                          icono: Icons.shopping_cart,
                          destino: Pantallaventa(),
                          interno: true,
                        ),
                        _crearOpcion(
                          context,
                          texto: "Compras",
                          icono: Icons.shopping_bag,
                          destino: PantallaCompra(),
                          interno: true,
                        ),
                        _crearOpcion(
                          context,
                          texto: "Registrar Compra",
                          icono: Icons.add_business,
                          destino: RegistrarSuministroScreen(),
                          interno: true,
                        ),
                      ],
                    ),

                  // Proveedores (solo Admin)
                  if (empleado?.rol == 'Administrador')
                    _ExpansionTileConAnimacion(
                      icono: Icons.local_shipping,
                      titulo: "Proveedores",
                      opciones: [
                        _crearOpcion(
                          context,
                          texto: "Registrar",
                          icono: Icons.person_add,
                          destino: PantallaProveedor(),
                          interno: true,
                        ),
                        _crearOpcion(
                          context,
                          texto: "Mostrar",
                          icono: Icons.list_alt,
                          destino: PantallaListaProveedores(),
                          interno: true,
                        ),
                      ],
                    ),

                  const Divider(),

                  // Cerrar sesión
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Cerrar Sesión",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _mostrarDialogoCerrarSesion(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final empleado = Sesion().empleadoActual;

    return Container(
      color: _primary,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            radius: 28,
            child: Icon(Icons.storefront, size: 32, color: Color(0xFF1B4332)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ferretería Pinotello",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                empleado != null
                    ? "${empleado.nombre} ${empleado.apellido} - ${empleado.rol}"
                    : "Usuario no identificado",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _crearOpcion(
    BuildContext context, {
    required String texto,
    required IconData icono,
    required Widget destino,
    bool interno = false,
  }) {
    final tile = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // Cierra el drawer primero
          Future.delayed(const Duration(milliseconds: 100), () {
            Navigator.of(
              context,
            ).pushReplacement(MaterialPageRoute(builder: (_) => destino));
          });
        },
        splashColor: _accent.withOpacity(0.2),
        child: ListTile(
          dense: true,
          leading: Icon(icono, size: 22, color: _accent),
          title: Text(texto),
        ),
      ),
    );

    return interno
        ? Padding(padding: const EdgeInsets.only(left: 24.0), child: tile)
        : tile;
  }

  void _mostrarDialogoCerrarSesion(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Cerrar Sesión"),
            content: const Text("¿Deseas cerrar sesión?"),
            actions: [
              TextButton(
                onPressed: () {
                  Sesion().empleadoActual = null;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => PantallaLogin()),
                    (route) => false,
                  );
                },

                child: const Text("Salir"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => PantallaDashboard(),
                    ), // cambia si tienes login
                    (route) => false,
                  );
                },
                child: const Text("Cancelar"),
              ),
            ],
          ),
    );
  }
}

// COMPONENTE CON ANIMACIÓN EN LOS SUBMENÚS

class _ExpansionTileConAnimacion extends StatefulWidget {
  final IconData icono;
  final String titulo;
  final List<Widget> opciones;

  const _ExpansionTileConAnimacion({
    required this.icono,
    required this.titulo,
    required this.opciones,
  });

  @override
  State<_ExpansionTileConAnimacion> createState() =>
      _ExpansionTileConAnimacionState();
}

class _ExpansionTileConAnimacionState
    extends State<_ExpansionTileConAnimacion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(widget.icono, color: MenuLateral._primary),
      title: Text(
        widget.titulo,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      trailing: AnimatedRotation(
        turns: _isExpanded ? 0.5 : 0,
        duration: const Duration(milliseconds: 200),
        child: const Icon(Icons.expand_more),
      ),
      onExpansionChanged: (expanded) => setState(() => _isExpanded = expanded),
      children: widget.opciones,
    );
  }
}
