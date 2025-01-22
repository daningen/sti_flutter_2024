part of 'items_bloc.dart';

 

sealed class ItemsEvent {}

class LoadItems extends ItemsEvent {}

class ReloadItems extends ItemsEvent {}

class UpdateItem extends ItemsEvent {
  final String id; // Ensure this is a String
  final Item item;

  UpdateItem({required this.id, required this.item});
}


class CreateItem extends ItemsEvent {
  final Item item;

  CreateItem({required this.item});
}

class DeleteItem extends ItemsEvent {
  final Item item;

  DeleteItem({required this.item});
}
