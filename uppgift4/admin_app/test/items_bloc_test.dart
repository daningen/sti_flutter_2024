import 'package:admin_app/bloc/items/items_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:client_repositories/async_http_repos.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared/shared.dart';

/// Mock implementation of the ItemRepository for testing purposes.
class MockItemRepository extends Mock implements ItemRepository {}

/// Fake implementation of the Item class for testing purposes.
class FakeItem extends Fake implements Item {}

void main() {
  group('ItemsBloc', () {
    late ItemRepository itemRepository;

    setUp(() {
      itemRepository = MockItemRepository();
    });

    // setUpAll(() {
    //   registerFallbackValue(FakeItem());
    // });

    blocTest<ItemsBloc, ItemsState>(
      'emits [ItemsLoading, ItemsLoaded] when LoadItems is added',
      build: () {
        when(() => itemRepository.getAll()).thenAnswer((_) async {
          debugPrint('Mock Repository: Returning items');
          return [Item('Test Item', 1)];
        });
        return ItemsBloc(repository: itemRepository);
      },
      act: (bloc) {
        debugPrint('Test: Dispatching LoadItems event');
        bloc.add(LoadItems());
      },
      expect: () => [
        ItemsLoading(),
        isA<ItemsLoaded>().having((state) {
          debugPrint('Test: Expecting ItemsLoaded state: ${state.items}');
          return state.items;
        }, 'items', [isA<Item>()]),
      ],
      verify: (_) {
        debugPrint('Test: Verifying repository.getAll() was called');
        verify(() => itemRepository.getAll()).called(1);
      },
    );

    blocTest<ItemsBloc, ItemsState>(
      'Load items test - Empty list', // More descriptive test name
      setUp: () {
        when(() => itemRepository.getAll()).thenAnswer((_) async {
          debugPrint('Mock Repository: Returning empty list');
          return [];
        });
      },
      build: () => ItemsBloc(repository: itemRepository),
      act: (bloc) {
        debugPrint('Test: Dispatching LoadItems event (empty list)');
        bloc.add(LoadItems());
      },
      expect: () => [
        ItemsLoading(),
        ItemsLoaded(items: const []),
      ],
    );
  });
}
