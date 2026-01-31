import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fabrics_app/Models/detalle.dart';
import 'package:fabrics_app/Models/order.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  final List<Order> _pendingOrders = [];
  int _activeIndex = -1;

  List<Order> get pendingOrders => _pendingOrders;
  int get activeIndex => _activeIndex;

  Order? get activeOrder =>
      _activeIndex != -1 ? _pendingOrders[_activeIndex] : null;

  List<Detalle> get items => activeOrder?.detalles ?? [];

  int get itemCount => items.length;

  double get totalAmount {
    if (items.isEmpty) return 0.0;
    return items
        .map((item) => item.total ?? 0.0)
        .fold(0.0, (previousValue, element) => previousValue + element);
  }

  void createNewOrder() {
    _pendingOrders.add(Order(detalles: []));
    _activeIndex = _pendingOrders.length - 1;
    saveToPrefs();
    notifyListeners();
  }

  void initializeOrder(Order newOrder) {
    // Para rutas como "Editar Orden" buscamos si ya existe por ID o simplemente la activamos
    int existingIndex = _pendingOrders.indexWhere(
      (o) => o.id == newOrder.id && o.id != null,
    );
    if (existingIndex != -1) {
      _activeIndex = existingIndex;
    } else {
      _pendingOrders.add(newOrder);
      _activeIndex = _pendingOrders.length - 1;
    }
    saveToPrefs();
    notifyListeners();
  }

  void switchToOrder(int index) {
    if (index >= 0 && index < _pendingOrders.length) {
      _activeIndex = index;
      notifyListeners();
    }
  }

  void addItem(Detalle item) {
    if (activeOrder == null) createNewOrder();

    int index = activeOrder!.detalles.indexWhere(
      (d) => d.codigoRollo == item.codigoRollo,
    );
    if (index != -1) {
      activeOrder!.detalles[index] = item;
    } else {
      activeOrder!.detalles.add(item);
    }
    saveToPrefs();
    notifyListeners();
  }

  void removeItem(int index) {
    if (activeOrder != null) {
      activeOrder!.detalles.removeAt(index);
      saveToPrefs();
      notifyListeners();
    }
  }

  void updateItem(int index, double cantidad, double precio) {
    if (activeOrder != null) {
      activeOrder!.detalles[index].cantidad = cantidad;
      activeOrder!.detalles[index].price = precio;
      activeOrder!.detalles[index].total = cantidad * precio;
      saveToPrefs();
      notifyListeners();
    }
  }

  void removeActiveOrder() {
    if (_activeIndex != -1) {
      _pendingOrders.removeAt(_activeIndex);
      _activeIndex = _pendingOrders.isEmpty ? -1 : 0;
      saveToPrefs();
      notifyListeners();
    }
  }

  void clearCart() {
    removeActiveOrder();
  }

  void setDocumentUser(String? doc) {
    if (activeOrder != null) {
      activeOrder!.documentUser = doc;
      saveToPrefs();
      notifyListeners();
    }
  }

  void removeOrderAt(int index) {
    if (index >= 0 && index < _pendingOrders.length) {
      _pendingOrders.removeAt(index);
      if (_activeIndex == index) {
        _activeIndex = _pendingOrders.isEmpty ? -1 : 0;
      } else if (_activeIndex > index) {
        _activeIndex--;
      }
      saveToPrefs();
      notifyListeners();
    }
  }

  // Persistencia
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _pendingOrders.map((o) => o.toJson()).toList(),
    );
    await prefs.setString('pending_orders', encodedData);
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? ordersString = prefs.getString('pending_orders');
    if (ordersString != null) {
      final List<dynamic> decodedData = jsonDecode(ordersString);
      _pendingOrders.clear();
      _pendingOrders.addAll(decodedData.map((o) => Order.fromJson(o)).toList());
      if (_pendingOrders.isNotEmpty) {
        _activeIndex = 0;
      }
      notifyListeners();
    }
  }
}
