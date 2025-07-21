import 'package:flutter/material.dart';
import 'package:proyecto0/Interfaz/PantallaMenuLateral.dart';
import 'package:proyecto0/Entidades/Sesion.dart';
// Pantallas
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
import 'package:proyecto0/Interfaz/PantallaHistorialVentas.dart';
import 'package:proyecto0/Interfaz/PantallaHistorialCompras.dart';
import 'package:proyecto0/Interfaz/PantallaUsuarios.dart';

class PantallaDashboard extends StatelessWidget {
  const PantallaDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final empleado = Sesion().empleadoActual;

    return Scaffold(
      drawer: const MenuLateral(),
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 148, 241, 202),
        title: const Text('Panel General'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (empleado?.rol == 'Administrador')
              _buildResumenSuperior(context),
            const SizedBox(height: 24),
            _buildTituloSeccion('Módulos del Sistema'),
            const SizedBox(height: 12),
            _buildGridModulos(context, empleado?.rol ?? 'Desconocido'),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenSuperior(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _cardResumen(
          'Usuarios',
          Icons.people,
          Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PantallaUsuarios()),
            );
          },
        ),
        _cardResumen('Productos', Icons.shopping_bag, Colors.blue),
        _cardResumen(
          'Ventas',
          Icons.attach_money,
          Colors.orange,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PantallaHistorialVentas(),
              ),
            );
          },
        ),
        _cardResumen(
          'Compras',
          Icons.shopping_basket,
          const Color.fromARGB(255, 206, 233, 155),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PantallaHistorialCompras(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _cardResumen(
    String titulo,
    IconData icono,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icono, size: 40, color: color),
                const SizedBox(height: 8),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Ver detalles', style: TextStyle(color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTituloSeccion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1B4332),
      ),
    );
  }

  Widget _buildGridModulos(BuildContext context, String rol) {
    List<_Modulo> modulos = [];

    if (rol == 'Administrador') {
      modulos = [
        _Modulo('Registrar Cliente', Icons.person_add, const Pantallacliente()),
        _Modulo('Ver Clientes', Icons.people, const Pantallamostrarclientes()),
        _Modulo(
          'Registrar Producto',
          Icons.add_box,
          const PantallaRegistrarProducto(),
        ),
        _Modulo(
          'Ver Productos',
          Icons.shopping_bag,
          const PantallaMostrarProducto(),
        ),
        _Modulo('Categoría', Icons.category, PantallaCategoria()),
        _Modulo('Marca', Icons.branding_watermark, PantallaMarca()),
        _Modulo(
          'Registrar Proveedor',
          Icons.person_add_alt,
          PantallaProveedor(),
        ),
        _Modulo('Ver Proveedores', Icons.store, PantallaListaProveedores()),
        _Modulo(
          'Registrar Empleado',
          Icons.person_add,
          PantallaRegistrarEmpleado(),
        ),
        _Modulo('Ver Empleados', Icons.badge, PantallaEmpleado()),
        _Modulo('Registrar Venta', Icons.point_of_sale, RegistrarVentaScreen()),
        _Modulo('Ver Ventas', Icons.bar_chart, Pantallaventa()),
        _Modulo(
          'Registrar Compra',
          Icons.shopping_cart,
          RegistrarSuministroScreen(),
        ),
        _Modulo('Ver Compras', Icons.assignment, PantallaCompra()),
      ];
    } else if (rol == 'Empleado') {
      modulos = [
        _Modulo('Registrar Cliente', Icons.person_add, const Pantallacliente()),
        _Modulo('Ver Clientes', Icons.people, const Pantallamostrarclientes()),
        _Modulo(
          'Registrar Producto',
          Icons.add_box,
          const PantallaRegistrarProducto(),
        ),
        _Modulo(
          'Ver Productos',
          Icons.shopping_bag,
          const PantallaMostrarProducto(),
        ),
        _Modulo('Categoría', Icons.category, PantallaCategoria()),
        _Modulo('Marca', Icons.branding_watermark, PantallaMarca()),
        _Modulo('Registrar Venta', Icons.point_of_sale, RegistrarVentaScreen()),
        _Modulo('Ver Ventas', Icons.bar_chart, Pantallaventa()),
        _Modulo(
          'Registrar Compra',
          Icons.shopping_cart,
          RegistrarSuministroScreen(),
        ),
        _Modulo('Ver Compras', Icons.assignment, PantallaCompra()),
      ];
    }

    if (modulos.isEmpty) {
      return const Text(
        'No tienes acceso a módulos.',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.red,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: modulos.length,
      itemBuilder: (context, index) {
        final item = modulos[index];
        return GestureDetector(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item.destino),
              ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            elevation: 3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icono, size: 36, color: Color(0xFF2D6A4F)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      item.titulo,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Modulo {
  final String titulo;
  final IconData icono;
  final Widget destino;

  _Modulo(this.titulo, this.icono, this.destino);
}
