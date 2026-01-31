import 'package:fabrics_app/Components/card_movs.dart';
import 'package:fabrics_app/Components/card_roll.dart';
import 'package:fabrics_app/Components/combo_colores.dart';
import 'package:fabrics_app/Components/combo_products.dart';
import 'package:fabrics_app/Components/default_button.dart';
import 'package:fabrics_app/Components/loader_component.dart';
import 'package:fabrics_app/Components/scan_bar_code.dart';
import 'package:fabrics_app/Components/scan_screen.dart';
import 'package:fabrics_app/Components/text_derecha.dart';
import 'package:fabrics_app/Components/text_encabezado.dart';
import 'package:fabrics_app/Helpers/api_helper.dart';
import 'package:fabrics_app/Helpers/scanner_helper.dart';
import 'package:fabrics_app/Models/descuento.dart';
import 'package:fabrics_app/Models/product.dart';
import 'package:fabrics_app/Models/response.dart';
import 'package:fabrics_app/Models/user.dart';
import 'package:fabrics_app/Screens/home_screen_modern.dart';
import 'package:fabrics_app/Components/custom_appbar_scan.dart';
import 'package:fabrics_app/constans.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ConsultaProductoScreen extends StatefulWidget {
  const ConsultaProductoScreen({super.key, required this.user});
  final User user;
  @override
  State<ConsultaProductoScreen> createState() => _ConsultaProductoScreenState();
}

class _ConsultaProductoScreenState extends State<ConsultaProductoScreen> {
  String? scanResult;
  TextEditingController codigoController = TextEditingController();
  String codigoError = '';
  bool codigoShowError = false;

  TextEditingController codProController = TextEditingController();
  String codProError = '';
  bool codProShowError = false;

  bool showLoader = false;
  Product product = Product();
  List<Descuento> movs = [];

  bool swicht = true;

  List<Product> products = [];
  List<Product> colores = [];

  Product auxProduct = Product();
  Product auxColor = Product();

