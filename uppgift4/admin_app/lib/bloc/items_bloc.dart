
import 'package:bloc/bloc.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:equatable/equatable.dart';
import 'package:shared/shared.dart';

part 'items_state.dart';
part 'items_event.dart';

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  final ItemRepository repository;

  ItemsBloc({required this.repository}) : super(ItemsInitial()) {
    on<ItemsEvent>((event, emit) async {
      try {
        switch (event) {
          case LoadItems():
            await onLoadItems(emit);

          case UpdateItem(item: final item):
            await onUpdateItem(item, emit);

          case CreateItem(item: final item):
            await onCreateItem(item, emit);

          case DeleteItem(item: final item):
            await onDeleteItem(emit, item);
          case ReloadItems():
            await onReloadItems(emit);
        }
      } catch (e) {
        emit(ItemsError(message: e.toString()));
      }
    });
  }

  Future<void> onReloadItems(Emitter<ItemsState> emit) async {
    final items = await repository.getAll();
    emit(ItemsLoaded(items: items));
  }

  Future<void> onDeleteItem(Emitter<ItemsState> emit, Item item) async {
    final currentItems = switch (state) {
      ItemsLoaded(:final items) => [...items],
      _ => <Item>[],
    };
    emit(ItemsLoaded(items: currentItems, pending: item));

    await repository.delete(item.id);
    final items = await repository.getAll();
    emit(ItemsLoaded(items: items));
  }

  Future<void> onCreateItem(Item item, Emitter<ItemsState> emit) async {
    final currentItems = switch (state) {
      ItemsLoaded(:final items) => [...items],
      _ => <Item>[],
    };
    currentItems.add(item);
    emit(ItemsLoaded(items: currentItems, pending: item));

    await repository.create(item);
    final items = await repository.getAll();
    emit(ItemsLoaded(items: items));
  }

  Future<void> onUpdateItem(Item item, Emitter<ItemsState> emit) async {
    final currentItems = switch (state) {
      ItemsLoaded(:final items) => [...items],
      _ => <Item>[],
    };
    var index = currentItems.indexWhere((e) => item.id == e.id);
    currentItems.removeAt(index);
    currentItems.insert(index, item);
    emit(ItemsLoaded(items: currentItems, pending: item));
    await repository.update(item.id, item);
    final items = await repository.getAll();
    emit(ItemsLoaded(items: items));
  }

  Future<void> onLoadItems(Emitter<ItemsState> emit) async {
    emit(ItemsLoading());
    final items = await repository.getAll();
    emit(ItemsLoaded(items: items));
  }
}
