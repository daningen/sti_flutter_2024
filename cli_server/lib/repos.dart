part 'repo_impls.dart';

class Item {
  final String description;
  Item(this.description);

  Map<String, dynamic> toJson() => {'description': description};

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(json['description']);
  }
}

abstract class Repository<T> {
  final List<T> _items = [];

  void add(T item) {
    _items.add(item);
  }

  List<T> getAll() {
    return _items;
  }

  void update(T item, T newItem) {
    var index = _items.indexWhere((element) => element == item);
    _items[index] = newItem;
  }

  void delete(T item) {
    _items.remove(item);
  }
}
