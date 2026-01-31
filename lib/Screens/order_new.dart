import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fabrics_app/Components/custom_appbar_scan.dart';
import 'package:fabrics_app/Helpers/api_helper.dart';
import 'package:fabrics_app/Models/detalle.dart';
import 'package:fabrics_app/Models/order.dart';
import 'package:fabrics_app/Models/response.dart';
import 'package:fabrics_app/Models/user.dart';
import 'package:fabrics_app/Screens/add_product_old.dart';
import 'package:fabrics_app/Screens/add_product_screen.dart';
import 'package:fabrics_app/Screens/home_screen_modern.dart';
import 'package:fabrics_app/constans.dart';
import 'package:provider/provider.dart';
import 'package:fabrics_app/Providers/cart_provider.dart';

class OrderNewScreen extends StatefulWidget {
  const OrderNewScreen({
    super.key,
    required this.orden,
    required this.user,
    required this.isOld,
  });
  final Order orden;
  final User user;
  final bool isOld;
  @override
  State<OrderNewScreen> createState() => _OrderNewScreenState();
}

class _OrderNewScreenState extends State<OrderNewScreen> {
  bool showLoader = false;

  @override
  Widget build(BuildContext context) {
    context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarScan(
        press: () => goMenu(),
        titulo: Consumer<CartProvider>(
          builder: (context, cart, child) {
            int index = cart.activeIndex;
            return Text(
              index != -1 ? 'Orden #${index + 1}' : 'Nueva Orden',
              style: GoogleFonts.oswald(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
        image: const AssetImage("assets/logoKGrande.png"),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kPrimaryColor.withValues(alpha: 0.05), Colors.white],
              ),
            ),
          ),
          _getContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    final cart = context.read<CartProvider>();
    double total = cart.totalAmount;

    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: kGradientHome,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Add Button
              RawMaterialButton(
                onPressed: _goAdd,
                elevation: 4.0,
                fillColor: Colors.white.withValues(alpha: 0.15),
                padding: const EdgeInsets.all(12.0),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add_shopping_cart,
                  size: 28.0,
                  color: Colors.white,
                ),
              ),

              // Total Info
              if (cart.items.isNotEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${cart.itemCount} Productos',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '\$${NumberFormat("###,000", "es_CO").format(total)}',
                      style: GoogleFonts.oswald(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

              // Save Button
              RawMaterialButton(
                onPressed: goSave,
                elevation: 4.0,
                fillColor: const Color(0xFFE4C643),
                padding: const EdgeInsets.all(12.0),
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.save_outlined,
                  size: 28.0,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void goSave() async {
    final cart = context.read<CartProvider>();
    if (cart.items.isEmpty) {
      await Fluttertoast.showToast(
        msg: 'No hay productos para guardar',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }
    setState(() {
      showLoader = true;
    });

    cart.setDocumentUser(widget.user.document);
    Map<String, dynamic> request = cart.activeOrder!.toJson();

    Response response = Response(isSuccess: false);
    if (widget.isOld) {
      response = await ApiHelper.post('api/kilos/PostOrderOld/', request);
    } else {
      response = await ApiHelper.post('api/kilos/PostOrder/', request);
    }

    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
      showErrorFromDialog(response.message);
      return;
    }

    setState(() {
      cart.clearCart();
    });

    await Fluttertoast.showToast(
      msg: 'Orden Guardada Correctamente',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      backgroundColor: const Color.fromARGB(255, 14, 131, 29),
      textColor: Colors.white,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreenModern(user: widget.user),
        ),
      );
    }
    return;
  }

  Widget _getContent() {
    final cart = context.read<CartProvider>();
    return cart.items.isEmpty ? _noContent() : _getList();
  }

  void _goAdd() {
    if (widget.isOld == false) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AddProductScreen(
            user: widget.user,
            orden: context.read<CartProvider>().activeOrder!,
            ruta: "New",
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AddOldProduct(
            user: widget.user,
            orden: context.read<CartProvider>().activeOrder!,
            ruta: "Old",
          ),
        ),
      );
    }
  }