  @override
  void initState() {
    super.initState();
    _getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kContrastColorMedium,
        appBar: CustomAppBarScan(
          press: goBack,
          titulo: Text(
            'Consulta Producto',
            style: GoogleFonts.oswald(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                swicht == false ? Icons.switch_right : Icons.switch_left,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => setState(() {
                swicht = !swicht;
              }),
            ),
          ],
        ),
        body: swicht ? formProduct() : _showProductResult(context),
      ),
    );
  }

  Widget formProduct() {
    return Stack(
      children: [
        Container(
          color: kContrastColor,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ScanBarCode(press: scanBarCode),
                  Container(color: kColorAlternativo, child: _showCodigo()),
                  Container(
                    color: kColorAlternativo,
                    child: _showCodigoProducto(),
                  ),
                  Container(height: 15, color: kContrastColor),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      color: kContrastColor,
                      child: Card(
                        color: Colors.white,
                        shadowColor: kPrimaryColor,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            ComboProducts(
                              onChanged: _goChange,
                              backgroundColor: Colors.white,
                              products: products,
                              titulo: 'Productos',
                            ),
                            ComboColores(
                              onChanged: _goChangeColor,
                              backgroundColor: Colors.white,
                              products: colores,
                              titulo: 'Color',
                            ),
                            const SizedBox(height: 10),
                            DefaultButton(
                              text: 'Buscar',
                              press: goBuscarSelect,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        showLoader ? const LoaderComponent(text: 'Cargando') : Container(),
      ],
    );
  }

  Future<void> _getProducts() async {
    setState(() {
      showLoader = true;
    });

    Response response = await ApiHelper.getProducts();

    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
      await Fluttertoast.showToast(
        msg: 'Error: ${response.message}',
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
      products = response.result;
    });
  }

  Future<void> _getColors() async {
    if (auxProduct.descripcion == null) {
      return;
    }

    setState(() {
      colores.clear();
      showLoader = true;
    });

    Map<String, dynamic> request = {
      'supId': 1,
      'descripcion': auxProduct.descripcion,
    };

    Response response = await ApiHelper.getProductColors(request);

    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
      await Fluttertoast.showToast(
        msg: 'Error: ${response.message}',
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
      colores = response.result;
    });
  }

  Widget _showProductResult(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (product.descripcion != null) _showInfo(context),
            if ((product.rolls?.isNotEmpty ?? false)) _showListRolls(context),
            if (movs.isNotEmpty) _showListMovs(context),
          ],
        ),
      ),
    );
  }

  Widget _showListRolls(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Rollos'),
          SizedBox(
            height: 160,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => CardRoll(roll: product.rolls![i]),
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: product.rolls!.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _showListMovs(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Movimientos'),
          Container(
            height: 180,
            padding: const EdgeInsets.all(10),
            child: ListWheelScrollView.useDelegate(
              perspective: 0.0025,
              itemExtent: 86,
              physics: const FixedExtentScrollPhysics(),
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (_, i) => CardMovimiento(descuento: movs[i]),
                childCount: movs.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _showInfo(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textPrimary = cs.onSurface;
    final n = NumberFormat("##.0#", "en_US");

    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            product.descripcion!,
            textAlign: TextAlign.center,
            style: GoogleFonts.oswald(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 16, thickness: 1, color: Colors.white12),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'Color', value: product.color ?? '-'),
              _InfoChip(label: 'Unidad', value: product.medida ?? '-'),
              _InfoChip(
                label: 'Rollos',
                value: '${product.rolls?.length ?? 0}',
              ),
              _InfoChip(label: 'Stock', value: '${product.stock ?? 0}'),
              _InfoChip(
                label: 'Bodega',
                value: '${product.stockEnBodega ?? 0}',
              ),
              _InfoChip(
                label: 'Almacén',
                value: '${product.stockEnAlmacen ?? 0}',
              ),
              _InfoChip(
                label: 'Últ. Entrada',
                value: product.ultimaEntrada ?? '-',
              ),
              _InfoChip(
                label: 'Tot. Entradas',
                value: '${product.totalEntradas ?? 0}',
              ),
              _InfoChip(
                label: 'Tot. Salidas',
                value: '${product.totalSalidas ?? 0}',
              ),
              _InfoChip(
                label: 'Prom. Compra',
                value: n.format(product.precioPromedio ?? 0),
              ),
              _InfoChip(
                label: 'Últ. Compra',
                value: n.format(product.ultimoPrecio ?? 0),
              ),
              _InfoChip(label: 'Prom. Venta', value: product.promVenta ?? '-'),
              _InfoChip(label: 'Últ. Venta', value: product.ultimaVenta ?? '-'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _showCodigo() {
    return Container(
      color: kContrastColor,
      padding: const EdgeInsets.only(left: 50.0, right: 50, top: 20),
      child: TextField(
        controller: codigoController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          hoverColor: const Color.fromARGB(255, 19, 47, 70),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: kPrimaryColor, width: 5),
          ),
          hintText: 'Ingresa el codigo...',
          labelText: 'Codigo Rollo',
          errorText: codigoShowError ? codigoError : null,
          suffixIcon: IconButton(
            iconSize: 40,
            onPressed: goGetProduct,
            icon: const Icon(
              Icons.search_sharp,
              color: Color.fromARGB(255, 35, 145, 39),
            ),
          ),
        ),
      ),
    );
  }

  Widget _showCodigoProducto() {
    return Container(
      color: kContrastColor,
      padding: const EdgeInsets.only(left: 50.0, right: 50, top: 20),
      child: TextField(
        controller: codProController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          hoverColor: const Color.fromARGB(255, 19, 47, 70),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: kPrimaryColor, width: 5),
          ),
          hintText: 'Ingresa el codigo...',
          labelText: 'Codigo Producto',
          errorText: codProShowError ? codProError : null,
          suffixIcon: IconButton(
            iconSize: 40,
            onPressed: goProductByID,
            icon: const Icon(
              Icons.search_sharp,
              color: Color.fromARGB(255, 35, 145, 39),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateCodigo() {
    bool isValid = true;

    if (codigoController.text.isEmpty) {
      isValid = false;
      codigoShowError = true;
      codigoError = 'Digite el Codigo.';
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

  void goGetProduct() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    if (!_validateCodigo()) {
      return;
    }
    int code22 = int.parse(codigoController.text);
    _getProduct(code22);
  }

  Future scanBarCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    );
    if (result != null) {
      setState(() {
        scanResult = result;
      });
    }
    _getProductScan();
  }

  Future _getProduct(int code) async {
    setState(() {
      showLoader = true;
    });

    Response response = await ApiHelper.getProductByRoll(code);

    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
      await Fluttertoast.showToast(
        msg: 'Error: ${response.message}',
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
      product = response.result;
    });

    List<Descuento> descAux = [];
    for (var v in product.rolls!) {
      descAux.addAll(v.descuentos!);
    }

    setState(() {
      movs = descAux;
      swicht = false;
    });
  }

  Future _getProductScan() async {
    var cides = scanResult ?? '';
    if (cides.isEmpty) {
      return;
    }
    if (cides == '-1') {
      return;
    }

    setState(() {
      showLoader = true;
    });

    int? code = ScannerHelper.extractRollId(cides);
    if (code == null) {
      await Fluttertoast.showToast(msg: 'Código inválido');
      return;
    }
    Response response = await ApiHelper.getProductByRoll(code);

    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
      await Fluttertoast.showToast(
        msg: 'Error: ${response.message}',
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
      product = response.result;
      codigoController.text = code.toString();
      swicht = false;
    });
  }

  goBack() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreenModern(user: widget.user),
      ),
    );
  }

  refrescar() {
    setState(() {
      swicht = true;
    });
  }

  void _goChange(selectedItem) {
    setState(() {
      auxProduct = selectedItem;
    });
    _getColors();
  }

  void _goChangeColor(selectedItem) {
    setState(() {
      auxColor = selectedItem;
    });
  }

  Future goProductByID() async {
    if (codProController.text.isEmpty) {
      await Fluttertoast.showToast(
        msg: "Digite el codigo del producto",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 48, 168, 84),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (int.tryParse(codProController.text) == null) {
      await Fluttertoast.showToast(
        msg: "Digite un numero valido",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 48, 168, 84),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    int cod = int.parse(codProController.text);

    _getProductById(cod);
  }

  Future goBuscarSelect() async {
    if (auxColor.descripcion == null) {
      await Fluttertoast.showToast(
        msg: "Seleccione un Producto y/o Color",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 48, 168, 84),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    _getProductById(auxColor.id!);
  }

  Future _getProductById(int code) async {
    setState(() {
      showLoader = true;
    });

    Response response = await ApiHelper.getPRoductById(code);

    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
      await Fluttertoast.showToast(
        msg: 'Error: ${response.message}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    Product aux = response.result;

    List<Descuento> descAux = [];
    for (var v in aux.rolls!) {
      descAux.addAll(v.descuentos!);
    }

    setState(() {
      movs = descAux;
      swicht = false;
      product = response.result;
    });
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary.withOpacity(.20), cs.secondary.withOpacity(.10)],
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
            letterSpacing: .4,
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withOpacity(.9),
              ),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: cs.onSurface.withOpacity(.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
