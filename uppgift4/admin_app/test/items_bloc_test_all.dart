import 'package:shared/bloc/items/items_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/shared.dart';

// Define a Fake for Item
class FakeItem extends Fake implements Item {}

// Mock repository
class MockItemRepository extends Mock implements ItemRepository {}

// Utility function to log Bloc states
void logBlocStream<T>(BlocBase<T> bloc, String testName) {
  bloc.stream.listen((state) {
    debugPrint('[$testName] State emitted: $state');
  });
}

void main() {
  group('ItemsBloc', () {
    late ItemRepository itemRepository;

    setUp(() {
      itemRepository = MockItemRepository();
      registerFallbackValue(Item('', -1)); // Fallback for uninitialized Items
    });

    group("create test", () {
      final newItem = Item("new item");

      blocTest<ItemsBloc, ItemsState>(
        "create item test",
        setUp: () {
          when(() => itemRepository.create(any()))
              .thenAnswer((_) async => newItem);
          when(() => itemRepository.getAll())
              .thenAnswer((_) async => [newItem]);
        },
        build: () {
          final bloc = ItemsBloc(repository: itemRepository);
          logBlocStream(bloc, "Create Test"); // Attach the stream logger
          return bloc;
        },
        seed: () => ItemsLoaded(items: const []),
        act: (bloc) => bloc.add(CreateItem(item: newItem)),
        expect: () => [
          ItemsLoaded(items: const [], pending: newItem), // Intermediate state
          ItemsLoaded(items: [newItem]), // Final state
        ],
        verify: (_) {
          verify(() => itemRepository.create(newItem)).called(1);
          verify(() => itemRepository.getAll()).called(1);
        },
      );
    });

    group("update test", () {
      final existingItem = Item("existing item", 1);
      final updatedItem = Item("updated item", 1);

      blocTest<ItemsBloc, ItemsState>(
        "update item test",
        setUp: () {
          when(() => itemRepository.update(any(), any()))
              .thenAnswer((_) async => updatedItem);
          when(() => itemRepository.getAll())
              .thenAnswer((_) async => [updatedItem]);
        },
        build: () {
          final bloc = ItemsBloc(repository: itemRepository);
          logBlocStream(bloc, "Update Test"); // Attach the stream logger
          return bloc;
        },
        seed: () => ItemsLoaded(items: [existingItem]),
        act: (bloc) => bloc.add(UpdateItem(item: updatedItem)),
        expect: () => [
          ItemsLoaded(items: [updatedItem], pending: updatedItem),
          ItemsLoaded(items: [updatedItem]),
        ],
        verify: (_) {
          verify(() => itemRepository.update(updatedItem.id, updatedItem))
              .called(1);
          verify(() => itemRepository.getAll()).called(1);
        },
      );
    });

    group("delete test", () {
      final existingItem = Item("existing item", 1);

      blocTest<ItemsBloc, ItemsState>(
        "delete item test",
        setUp: () {
          when(() => itemRepository.delete(existingItem.id))
              .thenAnswer((_) async => existingItem);
          when(() => itemRepository.getAll()).thenAnswer((_) async => []);
        },
        build: () => ItemsBloc(repository: itemRepository),
        seed: () => ItemsLoaded(items: [existingItem]),
        act: (bloc) => bloc.add(DeleteItem(item: existingItem)),
        expect: () => [
          ItemsLoaded(
              items: [existingItem],
              pending: existingItem), // Intermediate state
          ItemsLoaded(items: const []), // Final state
        ],
        verify: (_) {
          verify(() => itemRepository.delete(existingItem.id)).called(1);
          verify(() => itemRepository.getAll()).called(1);
        },
      );
    });
  });
}
