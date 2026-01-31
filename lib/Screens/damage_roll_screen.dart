import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fabrics_app/Components/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fabrics_app/Components/custom_appbar_scan.dart';
import 'package:fabrics_app/Components/loader_component.dart';
import 'package:fabrics_app/Helpers/api_helper.dart';
import 'package:fabrics_app/Helpers/scanner_helper.dart';
import 'package:fabrics_app/Models/response.dart';
import 'package:fabrics_app/Models/roll.dart';
import 'package:fabrics_app/Models/user.dart';
import 'package:fabrics_app/constans.dart';

class DamageRollScreen extends StatefulWidget {
  const DamageRollScreen({super.key, required this.user});
  final User user;

  @override
  State<DamageRollScreen> createState() => _DamageRollScreenState();
}

class _DamageRollScreenState extends State<DamageRollScreen> {
  bool showLoader = false;
  TextEditingController codigoController = TextEditingController();
  String codigoError = '';
  bool codigoShowError = false;
  TextEditingController cantidadDanadaController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  Roll rollAux = Roll();
  bool isProductFound = false;
  int selectedDamageType = 0; // 0=Mancha por defecto

  final List<Map<String, dynamic>> damageTypes = [
    {'id': 0, 'name': 'Mancha', 'icon': Icons.water_drop, 'color': Colors.brown},
    {'id': 1, 'name': 'Agua', 'icon': Icons.opacity, 'color': Colors.blue},
    {'id': 2, 'name': 'Corte', 'icon': Icons.content_cut, 'color': Colors.orange},
    {'id': 3, 'name': 'Rotura', 'icon': Icons.broken_image, 'color': Colors.red},
    {'id': 4, 'name': 'Desperdicio', 'icon': Icons.delete_outline, 'color': Colors.grey},
    {'id': 5, 'name': 'Otro', 'icon': Icons.more_horiz, 'color': Colors.purple},
  ];

  double get cantidadDanada =>
      double.tryParse(cantidadDanadaController.text) ?? 0;

