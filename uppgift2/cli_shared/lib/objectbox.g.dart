// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again
// with `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'
    as obx_int; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart' as obx;

import 'src/models/bag.dart';
import 'src/models/item.dart';
import 'src/models/parking.dart';
import 'src/models/parking_space.dart';
import 'src/models/person.dart';
import 'src/models/vehicle.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <obx_int.ModelEntity>[
  obx_int.ModelEntity(
      id: const obx_int.IdUid(1, 5734646974315608523),
      name: 'Bag',
      lastPropertyId: const obx_int.IdUid(3, 5912940655653160131),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 2913043497242712178),
            name: 'description',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 6977688743717899067),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 5912940655653160131),
            name: 'itemsInDb',
            type: 9,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(2, 8451282599434045579),
      name: 'Item',
      lastPropertyId: const obx_int.IdUid(2, 7672144424753055690),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 5284212236574591023),
            name: 'description',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 7672144424753055690),
            name: 'id',
            type: 6,
            flags: 1)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(3, 8633875150404365074),
      name: 'Parking',
      lastPropertyId: const obx_int.IdUid(5, 4671941546392095825),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 7532105327852508558),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 1827071331388757674),
            name: 'vehicleId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(1, 2058196314308392112),
            relationTarget: 'Vehicle'),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 7914912545972115442),
            name: 'parkingSpaceId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(2, 7254118980907793203),
            relationTarget: 'ParkingSpace'),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 624995545417993233),
            name: 'startTime',
            type: 10,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(5, 4671941546392095825),
            name: 'endTime',
            type: 10,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(4, 5011713746923030475),
      name: 'ParkingSpace',
      lastPropertyId: const obx_int.IdUid(3, 6139282941170218710),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 1654148026250898876),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 7733829480852838856),
            name: 'address',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 6139282941170218710),
            name: 'pricePerHour',
            type: 6,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(5, 3094493169103715337),
      name: 'Person',
      lastPropertyId: const obx_int.IdUid(3, 6911463499026042805),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 7755114901641342251),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 234065042007494800),
            name: 'name',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 6911463499026042805),
            name: 'ssn',
            type: 9,
            flags: 0)
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[]),
  obx_int.ModelEntity(
      id: const obx_int.IdUid(6, 6268045523101645489),
      name: 'Vehicle',
      lastPropertyId: const obx_int.IdUid(4, 2022103765916613720),
      flags: 0,
      properties: <obx_int.ModelProperty>[
        obx_int.ModelProperty(
            id: const obx_int.IdUid(1, 8827078427124820792),
            name: 'id',
            type: 6,
            flags: 1),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(2, 528972131072100482),
            name: 'licensePlate',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(3, 1479973430197364476),
            name: 'vehicleType',
            type: 9,
            flags: 0),
        obx_int.ModelProperty(
            id: const obx_int.IdUid(4, 2022103765916613720),
            name: 'ownerId',
            type: 11,
            flags: 520,
            indexId: const obx_int.IdUid(3, 7125145027456338928),
            relationTarget: 'Person')
      ],
      relations: <obx_int.ModelRelation>[],
      backlinks: <obx_int.ModelBacklink>[])
];

/// Shortcut for [obx.Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [obx.Store.new] for an explanation of all parameters.
///
/// For Flutter apps, also calls `loadObjectBoxLibraryAndroidCompat()` from
/// the ObjectBox Flutter library to fix loading the native ObjectBox library
/// on Android 6 and older.
obx.Store openStore(
    {String? directory,
    int? maxDBSizeInKB,
    int? maxDataSizeInKB,
    int? fileMode,
    int? maxReaders,
    bool queriesCaseSensitiveDefault = true,
    String? macosApplicationGroup}) {
  return obx.Store(getObjectBoxModel(),
      directory: directory,
      maxDBSizeInKB: maxDBSizeInKB,
      maxDataSizeInKB: maxDataSizeInKB,
      fileMode: fileMode,
      maxReaders: maxReaders,
      queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
      macosApplicationGroup: macosApplicationGroup);
}

