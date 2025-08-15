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
import 'package:fabrics_app/Models/descuento.dart';
import 'package:fabrics_app/Models/product.dart';
import 'package:fabrics_app/Models/response.dart';
import 'package:fabrics_app/Models/user.dart';
import 'package:fabrics_app/Screens/home_screen.dart';
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
            decoration: const BoxDecoration(
              gradient: kGradientHome,
            ),
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
                      color: const Color.fromARGB(255, 70, 65, 65).withOpacity(0.5),
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
                  const SizedBox(width: 35), // Para ocupar el espacio a la derecha
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
                      unselectedLabelColor:const Color.fromARGB(255, 110, 108, 108),
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
                      _buildDetailsTab(),
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
          ScanBarCode(
            press: scanBarCode,
          ),
          // Código Rollo
          Container(
            color: kColorAlternativo,
            child: _showCodigo(),
          ),
          // Código Producto
          Container(
            color: kColorAlternativo,
            child: _showCodigoProducto(),
          ),
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
    );
  }

  // ======================== PESTAÑA DE DETALLES ========================
  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Solo muestra info si hay un producto cargado
          product.descripcion != null ? _showInfo() : Container(),
          product.rolls != null ? _showListRolls() : Container(),
          movs.isNotEmpty ? _showListMovs() : Container(),
        ],
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

    String code1 = cides.substring(1, 9);
    int code = int.parse(code1);
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

  // ======================== DETALLES DEL PRODUCTO ========================
  Widget _showInfo() {
    return Container(
      decoration: const BoxDecoration(
        color: kContrastColorMedium,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, right: 20, top: 10, bottom: 10),
        child: Card(
          color: Colors.white70,
          shadowColor: kPrimaryColor,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const TextEncabezado(texto: 'Producto: '),
                  TextDerecha(texto: product.descripcion!),
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const TextEncabezado(texto: 'Color: '),
                  TextDerecha(texto: product.color!),
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextEncabezado(texto: 'Stock: '),
                    TextDerecha(texto: product.stock.toString()),
                    const SizedBox(width: 10),
                    const TextEncabezado(texto: 'Stock Bodega: '),
                    TextDerecha(texto: product.stockEnBodega.toString()),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextEncabezado(texto: 'Stock Almacen: '),
                    TextDerecha(texto: product.stockEnAlmacen.toString()),
                    const SizedBox(width: 10),
                    const TextEncabezado(texto: 'Unidad: '),
                    TextDerecha(texto: product.medida!),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const TextEncabezado(texto: 'Rollos: '),
                  TextDerecha(texto: product.rolls!.length.toString()),
                  const SizedBox(width: 10),
                  const TextEncabezado(texto: 'Ultima Entrada: '),
                  TextDerecha(texto: product.ultimaEntrada!),
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const TextEncabezado(texto: 'Total Entradas: '),
                  TextDerecha(texto: product.totalEntradas.toString()),
                  const SizedBox(width: 10),
                  const TextEncabezado(texto: 'Total Salidas: '),
                  TextDerecha(texto: product.totalSalidas.toString()),
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const TextEncabezado(texto: 'Prom Compra: '),
                  TextDerecha(
                    texto: NumberFormat("##.0#", "en_US").format(product.precioPromedio),
                  ),
                  const SizedBox(width: 10),
                  const TextEncabezado(texto: 'Ult Compra: '),
                  TextDerecha(
                    texto: NumberFormat("##.0#", "en_US").format(product.ultimoPrecio),
                  ),
                ]),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const TextEncabezado(texto: ' Prom Venta: '),
                  TextDerecha(texto: product.promVenta!),
                  const SizedBox(width: 10),
                  const TextEncabezado(texto: 'Ult Venta: '),
                  TextDerecha(texto: product.ultimaVenta!),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _showListRolls() {
    return Container(
      color: kColorAlternativo,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
            child: Center(
              child: Text(
                'Rollos',
                style: GoogleFonts.oswald(
                  fontStyle: FontStyle.normal,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const Divider(height: 10, thickness: 2, color: kContrastColor),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...List.generate(
                  product.rolls!.length,
                  (index) {
                    return CardRoll(roll: product.rolls![index]);
                  },
                ),
                SizedBox(width: getProportionateScreenWidth(20)),
              ],
            ),
          ),
          const Divider(height: 10, thickness: 2, color: kContrastColor),
        ],
      ),
    );
  }

  Widget _showListMovs() {
    return Column(
      children: [
        Container(
          color: kColorAlternativo,
          child: Center(
            child: Text(
              'Movimientos',
              style: GoogleFonts.oswald(
                fontStyle: FontStyle.normal,
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container(
          height: 150,
          color: kColorAlternativo,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ListWheelScrollView.useDelegate(
              perspective: 0.005,
              itemExtent: 80,
              physics: const FixedExtentScrollPhysics(),
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  return CardMovimiento(descuento: movs[index]);
                },
                childCount: movs.length,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ======================== NAVEGAR HACIA ATRÁS ========================
  void goBack() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(user: widget.user),
      ),
    );
  }
}
