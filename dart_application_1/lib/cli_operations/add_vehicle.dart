import 'dart:io';
import 'package:dart_application_1/globals.dart';
import 'package:dart_application_1/menu.dart';
import 'package:dart_application_1/models/person.dart';

void addVehicle() {
  print("Ange regnummer:");
  String licensePlate = stdin.readLineSync()!;

  print("Ange type av fordon, ex bil, motorcyckel:");
  String vehicleType = stdin.readLineSync()!;

  print("Ange ägare av fordon:");
  String name = stdin.readLineSync()!;

  print("personnummer  ddmmår:");
  String ssn = stdin.readLineSync()!;

  // Initialize the repository
  // VehicleRepository vehicleRepository = VehicleRepository([]);

  // Create a Person object using named parameters
  // Person person = Person(owner: owner, ssn: ssn);
  Person person = Person(name: name, ssn: ssn);

  // Add the vehicle to the repository
  // ignore: prefer_typing_uninitialized_variables
  personRepository.add(person);

  print("Fordon adderat");
}
