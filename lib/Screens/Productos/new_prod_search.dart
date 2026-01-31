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
import 'package:fabrics_app/constans.dart';
import 'package:fabrics_app/sizeconfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NewProdSearch extends StatefulWidget {
  const NewProdSearch({super.key, required this.user});
  final User user;

  @override
  State<NewProdSearch> createState() => _NewProdSearchState();
}

class _NewProdSearchState extends State<NewProdSearch>
    with SingleTickerProviderStateMixin {
  // Controladores para TabBar
  late TabController _tabController;

  // Controladores de texto
  TextEditingController codigoController = TextEditingController();
  TextEditingController codProController = TextEditingController();

  // Variables para mostrar/ocultar error en TextField (aunque usas Fluttertoast, si quieres mantenerlo)
  String codigoError = '';
  bool codigoShowError = false;

  String codProError = '';
  bool codProShowError = false;

  // Estado de cargando
  bool showLoader = false;

  // Producto que se muestra en detalles
  Product product = Product();

  // Lista de movimientos (Descuentos) combinados de todos los rollos
  List<Descuento> movs = [];

  // Para combos de productos/colores
  List<Product> products = [];
  List<Product> colores = [];
  Product auxProduct = Product();
  Product auxColor = Product();

  // Para almacenar resultado de escaneo
  String? scanResult;

  @override
  void initState() {
    super.initState();
    // Inicializamos TabController para 2 pestañas (Buscar / Detalles)
    _tabController = TabController(length: 2, vsync: this);

    // Cargar la lista de productos
    _getProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ======================== BUILD PRINCIPAL ========================
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kContrastColorMedium,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            height: 70,
            decoration: const BoxDecoration(gradient: kGradientHome),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Botón de retroceso
                  SizedBox(
                    height: getProportionateScreenHeight(40),
                    width: getProportionateScreenWidth(40),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: goBack,
                      child: SvgPicture.asset(
                        "assets/Back ICon.svg",
                        height: 15,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),

                  // Título
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        70,
                        65,
                        65,
                      ).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Consulta Producto',
                      style: GoogleFonts.oswald(
                        fontStyle: FontStyle.normal,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Aquí ya no necesitas el ícono switch, se quita
                  const SizedBox(
                    width: 35,
                  ), // Para ocupar el espacio a la derecha
                ],
              ),
            ),
          ),
        ),

        // Incorporamos un TabBar dentro del body
        body: Stack(
          children: [
            // TabBarView con 2 pantallas
            Column(
              children: [
                // El TabBar
                Container(
                  color: Colors.white10,
                  child: Container(
                    color: const Color.fromARGB(255, 49, 9, 83),
                    child: TabBar(
                      labelStyle: GoogleFonts.oswald(
                        fontStyle: FontStyle.normal,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: const Color.fromARGB(
                        255,
                        110,
                        108,
                        108,
                      ),
                      indicatorColor: Colors.white,
                      tabs: const [
                        Tab(text: "Buscar"),
                        Tab(text: "Detalles"),
                      ],
                    ),
                  ),
                ),

                // El contenido de cada pestaña
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Pestaña 1: Búsqueda
                      _buildSearchTab(),

                      // Pestaña 2: Detalles
                      _buildDetailsTab(context),
                    ],
                  ),
                ),
              ],
            ),

            // Loader
            showLoader ? const LoaderComponent(text: 'Cargando') : Container(),
          ],
        ),
      ),
    );
  }

  // ======================== PESTAÑA DE BÚSQUEDA ========================
  Widget _buildSearchTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Scanner
          ScanBarCode(press: scanBarCode),
          // Código Rollo
          Container(color: kColorAlternativo, child: _showCodigo()),
          // Código Producto
          Container(color: kColorAlternativo, child: _showCodigoProducto()),
          // Separador
          Container(height: 15, color: kContrastColor),

          // Tarjeta con Combos
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
                    // Combo de productos
                    ComboProducts(
                      onChanged: _goChange,
                      backgroundColor: Colors.white,
                      products: products,
                      titulo: 'Productos',
                    ),
                    // Combo de colores
                    ComboColores(
                      onChanged: _goChangeColor,
                      backgroundColor: Colors.white,
                      products: colores,
                      titulo: 'Color',
                    ),
                    const SizedBox(height: 10),
                    // Botón BUSCAR
                    DefaultButton(text: 'Buscar', press: goBuscarSelect),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ======================== PESTAÑA DE DETALLES ========================
  Widget _buildDetailsTab(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (product.descripcion != null) _showInfo(),
            if ((product.rolls?.isNotEmpty ?? false)) _showListRolls(),
            if (movs.isNotEmpty) _showListMovs(),
          ],
        ),
      ),
    );
  }

  // ======================== WIDGETS DE FORMULARIO ========================
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

  // ======================== MÉTODOS DE BÚSQUEDA ========================
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
      codigoError = 'Debes ingresar un número correcto.';
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

  Future<void> _getProduct(int code) async {
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
      // Cambiamos a la pestaña de Detalles
      _tabController.index = 1;
    });
  }

  Future<void> scanBarCode() async {
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

  Future<void> _getProductScan() async {
    var cides = scanResult ?? '';
    if (cides.isEmpty || cides == '-1') {
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
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      product = response.result;
      codigoController.text = code.toString();
      // Vamos a pestaña de Detalles
      _tabController.index = 1;
    });
  }

  Future<void> goProductByID() async {
    if (codProController.text.isEmpty) {
      await Fluttertoast.showToast(
        msg: "Digite el codigo del producto",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
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
        backgroundColor: const Color.fromARGB(255, 48, 168, 84),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    int cod = int.parse(codProController.text);
    _getProductById(cod);
  }

  Future<void> _getProductById(int code) async {
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
      product = aux;
      movs = descAux;
      // Pasamos a Detalles
      _tabController.index = 1;
    });
  }

  // MÉTODO que se llama al pulsar el botón "Buscar" en combos
  Future<void> goBuscarSelect() async {
    if (auxColor.descripcion == null) {
      await Fluttertoast.showToast(
        msg: "Seleccione un Producto y/o Color",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: const Color.fromARGB(255, 48, 168, 84),
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }
    _getProductById(auxColor.id!);
  }

  // ======================== OBTENER LISTA DE PRODUCTOS / COLORES ========================
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

  // Combos
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

  // =================== ROLLOS ===================
  Widget _showListRolls() {
    final count = product.rolls?.length ?? 0;
    if (count == 0) return const SizedBox.shrink();

    return _ExpandableSection(
      title: 'Rollos',
      count: count,
      initiallyExpanded: false,
      child: SizedBox(
        height: 240,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          scrollDirection: Axis.horizontal,
          itemBuilder: (_, i) => CardRoll(roll: product.rolls![i]),
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemCount: count,
        ),
      ),
    );
  }

  // =================== MOVIMIENTOS ===================
  Widget _showListMovs() {
    final count = movs.length;
    if (count == 0) return const SizedBox.shrink();

    return _ExpandableSection(
      title: 'Movimientos',
      count: count,
      initiallyExpanded: false,
      child: Container(
        height: 240,
        padding: const EdgeInsets.all(8),
        child: ListWheelScrollView.useDelegate(
          perspective: 0.0025,
          itemExtent: 86,
          physics: const FixedExtentScrollPhysics(),
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (_, i) => CardMovimiento(descuento: movs[i]),
            childCount: count,
          ),
        ),
      ),
    );
  }

  // ======================== DETALLES DEL PRODUCTO ========================
  Widget _showInfo() {
    final n = NumberFormat("##.0#", "en_US");

    return Container(
      decoration: BoxDecoration(
        color: _DarkPalette.surface.withOpacity(.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _DarkPalette.border),
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
              color: _DarkPalette.textPrimary,
              letterSpacing: .5,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 16, thickness: 1, color: _DarkPalette.divider),
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

  // ======================== NAVEGAR HACIA ATRÁS ========================
  void goBack() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreenModern(user: widget.user),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x338B5CF6), // primary con opacidad
            Color(0x3322D3EE), // secondary con opacidad
          ],
        ),
      ),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.oswald(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _DarkPalette.textPrimary,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _DarkPalette.surfaceVariant.withOpacity(.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DarkPalette.border),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _DarkPalette.textSecondary,
              ),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _DarkPalette.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final String title;
  final int count;
  final Widget child;
  final bool initiallyExpanded;

  const _ExpandableSection({
    required this.title,
    required this.count,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(6, 0, 6, 12),
        backgroundColor: _DarkPalette.surfaceVariant.withOpacity(.5),
        collapsedBackgroundColor: _DarkPalette.surfaceVariant.withOpacity(.7),
        iconColor: _DarkPalette.textSecondary,
        collapsedIconColor: _DarkPalette.textSecondary,
        textColor: _DarkPalette.textPrimary,
        collapsedTextColor: _DarkPalette.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _DarkPalette.border),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _DarkPalette.border),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _DarkPalette.textPrimary,
                  letterSpacing: .4,
                ),
              ),
            ),
            _CountBadge(count: count),
          ],
        ),
        children: [child],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _DarkPalette.primary.withOpacity(.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _DarkPalette.border),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.robotoMono(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _DarkPalette.textPrimary,
        ),
      ),
    );
  }
}

class _DarkPalette {
  static const background = Color(0xFF0F1115);
  static const surface = Color(0xFF1B1E23);
  static const surfaceVariant = Color(0xFF262A34);
  static const primary = Color(0xFF8B5CF6); // púrpura
  static const secondary = Color(0xFF22D3EE); // cian
  static const textPrimary = Color.fromARGB(255, 255, 255, 255);
  static const textSecondary = Color(0xFFB9C0CC);
  static const border = Color(0x22FFFFFF);
  static const divider = Color(0x1FFFFFFF);
}
