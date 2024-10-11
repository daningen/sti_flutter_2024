abstract class Repository<T> {
  final List<T> _items = [];

  // Repository(this.items);
  void add(T item) => _items.add(item);

  List<T> getAll() => _items; //getter för att komma åt den privata variabeln

  void update(T item, T newItem) {
    var index = _items.indexWhere((element) => element == item);
    _items[index] = newItem;
  }

  void delete(T item) => _items.remove(item);
}