/// Returns the ObjectBox model definition for this project for use with
/// [obx.Store.new].
obx_int.ModelDefinition getObjectBoxModel() {
  final model = obx_int.ModelInfo(
      entities: _entities,
      lastEntityId: const obx_int.IdUid(6, 6268045523101645489),
      lastIndexId: const obx_int.IdUid(3, 7125145027456338928),
      lastRelationId: const obx_int.IdUid(0, 0),
      lastSequenceId: const obx_int.IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, obx_int.EntityDefinition>{
    Bag: obx_int.EntityDefinition<Bag>(
        model: _entities[0],
        toOneRelations: (Bag object) => [],
        toManyRelations: (Bag object) => {},
        getId: (Bag object) => object.id,
        setId: (Bag object, int id) {
          object.id = id;
        },
        objectToFB: (Bag object, fb.Builder fbb) {
          final descriptionOffset = fbb.writeString(object.description);
          final itemsInDbOffset = fbb.writeString(object.itemsInDb);
          fbb.startTable(4);
          fbb.addOffset(0, descriptionOffset);
          fbb.addInt64(1, object.id);
          fbb.addOffset(2, itemsInDbOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final descriptionParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 4, '');
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0);
          final object = Bag(description: descriptionParam, id: idParam)
            ..itemsInDb = const fb.StringReader(asciiOptimization: true)
                .vTableGet(buffer, rootOffset, 8, '');

          return object;
        }),
    Item: obx_int.EntityDefinition<Item>(
        model: _entities[1],
        toOneRelations: (Item object) => [],
        toManyRelations: (Item object) => {},
        getId: (Item object) => object.id,
        setId: (Item object, int id) {
          object.id = id;
        },
        objectToFB: (Item object, fb.Builder fbb) {
          final descriptionOffset = fbb.writeString(object.description);
          fbb.startTable(3);
          fbb.addOffset(0, descriptionOffset);
          fbb.addInt64(1, object.id);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final descriptionParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 4, '');
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0);
          final object = Item(descriptionParam, idParam);

          return object;
        }),
    Parking: obx_int.EntityDefinition<Parking>(
        model: _entities[2],
        toOneRelations: (Parking object) =>
            [object.vehicle, object.parkingSpace],
        toManyRelations: (Parking object) => {},
        getId: (Parking object) => object.id,
        setId: (Parking object, int id) {
          object.id = id;
        },
        objectToFB: (Parking object, fb.Builder fbb) {
          fbb.startTable(6);
          fbb.addInt64(0, object.id);
          fbb.addInt64(1, object.vehicle.targetId);
          fbb.addInt64(2, object.parkingSpace.targetId);
          fbb.addInt64(3, object.startTime.millisecondsSinceEpoch);
          fbb.addInt64(4, object.endTime?.millisecondsSinceEpoch);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final endTimeValue =
              const fb.Int64Reader().vTableGetNullable(buffer, rootOffset, 12);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final startTimeParam = DateTime.fromMillisecondsSinceEpoch(
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0));
          final endTimeParam = endTimeValue == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(endTimeValue);
          final object = Parking(
              id: idParam, startTime: startTimeParam, endTime: endTimeParam);
          object.vehicle.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 6, 0);
          object.vehicle.attach(store);
          object.parkingSpace.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0);
          object.parkingSpace.attach(store);
          return object;
        }),
    ParkingSpace: obx_int.EntityDefinition<ParkingSpace>(
        model: _entities[3],
        toOneRelations: (ParkingSpace object) => [],
        toManyRelations: (ParkingSpace object) => {},
        getId: (ParkingSpace object) => object.id,
        setId: (ParkingSpace object, int id) {
          object.id = id;
        },
        objectToFB: (ParkingSpace object, fb.Builder fbb) {
          final addressOffset = fbb.writeString(object.address);
          fbb.startTable(4);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, addressOffset);
          fbb.addInt64(2, object.pricePerHour);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final addressParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final pricePerHourParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 8, 0);
          final object = ParkingSpace(
              id: idParam,
              address: addressParam,
              pricePerHour: pricePerHourParam);

          return object;
        }),
    Person: obx_int.EntityDefinition<Person>(
        model: _entities[4],
        toOneRelations: (Person object) => [],
        toManyRelations: (Person object) => {},
        getId: (Person object) => object.id,
        setId: (Person object, int id) {
          object.id = id;
        },
        objectToFB: (Person object, fb.Builder fbb) {
          final nameOffset = fbb.writeString(object.name);
          final ssnOffset = fbb.writeString(object.ssn);
          fbb.startTable(4);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, nameOffset);
          fbb.addOffset(2, ssnOffset);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final ssnParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 8, '');
          final object = Person(id: idParam, name: nameParam, ssn: ssnParam);

          return object;
        }),
    Vehicle: obx_int.EntityDefinition<Vehicle>(
        model: _entities[5],
        toOneRelations: (Vehicle object) => [object.owner],
        toManyRelations: (Vehicle object) => {},
        getId: (Vehicle object) => object.id,
        setId: (Vehicle object, int id) {
          object.id = id;
        },
        objectToFB: (Vehicle object, fb.Builder fbb) {
          final licensePlateOffset = fbb.writeString(object.licensePlate);
          final vehicleTypeOffset = fbb.writeString(object.vehicleType);
          fbb.startTable(5);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, licensePlateOffset);
          fbb.addOffset(2, vehicleTypeOffset);
          fbb.addInt64(3, object.owner.targetId);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (obx.Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final idParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0);
          final licensePlateParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 6, '');
          final vehicleTypeParam =
              const fb.StringReader(asciiOptimization: true)
                  .vTableGet(buffer, rootOffset, 8, '');
          final object = Vehicle(
              id: idParam,
              licensePlate: licensePlateParam,
              vehicleType: vehicleTypeParam);
          object.owner.targetId =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0);
          object.owner.attach(store);
          return object;
        })
  };

  return obx_int.ModelDefinition(model, bindings);
}

