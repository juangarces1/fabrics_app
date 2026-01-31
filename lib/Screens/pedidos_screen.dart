import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fabrics_app/Components/custom_appbar_scan.dart';
import 'package:fabrics_app/Components/loader_component.dart';
import 'package:fabrics_app/Helpers/api_helper.dart';
import 'package:fabrics_app/Models/detalle.dart';
import 'package:fabrics_app/Models/order.dart';
import 'package:fabrics_app/Models/orderview.dart';
import 'package:fabrics_app/Models/response.dart';
import 'package:fabrics_app/Models/user.dart';
import 'package:fabrics_app/Screens/detail_pedido_screen.dart';
import 'package:fabrics_app/Screens/edit_order_screem.dart';
import 'package:fabrics_app/Screens/home_screen_modern.dart';
import 'package:fabrics_app/constans.dart';
import 'package:provider/provider.dart';
import 'package:fabrics_app/Providers/cart_provider.dart';

class PedidosScreen extends StatefulWidget {
  final User user;

  const PedidosScreen({super.key, required this.user});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  List<OrderView> pedidos = [];
  bool showLoader = false;

  @override
  void initState() {
    super.initState();
    _getOrdenes();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<CartProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarScan(
        press: () => goMenu(),
        titulo: Text(
          'Listado de Ordenes',
          style: GoogleFonts.oswald(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        image: const AssetImage('assets/logoKGrande.png'),
      ),
      body: Stack(
        children: [
          // Main Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  kPrimaryColor.withValues(alpha: 0.08),
                  const Color.fromARGB(
                    255,
                    175,
                    175,
                    200,
                  ).withValues(alpha: 0.4),
                  const Color.fromARGB(
                    255,
                    202,
                    202,
                    233,
                  ).withValues(alpha: 0.2),
                ],
              ),
            ),
          ),
          showLoader
              ? const LoaderComponent(text: 'Por favor espere...')
              : _getContent(),
        ],
      ),
      bottomNavigationBar: _buildBottomSummary(),
    );
  }

  Widget _buildBottomSummary() {
    if (pedidos.isEmpty) return const SizedBox.shrink();

    final totalAmount = pedidos
        .map((item) => item.total!)
        .reduce((value, element) => value + element);

    return Container(
      height: 90,
      decoration: const BoxDecoration(
        gradient: kGradientHome,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pedidos.length} Ordenes',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  'Hoy',
                  style: GoogleFonts.oswald(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Total General',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  '\$${NumberFormat("###,000", "es_CO").format(totalAmount)}',
                  style: GoogleFonts.oswald(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getContent() {
    return pedidos.isEmpty ? _noContent() : _getList();
  }

  Future<void> _getOrdenes() async {
    setState(() {
      showLoader = true;
    });

    Response response = await ApiHelper.getOrdersByUser(
      widget.user.document ?? '',
    );

    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
      showErrorFromDialog(response.message);
      return;
    }

    setState(() {
      pedidos = response.result;
    });
  }

  _noContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: kPrimaryColor.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Sin ordenes registradas',
            style: GoogleFonts.oswald(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las órdenes que crees hoy aparecerán aquí.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  _getList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: pedidos.length,
      itemBuilder: (context, index) {
        final pedido = pedidos[index];
        return _buildOrderCard(pedido);
      },
    );
  }

  Widget _buildOrderCard(OrderView pedido) {
    bool isCreada = pedido.estado == "Creada";
    Color statusColor = isCreada ? kBlueColorLogo : Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Dismissible(
          key: Key(pedido.id.toString()),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) => _confirmDelete(),
          onDismissed: (_) => goDelete(pedido),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: kColorRed.withValues(alpha: 0.1),
            child: SvgPicture.asset(
              "assets/Trash.svg",
              color: kColorRed,
              height: 25,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Status Accent Bar
                Container(width: 6, color: statusColor),
                // Order Info
                Expanded(
                  child: GestureDetector(
                    onTap: () => goDetail(pedido),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'Orden #${pedido.id}',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.oswald(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(
                                pedido.estado ?? "Desconocido",
                                statusColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                pedido.hora ?? '--:--',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.shopping_bag_outlined,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${pedido.productos} prods',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.visibility_outlined,
                                  size: 18,
                                  color: kPrimaryColor.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '\$${NumberFormat("###,000", "es_CO").format(pedido.total)}',
                            style: GoogleFonts.oswald(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Edit Button (if applies)
                if (isCreada)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Center(
                      child: RawMaterialButton(
                        onPressed: () => goEdit(pedido),
                        elevation: 2.0,
                        fillColor: const Color.fromARGB(255, 228, 198, 67),
                        padding: const EdgeInsets.all(8.0),
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.edit,
                          size: 25.0,
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
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Desea eliminar esta Orden?'),
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

  goDetail(OrderView pedido) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPedidoScreen(pedido: pedido),
      ),
    );
  }

  goEdit(OrderView order) async {
    bool flag = false;
    Detalle det = order.detalles!.first;
    if (det.codigoRollo == 0) {
      flag = true;
    }
    Order editOrder = Order(
      detalles: order.detalles!,
      id: order.id,
      documentUser: widget.user.document,
    );
    context.read<CartProvider>().initializeOrder(editOrder);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            EditOrderScreen(user: widget.user, orden: editOrder, isOld: flag),
      ),
    );
  }

  Future<void> goDelete(OrderView pedido) async {
    setState(() {
      showLoader = true;
    });
    Response response = await ApiHelper.delete(
      '/api/Kilos/DeleteOrder/',
      pedido.id.toString(),
    );
    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
      showErrorFromDialog(response.message);
      setState(() {
        pedidos = pedidos;
      });
      return;
    }

    setState(() {
      pedidos.remove(pedido);
    });
  }

  goMenu() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreenModern(user: widget.user),
      ),
    );
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
