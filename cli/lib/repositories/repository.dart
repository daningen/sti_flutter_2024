abstract class Repository<T> {
  final List<T> items = [];

  Future<void> add(T item) async {
    items.add(item);
  }

  Future<List<T>> getAll() async {
    return items;
  }

  Future<void> update(T item, T newItem) async {
    var index = items.indexWhere((element) => element == item);
    if (index != -1) {
      items[index] = newItem;
    } else {
      throw Exception("Item not found");
    }
  }

  Future<void> delete(T item) async {
    items.remove(item);
  }
}
