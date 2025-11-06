import 'package:flutter/foundation.dart';

@immutable
class Item {
  final String id;       // ex: 'key_blue'
  final String type;     // ex: 'key'
  final int quantity;

  const Item({required this.id, required this.type, this.quantity = 1});

  Item copyWith({int? quantity}) =>
      Item(id: id, type: type, quantity: quantity ?? this.quantity);
}

/// Petit inventaire + notifications UI
class Inventory extends ChangeNotifier {
  final Map<String, Item> _items = {};

  void add(Item item) {
    final existing = _items[item.id];
    if (existing == null) {
      _items[item.id] = item;
    } else {
      _items[item.id] =
          existing.copyWith(quantity: existing.quantity + item.quantity);
    }
    notifyListeners();
  }

  bool has(String id, {int atLeast = 1}) {
    final it = _items[id];
    return it != null && it.quantity >= atLeast;
  }

  bool consume(String id, {int quantity = 1}) {
    final it = _items[id];
    if (it == null || it.quantity < quantity) return false;
    final left = it.quantity - quantity;
    if (left <= 0) {
      _items.remove(id);
    } else {
      _items[id] = it.copyWith(quantity: left);
    }
    notifyListeners();
    return true;
  }

  List<Item> get items => List.unmodifiable(_items.values);
}