/// [Bag] entity fields to define ObjectBox queries.
class Bag_ {
  /// See [Bag.description].
  static final description =
      obx.QueryStringProperty<Bag>(_entities[0].properties[0]);

  /// See [Bag.id].
  static final id = obx.QueryIntegerProperty<Bag>(_entities[0].properties[1]);

  /// See [Bag.itemsInDb].
  static final itemsInDb =
      obx.QueryStringProperty<Bag>(_entities[0].properties[2]);
}

/// [Item] entity fields to define ObjectBox queries.
class Item_ {
  /// See [Item.description].
  static final description =
      obx.QueryStringProperty<Item>(_entities[1].properties[0]);

  /// See [Item.id].
  static final id = obx.QueryIntegerProperty<Item>(_entities[1].properties[1]);
}

/// [Parking] entity fields to define ObjectBox queries.
class Parking_ {
  /// See [Parking.id].
  static final id =
      obx.QueryIntegerProperty<Parking>(_entities[2].properties[0]);

  /// See [Parking.vehicle].
  static final vehicle =
      obx.QueryRelationToOne<Parking, Vehicle>(_entities[2].properties[1]);

  /// See [Parking.parkingSpace].
  static final parkingSpace =
      obx.QueryRelationToOne<Parking, ParkingSpace>(_entities[2].properties[2]);

  /// See [Parking.startTime].
  static final startTime =
      obx.QueryDateProperty<Parking>(_entities[2].properties[3]);

  /// See [Parking.endTime].
  static final endTime =
      obx.QueryDateProperty<Parking>(_entities[2].properties[4]);
}

/// [ParkingSpace] entity fields to define ObjectBox queries.
class ParkingSpace_ {
  /// See [ParkingSpace.id].
  static final id =
      obx.QueryIntegerProperty<ParkingSpace>(_entities[3].properties[0]);

  /// See [ParkingSpace.address].
  static final address =
      obx.QueryStringProperty<ParkingSpace>(_entities[3].properties[1]);

  /// See [ParkingSpace.pricePerHour].
  static final pricePerHour =
      obx.QueryIntegerProperty<ParkingSpace>(_entities[3].properties[2]);
}

/// [Person] entity fields to define ObjectBox queries.
class Person_ {
  /// See [Person.id].
  static final id =
      obx.QueryIntegerProperty<Person>(_entities[4].properties[0]);

  /// See [Person.name].
  static final name =
      obx.QueryStringProperty<Person>(_entities[4].properties[1]);

  /// See [Person.ssn].
  static final ssn =
      obx.QueryStringProperty<Person>(_entities[4].properties[2]);
}

/// [Vehicle] entity fields to define ObjectBox queries.
class Vehicle_ {
  /// See [Vehicle.id].
  static final id =
      obx.QueryIntegerProperty<Vehicle>(_entities[5].properties[0]);

  /// See [Vehicle.licensePlate].
  static final licensePlate =
      obx.QueryStringProperty<Vehicle>(_entities[5].properties[1]);

  /// See [Vehicle.vehicleType].
  static final vehicleType =
      obx.QueryStringProperty<Vehicle>(_entities[5].properties[2]);

  /// See [Vehicle.owner].
  static final owner =
      obx.QueryRelationToOne<Vehicle, Person>(_entities[5].properties[3]);
}
