

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:fabrics_app/Components/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fabrics_app/Components/custom_appbar_scan.dart';
import 'package:fabrics_app/Components/default_button.dart';
import 'package:fabrics_app/Components/loader_component.dart';
import 'package:fabrics_app/Components/scan_bar_code.dart';
import 'package:fabrics_app/Components/text_derecha.dart';
import 'package:fabrics_app/Components/text_encabezado.dart';
import 'package:fabrics_app/Helpers/api_helper.dart';
import 'package:fabrics_app/Models/detalle.dart';
import 'package:fabrics_app/Models/order.dart';
import 'package:fabrics_app/Models/response.dart';
import 'package:fabrics_app/Models/roll.dart';
import 'package:fabrics_app/Models/user.dart';
import 'package:fabrics_app/Screens/edit_order_screem.dart';
import 'package:fabrics_app/Screens/order_new.dart';
import 'package:fabrics_app/constans.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key, required this.orden, required this.user, required this.ruta, });
  final String ruta;
  final Order orden;
  final User user;
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  String? scanResult;
  bool showLoader=false;
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      
      child: Scaffold(
        backgroundColor: kContrastColor,
        appBar: PreferredSize(
              preferredSize: Size.fromHeight(AppBar().preferredSize.height),
              child:  CustomAppBarScan(              
                press: () => goBack(),
                 titulo:  Text('Agregue un Producto.', style: GoogleFonts.oswald(fontStyle: FontStyle.normal, fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                 image: const AssetImage('assets/ImgAddPro.png'),
              ),
            ),
        body:  Stack(
          children: [
            Container(
              color: kContrastColor,
              child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children:  [ 
                     ScanBarCode(press: scanBarCode,),      
                    Container(                    
                      color: kContrastColorMedium,
                      child: _showCodigo()),     
                   Container(height: 15, color: kContrastColor,),
                  rollAux.cantidad != null ?  _showInfo() : Container(),
                   _showCantidad(),
                  _showPrecio(),
                  const SizedBox(height: 20,),
             
                      DefaultButton(text: 'Agregar', press: _addProduct),  
                      const SizedBox(height: 20,),
                
                     
                  ],
                  ),
                 ),
              ),
            ),
            showLoader ? const LoaderComponent(text: 'Cargando') : Container(),
          ],
        ),
        )
    );
  }

  void  _addProduct() async  {
   FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
   
    var  pId = rollAux.product?.id;
    if(pId==null){
       await Fluttertoast.showToast(
          msg: "Seleccione un Producto",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );     
      return;
    }

    if (!_validateFields()) {
      return;

    }
    Detalle detailAux =  Detalle(); 
    detailAux.producto=rollAux.product!.descripcion;
    detailAux.cantidad=double.parse(cantidadController.text);
    detailAux.price=double.parse(precioController.text);
    detailAux.codigoRollo=rollAux.id??0;
    detailAux.codigoProducto=rollAux.product!.id??0;
    detailAux.color=rollAux.product!.color!;
    double var2 =detailAux.cantidad ?? 0;

    
     double var3 =detailAux.price ?? 0;
     detailAux.total=var3*var2;

     if(var2 > var3){
      await Fluttertoast.showToast(
          msg: "Por favor revise los valores\nCantidad y Precio.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );     
       
      return;
     }
     
     setState(() {
       widget.orden.detalles.insert(0, detailAux);
     });

      if(widget.ruta=="Edit")
      {
          Navigator.of(context).pushReplacement(            
            MaterialPageRoute(
              builder: (context) => EditOrderScreen(orden: widget.orden, user: widget.user, isOld: true,)
            )
          );
      }
      else
      {
          Navigator.of(context).pushReplacement(  
            MaterialPageRoute(
              builder: (context) => OrderNewScreen(orden: widget.orden, user: widget.user, isOld: false,)
            )
          );
      }

       

  }

 Widget _showPrecio() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
    child: Row(
      children: [
        // Botón de decremento (-)
        GestureDetector(
          onTap: () {
            setState(() {
              double currentPrecio = double.tryParse(precioController.text) ?? 0.0;
              currentPrecio = (currentPrecio - 50).clamp(0.0, double.infinity);
              precioController.text = currentPrecio.toStringAsFixed(0);
            });
          },
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.remove,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // TextField para el precio
        Expanded(
          child: TextField(
            controller: precioController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white, // Cambia según tu esquema de colores
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              hintText: 'Ingresa el precio...',
              labelText: 'Precio',
              errorText: precioShowError ? precioError : null,
              isDense: true, // Reduce el tamaño vertical
              suffixIcon: null, // Eliminamos el suffixIcon original
            ),
            onChanged: (value) {
              setState(() {
                // Actualiza el precio cuando el usuario edita el TextField
                double newPrecio = double.tryParse(value) ?? 0.0;
                precioController.text = newPrecio.toStringAsFixed(0);
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        // Botón de incremento (+)
        GestureDetector(
          onTap: () {
            setState(() {
              double currentPrecio = double.tryParse(precioController.text) ?? 0.0;
              currentPrecio += 50;
              precioController.text = currentPrecio.toStringAsFixed(0);
            });
          },
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _showCodigo() {
    return Container(
      color: kContrastColor,
      padding: const EdgeInsets.only(left: 50.0, right: 50, top:20),      
      child: TextField(
        controller: codigoController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(          
          filled: true,
          hoverColor: const Color.fromARGB(255, 19, 47, 70),
          border:   const OutlineInputBorder(borderSide: BorderSide(color: kPrimaryColor, width: 5)),
          hintText: 'Ingresa el codigo...',
          labelText: 'Codigo',
          errorText: codigoShowError ? codigoError : null,
          suffixIcon: IconButton(
            iconSize: 40,
             onPressed: goGetProduct,
              icon: const Icon(
                Icons.search_sharp, 
                color: Color(0xffc94216)),)
         
        ),
    
      ),
    );
  }

 Widget _showCantidad() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 10),
    child: Row(
      children: [
        // Botón de decremento (-)
        GestureDetector(
          onTap: () {
            setState(() { 

             double newCantidad = cantidad - 0.5;
             if(newCantidad> 0){
                  cantidadController.text = newCantidad.toStringAsFixed(1);
                  cantidad=newCantidad;
             }
            
            });
          },
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red, // Color rojo para el botón de decremento
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.remove,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // TextField para la cantidad
        Expanded(
          child: TextField(
            controller: cantidadController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white, // Fondo blanco para el TextField
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: kPrimaryColor, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              hintText: 'Ingresa la Cantidad...',
              labelText: 'Cantidad',
              errorText: cantidadShowError ? cantidadError : null,
              isDense: true, // Reduce el tamaño vertical del TextField
              suffixIcon: null, // Eliminamos el suffixIcon original
            ),
            onChanged: (value) {
               setState(() {
                // Actualiza el precio cuando el usuario edita el TextField
               _validateCantidad(value);
               
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        // Botón de incremento (+)
        GestureDetector(
          onTap: () {
            setState(() {
              double currentCantidad = double.tryParse(cantidadController.text) ?? 0.0;
              currentCantidad += 0.5;
              cantidadController.text = currentCantidad.toStringAsFixed(1);
              cantidad=currentCantidad;
            });
          },
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue, // Color azul para el botón de incremento
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
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
        showLoader=true;
    });
    Response response = await ApiHelper.getRoll(codigo);
    setState(() {
        showLoader=false;
    });

    if (!response.isSuccess) {
      await Fluttertoast.showToast(
          msg: "El rollo no existe",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );     
      return;
    }    
   
    setState(() {
      rollAux= response.result;
      cantidadController.text=1.toString();
      cantidad=1;
      precioController.text=  rollAux.product!.venta.toString().substring(0,rollAux.product!.venta.toString().length-3);
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
    
    if(cantidad == 0){
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
    
    if(double.tryParse(precioController.text) == null){
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
    
    if(int.tryParse(codigoController.text) == null){
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
      showLoader=true;
    });  
    String code1 = cod.substring(1,9);
    int code = int.parse(code1);
    Response response = await ApiHelper.getRoll(code);

    setState(() {
        showLoader=false;
    });
  
      if (!response.isSuccess) {
    showErrorFromDialog(response.message);
      return;
    }   

      rollAux= response.result;

      String normalized = rollAux.product!.venta!.replaceAll('.', '').replaceAll(',', '.');


    double parseDouble = double.parse(normalized);
    int parsedInt = parseDouble.toInt();

    setState(() {
      showLoader=false;    
      codigoController.text=rollAux.id.toString();
      precioController.text=parsedInt.toString();
      cantidad=1;
      cantidadController.text=1.toString();
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
  
  Widget _showInfo() {     
     return Container( 
      decoration:  const
      BoxDecoration(             
        color: kContrastColorMedium,             
      ),
        child: Padding(
          padding:  const EdgeInsets.only(left: 50.0, right: 50, top:10, bottom: 10),  
          child: Card(
                color:kContrastColor,
                shadowColor: kPrimaryColor,
                elevation: 8,
            child: Padding(
              padding:  const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,                     
                children: [
                  Row(
                    children: [
                      const TextEncabezado(texto: 'Producto: '),
                      TextDerecha(texto: rollAux.product!.descripcion!),
                    ],
                  ),
                    Row(
                    children: [
                      const TextEncabezado(texto: 'Color: '),
                      TextDerecha(texto: rollAux.product!.color!),
                    ],
                  ),
                    Row(
                    children: [
                      const TextEncabezado(texto: 'Stock: '),
                      TextDerecha(texto: rollAux.product!.stock!.toString()),
                    ],
                  ),
                ]),
            ),
          ),
        ),
    );
  }
  
  goBack() async {
    if(widget.ruta=="Edit"){
      Navigator.of(context).pushReplacement(  
      MaterialPageRoute(
        builder: (context) => EditOrderScreen(user: widget.user, orden: widget.orden,isOld: false,)
    ));  
    }
    else{
       Navigator.of(context).pushReplacement(  
       MaterialPageRoute(
        builder: (context) => OrderNewScreen(user: widget.user, orden: widget.orden, isOld: false,)
    ));  
    }
    
  }

 void showErrorFromDialog(String msg) async {
    await showAlertDialog(
        context: context,
        title: 'Error', 
        message: msg,
        actions: <AlertDialogAction>[
            const AlertDialogAction(key: null, label: 'Aceptar'),
        ]
      );       
  }

}