  _noContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: kPrimaryColor.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '¡Tu carrito está vacío!',
            style: GoogleFonts.oswald(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega productos para comenzar\ntu nueva orden.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  _getList() {
    final cart = context.watch<CartProvider>();
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: cart.itemCount,
      itemBuilder: (context, index) {
        final detalle = cart.items[index];
        final itemKey = detalle.codigoRollo.toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Dismissible(
              key: Key(itemKey),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => _confirmDelete(),
              onDismissed: (_) {
                cart.removeItem(index);
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: kColorRed.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.delete_outline,
                  color: kColorRed,
                  size: 28,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // Color strip
                    Container(width: 6, color: kPrimaryColor),

                    // Product Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              detalle.producto ?? "Sin nombre",
                              style: GoogleFonts.oswald(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                            Text(
                              detalle.color ?? "Color no especificado",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildInfoChip(
                                  Icons.straighten,
                                  '${detalle.cantidad} m',
                                ),
                                const SizedBox(width: 12),
                                _buildInfoChip(
                                  Icons.sell_outlined,
                                  '\$${NumberFormat("###,000", "es_CO").format(detalle.price)}',
                                ),
                              ],
                            ),
                            const Spacer(),
                            const SizedBox(height: 8),
                            Text(
                              '\$${NumberFormat("###,000", "es_CO").format(detalle.total)}',
                              style: GoogleFonts.oswald(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Edit Button
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Center(
                        child: RawMaterialButton(
                          onPressed: () => _showFilter(detalle),
                          elevation: 2.0,
                          fillColor: const Color(0xFFE4C643),
                          padding: const EdgeInsets.all(8.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 22.0,
                            color: Colors.black87,
                          ),
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
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: kPrimaryColor.withValues(alpha: 0.6)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: kPrimaryColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Eliminar?'),
        content: const Text('¿Desea eliminar este producto de la orden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }

  void goMenu() {
    final cart = context.read<CartProvider>();
    // Si la orden es nueva (local) y está vacía, la borramos al salir
    if (!widget.isOld && cart.items.isEmpty) {
      cart.removeActiveOrder();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreenModern(user: widget.user),
      ),
    );
  }

  Future<void> _showFilter(Detalle detalle) => showDialog(
    context: context,
    builder: (context) {
      double cantidad = detalle.cantidad ?? 0.0;
      double precio = detalle.price ?? 0.0;

      TextEditingController cantidadController = TextEditingController(
        text: cantidad.toString(),
      );
      TextEditingController precioController = TextEditingController(
        text: precio.toString(),
      );

      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          title: Column(
            children: [
              Text(
                'Editar Producto',
                style: GoogleFonts.oswald(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${detalle.producto} - ${detalle.color}',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 15),
              const Divider(),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Quantity Section
                _buildEditRow(
                  label: "Cantidad (m)",
                  icon: Icons.straighten,
                  controller: cantidadController,
                  onDecrement: () {
                    setState(() {
                      cantidad = (cantidad - 0.5).clamp(0.0, double.infinity);
                      cantidadController.text = cantidad.toStringAsFixed(1);
                    });
                  },
                  onIncrement: () {
                    setState(() {
                      cantidad += 0.5;
                      cantidadController.text = cantidad.toStringAsFixed(1);
                    });
                  },
                  onChanged: (v) => cantidad = double.tryParse(v) ?? 0.0,
                ),

                const SizedBox(height: 25),

                // Price Section
                _buildEditRow(
                  label: "Precio (\$)",
                  icon: Icons.payments_outlined,
                  controller: precioController,
                  onDecrement: () {
                    setState(() {
                      precio = (precio - 100).clamp(0.0, double.infinity);
                      precioController.text = precio.toStringAsFixed(0);
                    });
                  },
                  onIncrement: () {
                    setState(() {
                      precio += 100;
                      precioController.text = precio.toStringAsFixed(0);
                    });
                  },
                  onChanged: (v) => precio = double.tryParse(v) ?? 0.0,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                detalle.cantidad = cantidad;
                detalle.price = precio;
                detalle.total = precio * cantidad;
                context.read<CartProvider>().addItem(detalle);
                _editar();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE4C643),
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Guardar Cambios',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    },
  );

  Widget _buildEditRow({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: kPrimaryColor.withValues(alpha: 0.5)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildCircularButton(
              Icons.remove,
              onDecrement,
              Colors.grey[100]!,
              Colors.black54,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: TextField(
                controller: controller,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: onChanged,
                style: GoogleFonts.oswald(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: kPrimaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            _buildCircularButton(
              Icons.add,
              onIncrement,
              kPrimaryColor.withValues(alpha: 0.1),
              kPrimaryColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularButton(
    IconData icon,
    VoidCallback onTap,
    Color bgColor,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }

  _editar() {
    setState(() {});
  }

  void showErrorFromDialog(String msg) async {
    await showAlertDialog(
      context: context,
      title: 'Error',
      message: msg,
      actions: <AlertDialogAction>[
        const AlertDialogAction(key: null, label: 'Aceptar'),
      ],
    );
  }
}
