class Detalle {
  int? codigoRollo;
  double? price;
  double? cantidad;
  double? total;
  String? producto;
  String? color;
  int? codigoProducto;

  Detalle({
    this.codigoRollo,
    this.price,
    this.cantidad,
    this.total,
    this.producto,
    this.color,
    this.codigoProducto,
  });

  Detalle.fromJson(Map<String, dynamic> json) {
    codigoRollo = json['codigoRollo'] ?? 0;
    // Support both API keys (precio, cant, valor) and local storage keys (price, cantidad, total)
    price = (json['precio'] ?? json['price'])?.toDouble() ?? 0.0;
    cantidad = (json['cant'] ?? json['cantidad'])?.toDouble() ?? 0.0;
    total = (json['valor'] ?? json['total'])?.toDouble() ?? 0.0;
    producto = json['producto'];
    color = json['color'];
    codigoProducto = json['codigoProducto'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['codigoProducto'] = codigoProducto;
    data['codigoRollo'] = codigoRollo;
    data['price'] = price;
    data['cantidad'] = cantidad;
    data['valor'] = total;
    return data;
  }
}
