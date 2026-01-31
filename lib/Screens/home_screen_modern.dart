import 'package:fabrics_app/Models/compra.dart';
import 'package:fabrics_app/Models/user.dart';
import 'package:fabrics_app/Screens/Inventario_screen.dart';
import 'package:fabrics_app/Screens/Productos/new_prod_search.dart';
import 'package:fabrics_app/Screens/add_compra_screen.dart';
import 'package:fabrics_app/Screens/add_newproduct_screen.dart';
import 'package:fabrics_app/Screens/add_roll_screen.dart';
import 'package:fabrics_app/Screens/compras_screen.dart';
import 'package:fabrics_app/Screens/login_screen.dart';
import 'package:fabrics_app/Screens/orden_entrada.dart';
import 'package:fabrics_app/Screens/order_new.dart';
import 'package:fabrics_app/Screens/pedidos_screen.dart';
import 'package:fabrics_app/Screens/review_invent_screen.dart';
import 'package:fabrics_app/Screens/measure_roll_screen.dart';
import 'package:fabrics_app/Screens/finalize_roll_screen.dart';
import 'package:fabrics_app/Screens/damage_roll_screen.dart';
import 'package:fabrics_app/Screens/verify_roll_screen.dart';
import 'package:fabrics_app/constans.dart';
import 'package:fabrics_app/sizeconfig.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fabrics_app/Providers/cart_provider.dart';
import 'dart:ui';

class HomeScreenModern extends StatefulWidget {
  const HomeScreenModern({super.key, required this.user});
  final User user;

  @override
  State<HomeScreenModern> createState() => _HomeScreenModernState();
}

class _HomeScreenModernState extends State<HomeScreenModern> {
  int _currentIndex = 1; // Empezamos en Órdenes (Centro)

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final cart = context.watch<CartProvider>();