  double get stockRestante => (rollAux.inventario ?? 0) - cantidadDanada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBarScan(
        press: () => goBack(),
        titulo: Text(
          isProductFound ? 'Registrar Daño' : 'Buscar Rollo',
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [kPrimaryColor.withValues(alpha: 0.05), Colors.white],
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!isProductFound) ...[
                  _buildScanSection(),
                  const SizedBox(height: 25),
                  _buildSeparator(),
                  const SizedBox(height: 25),
                  _buildManualSearchLabel(),
                  _buildSearchField(),
                ],
                if (isProductFound) ...[
                  _buildRollInfoCard(),
                  const SizedBox(height: 12),
                  _buildChangeRollLink(),
                  const SizedBox(height: 20),
                  _buildInventarioActual(),
                  const SizedBox(height: 20),
                  _buildDamageTypeSelector(),
                  const SizedBox(height: 20),
                  _buildCantidadDanadaInput(),
                  const SizedBox(height: 20),
                  _buildStockRestanteCard(),
                  const SizedBox(height: 20),
                  _buildDescripcionInput(),
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
              "ESCANEAR CODIGO",
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

  Widget _buildSeparator() {
    return Row(
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
    );
  }

  Widget _buildManualSearchLabel() {
    return Padding(
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
            "BUSQUEDA MANUAL",
            style: GoogleFonts.oswald(
              fontSize: 14,
              letterSpacing: 1,
              color: Colors.black45,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
          hintText: 'Ingresa el codigo del rollo...',
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

  Widget _buildRollInfoCard() {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            rollAux.product?.descripcion ?? "Rollo encontrado",
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Rollo #${rollAux.id}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
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
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.straighten,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                rollAux.medida ?? "-",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
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

  Widget _buildChangeRollLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () {
          setState(() {
            isProductFound = false;
            rollAux = Roll();
            codigoController.clear();
            cantidadDanadaController.clear();
            descripcionController.clear();
            selectedDamageType = 0;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.refresh_rounded, size: 16, color: kPrimaryColor),
              const SizedBox(width: 4),
              Text(
                "Cambiar rollo",
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
    );
  }

  Widget _buildInventarioActual() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2, color: Colors.blue[700], size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INVENTARIO ACTUAL',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[400],
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${rollAux.inventario?.toStringAsFixed(2) ?? "0.00"} ${rollAux.medida ?? ""}',
                  style: GoogleFonts.oswald(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamageTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.category_outlined,
              size: 16,
              color: kPrimaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              'TIPO DE DAÑO',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: damageTypes.length,
          itemBuilder: (context, index) {
            final type = damageTypes[index];
            final isSelected = selectedDamageType == type['id'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDamageType = type['id'];
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (type['color'] as Color).withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (type['color'] as Color)
                        : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type['icon'] as IconData,
                      color: isSelected
                          ? (type['color'] as Color)
                          : Colors.grey[600],
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      type['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? (type['color'] as Color)
                            : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCantidadDanadaInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 16,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              'CANTIDAD DAÑADA',
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
              () => _adjustValue(-0.5),
              Colors.grey[100]!,
              Colors.black54,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: TextField(
                controller: cantidadDanadaController,
                textAlign: TextAlign.center,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.oswald(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  hintText: '0.00',
                  hintStyle: GoogleFonts.oswald(
                    fontSize: 28,
                    color: Colors.grey[300],
                  ),
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
                    borderSide: BorderSide(
                      color: Colors.red[400]!,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            _circularButton(
              Icons.add,
              () => _adjustValue(0.5),
              Colors.red[50]!,
              Colors.red[700]!,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockRestanteCard() {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;

    if (cantidadDanada == 0) {
      bgColor = Colors.grey[100]!;
      textColor = Colors.grey[700]!;
      icon = Icons.info_outline;
      label = 'SIN CAMBIOS';
    } else if (stockRestante < 0) {
      bgColor = Colors.red[50]!;
      textColor = Colors.red[700]!;
      icon = Icons.error_outline;
      label = 'CANTIDAD INVÁLIDA';
    } else if (stockRestante == 0) {
      bgColor = Colors.orange[50]!;
      textColor = Colors.orange[700]!;
      icon = Icons.inventory_2;
      label = 'ROLLO AGOTADO';
    } else {
      bgColor = Colors.green[50]!;
      textColor = Colors.green[700]!;
      icon = Icons.check_circle_outline;
      label = 'STOCK RESTANTE';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: textColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.7),
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  stockRestante < 0
                      ? 'Excede inventario'
                      : '${stockRestante.toStringAsFixed(2)} ${rollAux.medida ?? ""}',
                  style: GoogleFonts.oswald(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescripcionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notes,
              size: 16,
              color: kPrimaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Text(
              'DESCRIPCIÓN DEL DAÑO',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descripcionController,
          maxLines: 3,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Ej: Mancha de humedad en la parte superior del rollo...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[400],
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
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
              borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final damageTypeName =
        damageTypes.firstWhere((t) => t['id'] == selectedDamageType)['name'];
    final canSave = cantidadDanada > 0 && stockRestante >= 0;

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
                      damageTypeName.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${cantidadDanada.toStringAsFixed(2)} ${rollAux.medida ?? ""}',
                      style: GoogleFonts.oswald(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: canSave ? _saveDamage : null,
                icon: const Icon(Icons.save, size: 20),
                label: Text(
                  'REGISTRAR',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canSave ? Colors.red[600] : Colors.grey[400],
                  foregroundColor: Colors.white,
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

  Widget _circularButton(
    IconData icon,
    VoidCallback onTap,
    Color bgColor,
    Color iconColor,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, size: 24, color: iconColor),
      ),
    );
  }

  void _adjustValue(double delta) {
    setState(() {
      double current = double.tryParse(cantidadDanadaController.text) ?? 0.0;
      current = (current + delta).clamp(0.0, rollAux.inventario ?? 0.0);
      cantidadDanadaController.text = current.toStringAsFixed(2);
    });
  }

  void _saveDamage() async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    if (cantidadDanadaController.text.isEmpty || cantidadDanada <= 0) {
      await Fluttertoast.showToast(
        msg: "Ingresa la cantidad dañada",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    if (cantidadDanada > (rollAux.inventario ?? 0)) {
      await Fluttertoast.showToast(
        msg: "La cantidad dañada no puede ser mayor al inventario",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      showLoader = true;
    });

    Response response = await ApiHelper.registerDamage(
      rollId: rollAux.id!,
      employeeId: widget.user.id!,
      cantidadDanada: cantidadDanada,
      tipoDano: selectedDamageType,
      descripcion: descripcionController.text,
    );

    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
      showErrorFromDialog(response.message ?? 'Error al registrar daño');
      return;
    }

    final damageTypeName =
        damageTypes.firstWhere((t) => t['id'] == selectedDamageType)['name'];

    await Fluttertoast.showToast(
      msg:
          'Daño registrado: $damageTypeName\nCantidad: ${cantidadDanada.toStringAsFixed(2)}\nStock restante: ${stockRestante.toStringAsFixed(2)}',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    setState(() {
      isProductFound = false;
      rollAux = Roll();
      codigoController.clear();
      cantidadDanadaController.clear();
      descripcionController.clear();
      selectedDamageType = 0;
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
    int code = int.parse(codigoController.text);
    _getRollCodigo(code);
  }

  Future<void> _getRollCodigo(int codigo) async {
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
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    setState(() {
      rollAux = response.result;
      isProductFound = true;
      cantidadDanadaController.text = '0.00';
    });
  }

  bool _validateCodigo() {
    bool isValid = true;

    if (codigoController.text.isEmpty) {
      isValid = false;
      codigoShowError = true;
      codigoError = 'Debes ingresar el codigo.';
    } else {
      codigoShowError = false;
    }

    if (int.tryParse(codigoController.text) == null) {
      isValid = false;
      codigoShowError = true;
      codigoError = 'Debes ingresar un numero valido.';
    } else {
      codigoShowError = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> scanBarCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanScreen()),
    );

    if (result != null && result is String && mounted) {
      await _getRoll(result);
    } else {
      showErrorFromDialog('No se obtuvo un codigo valido del escaner.');
    }
  }

  Future<void> _getRoll(String cod) async {
    try {
      if (!mounted) return;

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
        showErrorFromDialog(response.message ?? 'Rollo no encontrado');
        return;
      }

      rollAux = response.result;

      setState(() {
        isProductFound = true;
        codigoController.text = rollAux.id.toString();
        cantidadDanadaController.text = '0.00';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          showLoader = false;
        });
        showErrorFromDialog('Ocurrio un error: $e');
      }
    }
  }

  void goBack() {
    if (isProductFound) {
      setState(() {
        isProductFound = false;
        rollAux = Roll();
        codigoController.clear();
        cantidadDanadaController.clear();
        descripcionController.clear();
        selectedDamageType = 0;
      });
      return;
    }
    Navigator.of(context).pop();
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
