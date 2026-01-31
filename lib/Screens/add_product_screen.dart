import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fabrics_app/Components/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fabrics_app/Components/custom_appbar_scan.dart';
import 'package:fabrics_app/Components/loader_component.dart';
import 'package:fabrics_app/Helpers/api_helper.dart';
import 'package:fabrics_app/Helpers/scanner_helper.dart';
import 'package:fabrics_app/Models/detalle.dart';
import 'package:fabrics_app/Models/order.dart';
import 'package:fabrics_app/Models/response.dart';
import 'package:fabrics_app/Models/roll.dart';
import 'package:fabrics_app/Models/user.dart';
import 'package:fabrics_app/Screens/edit_order_screem.dart';
import 'package:fabrics_app/Screens/order_new.dart';
import 'package:fabrics_app/constans.dart';
import 'package:provider/provider.dart';
import 'package:fabrics_app/Providers/cart_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({
    super.key,
    required this.orden,
    required this.user,
    required this.ruta,
  });
  final String ruta;
  final Order orden;
  final User user;
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String? scanResult;
  bool showLoader = false;
  TextEditingController precioController = TextEditingController();
  TextEditingController codigoController = TextEditingController();
  String codigoError = '';
  bool codigoShowError = false;
  TextEditingController scanController = TextEditingController();
  String precioError = '';
  bool precioShowError = false;
  TextEditingController cantidadController = TextEditingController();
  String cantidadError = '';
  bool cantidadShowError = false;
  Roll rollAux = Roll();
  double cantidad = 0;
  bool isProductFound = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarScan(
        press: () => goBack(),
        titulo: Text(
          isProductFound ? 'Agregar Producto' : 'Buscar Producto',
          style: GoogleFonts.oswald(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        image: const AssetImage('assets/logoKGrande.png'),
      ),
      bottomNavigationBar: isProductFound ? _buildBottomBar() : null,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kPrimaryColor.withOpacity(0.05), Colors.white],
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isProductFound) ...[
                  // Scan Section
                  _buildScanSection(),

                  const SizedBox(height: 25),

                  // Separator
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: kPrimaryColor.withValues(alpha: 0.1),
                          thickness: 3,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "O",
                          style: GoogleFonts.poppins(
                            color: Colors.black26,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: kPrimaryColor.withValues(alpha: 0.1),
                          thickness: 3,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Manual Code Entry Label
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.keyboard_outlined,
                          size: 16,
                          color: kPrimaryColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "BÚSQUEDA MANUAL",
                          style: GoogleFonts.oswald(
                            fontSize: 14,
                            letterSpacing: 1,
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Manual Code Entry Field
                  _buildSearchField(),
                ],

                if (isProductFound) ...[
                  // Product Info Card
                  _buildProductInfoCard(),

                  const SizedBox(height: 12),

                  // Change Product Link (More visible)
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isProductFound = false;
                          rollAux = Roll();
                          codigoController.clear();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: kPrimaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "¿No es este producto? Cambiar",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: kPrimaryColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Inputs Section
                  _buildNumericInput(
                    label: "Cantidad a despachar",
                    icon: Icons.straighten,
                    controller: cantidadController,
                    onDecrement: () =>
                        _adjustValue(cantidadController, -0.5, true),
                    onIncrement: () =>
                        _adjustValue(cantidadController, 0.5, true),
                    onChanged: (v) => _validateCantidad(v),
                  ),

                  const SizedBox(height: 20),

                  _buildNumericInput(
                    label: "Precio de orden",
                    icon: Icons.payments_outlined,
                    controller: precioController,
                    onDecrement: () =>
                        _adjustValue(precioController, -100, false),
                    onIncrement: () =>
                        _adjustValue(precioController, 100, false),
                    onChanged: (v) =>
                        setState(() {}), // Trigger refresh for real-time total
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),

          if (showLoader) const LoaderComponent(text: 'Cargando'),
        ],
      ),
    );
  }

  void _addProduct() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    var pId = rollAux.product?.id;
    if (pId == null) {
      await Fluttertoast.showToast(
        msg: "Seleccione un Producto",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (!_validateFields()) {
      return;
    }
    Detalle detailAux = Detalle();
    detailAux.producto = rollAux.product!.descripcion;
    detailAux.cantidad = double.parse(cantidadController.text);
    detailAux.price = double.parse(precioController.text);
    detailAux.codigoRollo = rollAux.id ?? 0;
    detailAux.codigoProducto = rollAux.product!.id ?? 0;
    detailAux.color = rollAux.product!.color!;
    double var2 = detailAux.cantidad ?? 0;

    double var3 = detailAux.price ?? 0;
    detailAux.total = var3 * var2;

    if (var2 > var3) {
      await Fluttertoast.showToast(
        msg: "Por favor revise los valores\nCantidad y Precio.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      return;
    }

    context.read<CartProvider>().addItem(detailAux);

    setState(() {
      isProductFound = false;
      rollAux = Roll();
      codigoController.clear();
      precioController.clear();
      cantidadController.text = "1";
      cantidad = 1;
    });

    await Fluttertoast.showToast(
      msg: "Producto agregado",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    if (widget.ruta == "Edit") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => EditOrderScreen(
            orden: widget.orden,
            user: widget.user,
            isOld: true,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderNewScreen(
            orden: widget.orden,
            user: widget.user,
            isOld: false,
          ),
        ),
      );
    }
  }

  void _adjustValue(
    TextEditingController controller,
    double delta,
    bool isDecimal,
  ) {
    setState(() {
      double current = double.tryParse(controller.text) ?? 0.0;
      current = (current + delta).clamp(0.0, double.infinity);
      controller.text = isDecimal
          ? current.toStringAsFixed(1)
          : current.toStringAsFixed(0);
      if (isDecimal) cantidad = current;
    });
  }

  Widget _buildScanSection() {
    return GestureDetector(
      onTap: scanBarCode,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: kGradientHome,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
            const SizedBox(width: 15),
            Text(
              "ESCANEAR CÓDIGO",
              style: GoogleFonts.oswald(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: codigoController,
        keyboardType: TextInputType.number,
        style: GoogleFonts.oswald(
          fontSize: 20,
          color: kPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: 'Ingresa el código del rollo...',
          hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          errorText: codigoShowError ? codigoError : null,
          suffixIcon: Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: goGetProduct,
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 24,
              ),
              style: IconButton.styleFrom(
                backgroundColor: kPrimaryColor,
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: kPrimaryColor.withValues(alpha: 0.4),
              ),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 6, color: kPrimaryColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rollAux.product?.descripcion ?? "Producto encontrado",
                      style: GoogleFonts.oswald(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Larger Color Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.palette_outlined,
                                size: 18,
                                color: kPrimaryColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                rollAux.product?.color ?? "-",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${rollAux.product?.stock} Disp.',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumericInput({
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
            Icon(icon, size: 16, color: kPrimaryColor.withOpacity(0.5)),
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
            _circularButton(
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
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[200]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: kPrimaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            _circularButton(
              Icons.add,
              onIncrement,
              kPrimaryColor.withValues(alpha: 0.05),
              kPrimaryColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _circularButton(
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

  Widget _buildBottomBar() {
    double precioActual = double.tryParse(precioController.text) ?? 0;
    double total = cantidad * precioActual;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL PRODUCTO',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '\$${NumberFormat("###,000", "es_CO").format(total)}',
                      style: GoogleFonts.oswald(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add_shopping_cart, size: 20),
                label: Text(
                  'AGREGAR',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE4C643),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _validateCantidad(String value) {
    setState(() {
      if (value.isEmpty) {
        cantidadShowError = true;
        cantidadError = 'La cantidad no puede estar vacía.';
        cantidad = 0.0;
      } else {
        double? parsedValue = double.tryParse(value);
        if (parsedValue == null) {
          cantidadShowError = true;
          cantidadError = 'Ingresa un número válido.';
          cantidad = 0.0;
        } else if (parsedValue < 0) {
          cantidadShowError = true;
          cantidadError = 'La cantidad no puede ser negativa.';
          cantidad = parsedValue;
        } else {
          cantidadShowError = false;
          cantidadError = '';
          cantidad = parsedValue;
        }
      }
    });
  }

  void goGetProduct() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (!_validateCodigo()) {
      return;
    }
    int code22 = int.parse(codigoController.text);
    _getRollCodigo(code22);
  }

  Future _getRollCodigo(int codigo) async {
    setState(() {
      showLoader = true;
    });
    Response response = await ApiHelper.getRoll(codigo);
    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
      await Fluttertoast.showToast(
        msg: "El rollo no existe",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      rollAux = response.result;
      isProductFound = true;
      cantidadController.text = 1.toString();
      cantidad = 1;
      precioController.text = rollAux.product!.venta.toString().substring(
        0,
        rollAux.product!.venta.toString().length - 3,
      );
    });
  }

  bool _validateFields() {
    bool isValid = true;

    if (cantidadController.text.isEmpty) {
      isValid = false;
      cantidadShowError = true;
      cantidadError = 'Debes ingresar la Cantidad.';
    } else {
      cantidadShowError = false;
    }

    if (cantidad == 0) {
      isValid = false;
      cantidadShowError = true;
      cantidadError = 'Debes ingresar un numero correcto.';
    } else {
      cantidadShowError = false;
    }

    if (precioController.text.isEmpty) {
      isValid = false;
      precioShowError = true;
      precioError = 'Debes ingresar el Precio.';
    } else {
      precioShowError = false;
    }

    if (double.tryParse(precioController.text) == null) {
      isValid = false;
      precioShowError = true;
      precioError = 'Debes ingresar un numero correcto.';
    } else {
      precioShowError = false;
    }

    setState(() {});
    return isValid;
  }

  bool _validateCodigo() {
    bool isValid = true;

    if (codigoController.text.isEmpty) {
      isValid = false;
      codigoShowError = true;
      codigoError = 'Debes el Codigo.';
    } else {
      codigoShowError = false;
    }

    if (int.tryParse(codigoController.text) == null) {
      isValid = false;
      codigoShowError = true;
      codigoError = 'Debes ingresar un numero correcto.';
    } else {
      codigoShowError = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> scanBarCode() async {
    // Navega a la pantalla de escaneo y espera el resultado
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    );

    if (result != null && result is String && mounted) {
      await _getRoll(result);
    } else {
      showErrorFromDialog('No se obtuvo un código válido del escáner.');
    }
  }

  Future<void> _getRoll(String cod) async {
    try {
      if (!mounted) return; // Verificar si el widget está montado

      setState(() {
        showLoader = true;
      });
      int? code = ScannerHelper.extractRollId(cod);
      if (code == null) {
        showErrorFromDialog('Código inválido');
        return;
      }
      Response response = await ApiHelper.getRoll(code);

      setState(() {
        showLoader = false;
      });

      if (!response.isSuccess) {
        showErrorFromDialog(response.message);
        return;
      }

      rollAux = response.result;

      String normalized = rollAux.product!.venta!
          .replaceAll('.', '')
          .replaceAll(',', '.');

      double parseDouble = double.parse(normalized);
      int parsedInt = parseDouble.toInt();

      setState(() {
        showLoader = false;
        rollAux = response.result;
        isProductFound = true;
        codigoController.text = rollAux.id.toString();
        precioController.text = parsedInt.toString();
        cantidad = 1;
        cantidadController.text = 1.toString();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          showLoader = false;
        });
        showErrorFromDialog('Ocurrió un error: $e');
      }
    }
  }

  goBack() async {
    if (isProductFound) {
      setState(() {
        isProductFound = false;
        rollAux = Roll();
        codigoController.clear();
      });
      return;
    }

    if (widget.ruta == "Edit") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => EditOrderScreen(
            user: widget.user,
            orden: context.read<CartProvider>().activeOrder!,
            isOld: false,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderNewScreen(
            user: widget.user,
            orden: context.read<CartProvider>().activeOrder!,
            isOld: false,
          ),
        ),
      );
    }
  }

  void showErrorFromDialog(String msg) async {
    if (!mounted) return;
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
