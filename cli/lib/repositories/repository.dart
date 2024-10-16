abstract class Repository<T> {
  final List<T> _items = [];

  // Asynchronously add an item
  Future<void> add(T item) async {
    _items.add(item);
  }

  // Asynchronously get all items
  Future<List<T>> getAll() async {
    return _items;
  }

  // Asynchronously update an item
  Future<void> update(T item, T newItem) async {
    var index = _items.indexWhere((element) => element == item);
    if (index != -1) {
      _items[index] = newItem;
    } else {
      throw Exception("Item not found");
    }
  }

  // Asynchronously delete an item
  Future<void> delete(T item) async {
    _items.remove(item);
  }
}