    // Build destinations list based on user role
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2),
        label: 'Gestión',
      ),
      const NavigationDestination(
        icon: Icon(Icons.shopping_bag_outlined),
        selectedIcon: Icon(Icons.shopping_bag),
        label: 'Órdenes',
      ),
    ];

    if (widget.user.isAdmin == true) {
      destinations.add(
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
      );
    }

    // Build body widgets list
    final bodyWidgets = <Widget>[_buildGestionTab(), _buildOrdersTab(cart)];

    if (widget.user.isAdmin == true) {
      bodyWidgets.add(_buildAdminTab());
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Background Gradient base (Dark 2025 style)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimaryColor, kColorHomeBar, Color(0xFF020420)],
              ),
            ),
          ),
          // Subtle background decoration
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kColorAlternativo.withValues(alpha: 0.05),
              ),
            ),
          ),
          SafeArea(
            child: IndexedStack(index: _currentIndex, children: bodyWidgets),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    );
                  }
                  return GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                elevation: 0,
                indicatorColor: Colors.white.withValues(alpha: 0.2),
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: destinations.map((d) {
                  return NavigationDestination(
                    icon: Icon(
                      (d.icon as Icon).icon,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    selectedIcon: Icon(
                      (d.selectedIcon as Icon).icon,
                      color: Colors.white,
                    ),
                    label: d.label,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGestionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          Text(
            "Gestión por Rollos",
            style: GoogleFonts.oswald(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          _buildQuickActionsGrid(),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(CartProvider cart) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          _buildHeroSection(cart),
          const SizedBox(height: 20),
          _buildPendingOrdersSection(cart),
          const SizedBox(height: 25),
          _buildOrdersSection(),
        ],
      ),
    );
  }

  Widget _buildAdminTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 30),
          Text(
            "Administración del Sistema",
            style: GoogleFonts.oswald(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          _buildAdminGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola,",
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white60),
            ),
            Text(
              widget.user.fullName ?? "Usuario",
              style: GoogleFonts.oswald(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => _goMenu('Cerrar Sesion'),
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(CartProvider cart) {
    return GestureDetector(
      onTap: () => _goMenu('Nueva Orden'),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          gradient: kGradientCardNewOrder,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    cart.items.isEmpty ? "Nueva Orden" : "Orden en Curso",
                    style: GoogleFonts.oswald(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    cart.items.isEmpty
                        ? "Crear un nuevo pedido ahora"
                        : "Tienes ${cart.itemCount} productos pendientes",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingOrdersSection(CartProvider cart) {
    if (cart.pendingOrders.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ordenes en Curso",
              style: GoogleFonts.oswald(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${cart.pendingOrders.length}",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cart.pendingOrders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = cart.pendingOrders[index];
            final isActive = index == cart.activeIndex;
            return GestureDetector(
              onTap: () {
                cart.switchToOrder(index);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => OrderNewScreen(
                      orden: cart.activeOrder!,
                      user: widget.user,
                      isOld: false,
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isActive
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.15),
                        width: isActive ? 2 : 1,
                      ),
                      gradient: isActive
                          ? LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.1),
                                Colors.white.withValues(alpha: 0.05),
                              ],
                            )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Orden #${index + 1}",
                                style: GoogleFonts.oswald(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "${order.detalles.length} productos",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => cart.removeOrderAt(index),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.delete_sweep_outlined,
                              color: Colors.white70,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrdersSection() {
    return GestureDetector(
      onTap: () => _goMenu('Ordenes'),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              gradient: kGradientCardListOrder,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Listado de Ordenes",
                        style: GoogleFonts.oswald(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Ver historial y estados",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.white24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.1,
      children: [
        _buildActionCard(
          "Toma Inventario",
          "assets/inventario.png",
          const Color(0xFFE3F2FD),
          const Color(0xFF1565C0),
          onTapOverride: () => _goMenu('Medir Rollo'),
        ),
        _buildActionCard(
          "Finalizar Rollo",
          "assets/iconNuevo.png",
          const Color(0xFFF3E5F5),
          const Color(0xFF7B1FA2),
          onTapOverride: () => _goMenu('Finalizar Rollo'),
        ),
        _buildActionCard(
          "Verificar Medida",
          "assets/rollos1.png",
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32),
          onTapOverride: () => _goMenu('Verificar Medida'),
        ),
        _buildActionCard(
          "Mermas / Daños",
          "assets/Rollos6.png",
          const Color(0xFFFFF3E0),
          const Color(0xFFEF6C00),
          onTapOverride: () => _goMenu('Mermas / Daños'),
        ),
        _buildActionCard(
          "Convertir a Retazo",
          "assets/inventario.png",
          Colors.grey[200]!,
          Colors.grey,
          onTapOverride: () {}, // Disabled for now
          isProximamente: true,
        ),
      ],
    );
  }

  Widget _buildAdminGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3, // Smaller cards for admin
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: [
        _buildSmallActionCard(
          "Crear Producto",
          "assets/NewFondo.png",
          "Crear Producto",
        ),
        _buildSmallActionCard(
          "Agregar Rollo",
          "assets/iconNuevo.png",
          "Agregar Rollo",
        ),
        _buildSmallActionCard(
          "Agregar Compra",
          "assets/Factura.png",
          "Agregar Compra",
        ),
        _buildSmallActionCard("Compras", "assets/Factura.png", "Compras"),
        _buildSmallActionCard(
          "Entrada Almacen",
          "assets/Almacen.png",
          "Entrada Almacen",
        ),
        // _buildSmallActionCard("Revisar Inventario", "assets/inventario.png", "Revisar Inventario"), // Added to main grid for visibility
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    String asset,
    Color bgColor,
    Color iconColor, {
    VoidCallback? onTapOverride,
    bool isProximamente = false,
  }) {
    return GestureDetector(
      onTap: isProximamente ? null : (onTapOverride ?? () => _goMenu(title)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Opacity(
            opacity: isProximamente ? 0.5 : 1.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: isProximamente
                            ? Colors.grey.withValues(alpha: 0.2)
                            : bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: ColorFiltered(
                        colorFilter: isProximamente
                            ? const ColorFilter.matrix([
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0.2126,
                                0.7152,
                                0.0722,
                                0,
                                0,
                                0,
                                0,
                                0,
                                1,
                                0,
                              ])
                            : const ColorFilter.mode(
                                Colors.transparent,
                                BlendMode.dst,
                              ),
                        child: Image.asset(
                          asset,
                          height: 35,
                          width: 35,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.oswald(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isProximamente ? Colors.grey : Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallActionCard(String title, String asset, String action) {
    return GestureDetector(
      onTap: () => _goMenu(action),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(asset, height: 30, width: 30, fit: BoxFit.contain),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.oswald(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goMenu(String? nombre) {
    if (nombre == 'Nueva Orden' || nombre == 'Orden') {
      final cart = context.read<CartProvider>();
      cart.createNewOrder();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderNewScreen(
            orden: cart.activeOrder!,
            user: widget.user,
            isOld: false,
          ),
        ),
      );
      return;
    }

    if (nombre == 'Revisar Inventario') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewInventScreen(user: widget.user),
        ),
      );
      return;
    }

    if (nombre == 'Agregar Compra') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddCompraScreen(
            user: widget.user,
            compra: Compra(rolls: []),
            fechaFactura: DateTime.now(),
            fechaFacturaRecepcion: DateTime.now(),
          ),
        ),
      );
      return;
    }

    if (nombre == 'Ordenes') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PedidosScreen(user: widget.user),
        ),
      );
      return;
    }
    if (nombre == 'Entrada Almacen') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const OrdenEntradaScreen(status: 'EnBodega'),
        ),
      );
      return;
    }
    if (nombre == 'Crear Producto') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddNewProductScreen(user: widget.user),
        ),
      );
      return;
    }
    if (nombre == 'Consultar Producto') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewProdSearch(user: widget.user),
        ),
      );
      return;
    }
    if (nombre == 'Cerrar Sesion') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }
    if (nombre == 'Agregar Rollo') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddRollScreen(user: widget.user),
        ),
      );
      return;
    }

    if (nombre == 'Inventario') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InventarioScreen(user: widget.user),
        ),
      );
      return;
    }
    if (nombre == 'Compras') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompasScreen(user: widget.user),
        ),
      );
      return;
    }
    if (nombre == 'Medir Rollo') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MeasureRollScreen(user: widget.user),
        ),
      );
      return;
    }
    if (nombre == 'Finalizar Rollo') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinalizeRollScreen(user: widget.user),
        ),
      );
      return;
    }
    if (nombre == 'Mermas / Daños') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DamageRollScreen(user: widget.user),
        ),
      );
      return;
    }
    if (nombre == 'Verificar Medida') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyRollScreen(user: widget.user),
        ),
      );
      return;
    }
  }
}
