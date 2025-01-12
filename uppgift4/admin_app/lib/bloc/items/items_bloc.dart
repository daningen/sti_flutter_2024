import 'package:bloc/bloc.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

part 'items_state.dart';
part 'items_event.dart';

class ItemsBloc extends Bloc<ItemsEvent, ItemsState> {
  final ItemRepository repository;

  ItemsBloc({required this.repository}) : super(ItemsInitial()) {
    on<LoadItems>(_onLoadItems);
    on<ReloadItems>(_onReloadItems);
    on<CreateItem>(_onCreateItem);
    on<UpdateItem>(_onUpdateItem);
    on<DeleteItem>(_onDeleteItem);
  }

  Future<void> _onLoadItems(LoadItems event, Emitter<ItemsState> emit) async {
    debugPrint('Loading items...');
    emit(ItemsLoading());
    try {
      final items = await repository.getAll();
      debugPrint('Items loaded: $items');
      emit(ItemsLoaded(items: items));
    } catch (e) {
      debugPrint('Error loading items: $e');
      emit(ItemsError(message: e.toString()));
    }
  }

  Future<void> _onReloadItems(
      ReloadItems event, Emitter<ItemsState> emit) async {
    debugPrint('Reloading items...');
    try {
      final items = await repository.getAll();
      debugPrint('Items reloaded: $items');
      emit(ItemsLoaded(items: items));
    } catch (e) {
      debugPrint('Error reloading items: $e');
      emit(ItemsError(message: e.toString()));
    }
  }

  Future<void> _onCreateItem(CreateItem event, Emitter<ItemsState> emit) async {
    debugPrint('Creating item: ${event.item}');
    final currentItems = _getCurrentItems();
    emit(ItemsLoaded(items: currentItems, pending: event.item));
    try {
      await repository.create(event.item);
      debugPrint('Item created: ${event.item}');
      final items = await repository.getAll();
      emit(ItemsLoaded(items: items));
    } catch (e) {
      debugPrint('Error creating item: $e');
      emit(ItemsError(message: e.toString()));
    }
  }

  Future<void> _onUpdateItem(UpdateItem event, Emitter<ItemsState> emit) async {
    debugPrint('Updating item: ${event.item}');
    final currentItems = _getCurrentItems();
    final index = currentItems.indexWhere((e) => e.id == event.item.id);
    if (index != -1) {
      currentItems[index] = event.item;
    }
    emit(ItemsLoaded(items: currentItems, pending: event.item));
    try {
      await repository.update(event.item.id, event.item);
      debugPrint('Item updated: ${event.item}');
      final items = await repository.getAll();
      emit(ItemsLoaded(items: items));
    } catch (e) {
      debugPrint('Error updating item: $e');
      emit(ItemsError(message: e.toString()));
    }
  }

  Future<void> _onDeleteItem(DeleteItem event, Emitter<ItemsState> emit) async {
    debugPrint('Deleting item: ${event.item}');
    final currentItems = _getCurrentItems();
    emit(ItemsLoaded(items: currentItems, pending: event.item));
    try {
      await repository.delete(event.item.id);
      debugPrint('Item deleted: ${event.item}');
      final items = await repository.getAll();
      emit(ItemsLoaded(items: items));
    } catch (e) {
      debugPrint('Error deleting item: $e');
      emit(ItemsError(message: e.toString()));
    }
  }

  List<Item> _getCurrentItems() {
    return state is ItemsLoaded
        ? List<Item>.from((state as ItemsLoaded).items)
        : <Item>[];
  }
}
