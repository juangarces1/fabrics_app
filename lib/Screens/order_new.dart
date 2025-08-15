import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fabrics_app/Components/custom_appbar_scan.dart';
import 'package:fabrics_app/Components/text_derecha.dart';
import 'package:fabrics_app/Components/text_encabezado.dart';
import 'package:fabrics_app/Helpers/api_helper.dart';
import 'package:fabrics_app/Models/detalle.dart';
import 'package:fabrics_app/Models/order.dart';
import 'package:fabrics_app/Models/response.dart';
import 'package:fabrics_app/Models/user.dart';
import 'package:fabrics_app/Screens/add_product_old.dart';
import 'package:fabrics_app/Screens/add_product_screen.dart';
import 'package:fabrics_app/Screens/home_screen.dart';
import 'package:fabrics_app/constans.dart';
import 'package:fabrics_app/sizeconfig.dart';

class OrderNewScreen extends StatefulWidget {
  const OrderNewScreen({super.key, required this.orden, required this.user, required this.isOld });
  final Order orden;
  final User user;
  final bool isOld;
  @override
  State<OrderNewScreen> createState() => _OrderNewScreenState();
}

class _OrderNewScreenState extends State<OrderNewScreen> {
  List<Detalle> detalles = [];
  bool showLoader = false;
  final String _precio='';
  final String _cantidad='';
   
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(      
        appBar:  PreferredSize(
              preferredSize: const Size.fromHeight(65),
              child:  CustomAppBarScan(              
                press: () => goMenu(),
                 titulo:  Text(widget.isOld ? 'Nueva Orden' : 'Nuevo Pedido',
                  style:  GoogleFonts.oswald(fontStyle: FontStyle.normal, fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  image: const AssetImage("assets/AppBar.png"),
              ),
            ),
        body:  Center(
          child:  _getContent(),),
           bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              gradient: kGradientHome,
            ),
            height: 80,
             child: Row(
               mainAxisSize: MainAxisSize.max,
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  RawMaterialButton(
                     onPressed: _goAdd,
                     elevation: 2.0,
                     fillColor: const Color.fromARGB(255, 184, 13, 118),
                     padding: const EdgeInsets.all(8.0),
                     shape: const CircleBorder(),
                     child: const Icon(
                       Icons.add,
                       size: 35.0,
                       color: Colors.white,
                     ),
                   ),
                Text(widget.orden.detalles.isNotEmpty ? 'Prod: ${widget.orden.detalles.length.toString()} -  \$${NumberFormat("###,000", "es_CO").format(widget.orden.detalles.map((item)=>item.total!).reduce((value, element) => value + element))}' : '', style:  GoogleFonts.oswald(fontStyle: FontStyle.normal, fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),),
                 Padding(
                   padding: const EdgeInsets.only(top: 3, bottom: 3),
                   child: RawMaterialButton(
                      onPressed: goSave,
                      elevation: 2.0,
                      fillColor: Colors.white,
                      padding: const EdgeInsets.all(8.0),
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.save,
                        size: 35.0,
                        color: kBlueColorLogo,
                      ),
                    ),
                 ),
                 ],          
               ),
           ),  
      ),
    );
  }

  void  goSave()  async {
      if(widget.orden.detalles.isEmpty){
       await  Fluttertoast.showToast(
          msg: 'No hay productos para guardar',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 211, 16, 25),
          textColor: Colors.white,
          fontSize: 16.0
      );     
      return;
    }    
     setState(() {
      showLoader = true;
    });    
  
   widget.orden.documentUser=widget.user.document;
   widget.orden.id=0;

   

   Map<String, dynamic> request = widget.orden.toJson();
   

   Response response = Response(isSuccess: false);
    if(widget.isOld){
       response = await ApiHelper.post(
      'api/Kilos/PostOrderOld/', 
       request,       
     );
    }
    else{
       response = await ApiHelper.post(
      'api/Kilos/PostOrder/', 
       request,       
      );
    }
 

    setState(() {
      showLoader = false;
    });

    if (!response.isSuccess) {
     showErrorFromDialog(response.message);
      return;
    }   

    setState(() {
      widget.orden.detalles.clear();       
    });

    
      
   

      await  Fluttertoast.showToast(
          msg: 'Orden Guardada Correcatemente',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 14, 131, 29),
          textColor: Colors.white,
          fontSize: 16.0
      );     
      return;
  }

  Widget _getContent() {
    return widget.orden.detalles.isEmpty 
      ? _noContent()
      : _getList();
  }
  
  void _goAdd() {
    if(widget.isOld==false){
      Navigator.of(context).pushReplacement(  
      MaterialPageRoute(
        builder: (context) => AddProductScreen(user: widget.user,      
          orden: widget.orden,
          ruta: "New",
          )
        )
      );
    }
    else{
      Navigator.of(context).pushReplacement(  
      MaterialPageRoute(
        builder: (context) => AddOldProduct(user: widget.user,      
          orden: widget.orden,
          ruta: "Old",
        )
      ));
    }
  }
 
  _noContent() {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:  [
          SizedBox(
           
            height: 400,
            width: 400,
            child: Image(image: AssetImage('assets/cart_empty.png'))),
        
          Text(
            'Agregue algun producto al Carrito.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
          ),
        ],
      );
  }

  _getList() {
    return Container(
        color: kContrastColor,
        child: Padding(
        padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10), vertical: getProportionateScreenHeight(10)),
        child: ListView.builder(          
          itemCount: widget.orden.detalles.length,
          itemBuilder: (context, index)  
          { 
            final item = widget.orden.detalles[index].codigoRollo.toString();
            return 
            Card(
              color: Colors.white,
               shadowColor: Colors.blueGrey,
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding              (
                padding: const EdgeInsets.symmetric(vertical: 0),
                child: Dismissible(            
                  key: Key(item),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) {
                    return showDialog(
                      context: context,
                       builder: (_) =>  AlertDialog(
                        title: const Text('Eliminar'),
                        content: const Text('Desea eliminar el Producto?'),
                        actions: [
                          TextButton(onPressed: () {
                             Navigator.of(context).pop(false);
                          }, child: const Text('No')),
                            TextButton(onPressed: (){
                               Navigator.of(context).pop(true);
                            },
                           child: const Text('Sí')),
                        ],    
                       ));
                  },
                  onDismissed: (direction) { 
                        
                      setState(() {
                            widget.orden.detalles.removeAt(index); 
                      });          
                  },
                  background: Container(              
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 231, 216, 216),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        SvgPicture.asset("assets/Trash.svg"),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 88,
                        child: AspectRatio(
                          aspectRatio: 0.88,
                          child: Container(
                            padding: EdgeInsets.all(getProportionateScreenWidth(5)),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                               borderRadius: BorderRadius.only(topLeft: Radius.circular(15) , bottomLeft: Radius.circular(15))
                            ),
                            child:  const Image(image: AssetImage('assets/rollostela.png')),
                                    
                          ),
                        ),
                      ),                         
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          TextEncabezado(texto: widget.orden.detalles[index].producto.toString()),
                          TextEncabezado(texto: widget.orden.detalles[index].color.toString()),
                             Row(children: [
                              const TextEncabezado(texto:'Cantidad: '),
                            
                               TextDerecha(texto: widget.orden.detalles[index].cantidad.toString()),
                            ],),
                             Row(children: [
                              const TextEncabezado(texto:'Precio: '),
                           
                               TextDerecha(texto: NumberFormat("###,000", "es_CO").format(widget.orden.detalles[index].price)),
                            ],),
                             Row(children: [
                              const TextEncabezado(texto:'Total: '),
                            
                               TextDerecha(texto: NumberFormat("###,000", "es_CO").format(widget.orden.detalles[index].total)),
                            ],),             
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 3, bottom: 3),
                        child: RawMaterialButton(
                          onPressed: () => _showFilter(widget.orden.detalles[index]),
                          elevation: 2.0,
                          fillColor: const Color.fromARGB(255, 228, 198, 67),
                          padding: const EdgeInsets.all(12.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.edit,
                            size: 25.0,
                          ),
                        ),
                      ),                      
                    ],
                  ), 
                ),
              ),
            );
          }        
        ),
        ),
      );
  }
  
  void goMenu() async {
   
  if(widget.orden.detalles.isEmpty){
    Navigator.of(context).pushReplacement( 
      MaterialPageRoute(
        builder: (context) => HomeScreen(user: widget.user,)
      ));       
    }
        
  }

 Future<void> _showFilter(Detalle detalle) => showDialog(
  context: context,
  builder: (context) {
    // Inicializar las variables con los valores actuales de detalle
    double cantidad = detalle.cantidad ?? 0.0;
    double precio = detalle.price ?? 0.0;

    // Controladores para los TextFields
    TextEditingController cantidadController = TextEditingController(text: cantidad.toString());
    TextEditingController precioController = TextEditingController(text: precio.toString());

    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Text('${detalle.producto} ${detalle.color}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Divider(color: Colors.black, height: 11,),

              // Campo para Cantidad con botones de decremento y incremento
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    // Botón de decremento (-)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          cantidad = (cantidad - 0.5).clamp(0.0, double.infinity);
                          cantidadController.text = cantidad.toStringAsFixed(1);
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // TextField reducido
                    Expanded(
                      child: TextField(
                        controller: cantidadController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Cantidad',
                          suffixIcon: Icon(Icons.numbers),
                          isDense: true, // Reduce el tamaño vertical
                        ),
                        onChanged: (value) {
                          cantidad = double.tryParse(value) ?? 0.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Botón de incremento (+)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          cantidad += 0.5;
                          cantidadController.text = cantidad.toStringAsFixed(1);
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Campo para Precio con botones de decremento y incremento
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    // Botón de decremento (-)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          precio = (precio - 50).clamp(0.0, double.infinity);
                          precioController.text = precio.toStringAsFixed(0);
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // TextField reducido
                    Expanded(
                      child: TextField(
                        controller: precioController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Precio',
                          suffixIcon: Icon(Icons.money),
                          isDense: true, // Reduce el tamaño vertical
                        ),
                        onChanged: (value) {
                          precio = double.tryParse(value) ?? 0.0;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Botón de incremento (+)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          precio += 50;
                          precioController.text = precio.toStringAsFixed(0);
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10,),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Actualizar los valores en el objeto detalle
              detalle.cantidad = cantidad;
              detalle.price = precio;
              _editar(detalle);
              Navigator.of(context).pop();
            }, 
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  },
);


    _editar(Detalle detalle) {
        setState(() {
         for (var item in widget.orden.detalles){
          if(item.codigoRollo==detalle.codigoRollo){
            if(_precio != ''){
                 item.price = double.parse(_precio);
            }
             if(_cantidad != ''){
                 item.cantidad = double.parse(_cantidad);
            }
             item.total= item.price! * item.cantidad!;
          }
        }
        });
        
       
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