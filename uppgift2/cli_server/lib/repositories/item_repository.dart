import 'package:cli_server/router_config.dart';
import 'package:cli_shared/cli_shared.dart';

class ItemRepository implements RepositoryInterface<Item> {
  Box<Item> itemBox = ServerConfig.instance.store.box<Item>();

  @override
  Future<Item> create(Item item) async {
    itemBox.put(item, mode: PutMode.insert);

    // above command did not error
    return item;
  }

  @override
  Future<Item?> getById(int id) async {
    return itemBox.get(id);
  }

  @override
  Future<List<Item>> getAll() async {
    return itemBox.getAll();
  }

  @override
  Future<Item> update(int id, Item newItem) async {
    itemBox.put(newItem, mode: PutMode.update);
    return newItem;
  }

  @override
  Future<Item?> delete(int id) async {
    Item? item = itemBox.get(id);

    if (item != null) {
      itemBox.remove(id);
    }

    return item;
  }
}
