import 'dart:io';

class Config {
  static final String hostname = Platform.isAndroid ? "10.0.2.2" : "localhost";
  static final String baseUrl = 'http://$hostname:8080';

  // Define endpoints
  static String get vehiclesEndpoint => '$baseUrl/vehicles';
  static String get personsEndpoint => '$baseUrl/persons';
  static String get parkingSpacesEndpoint => '$baseUrl/parking_spaces';
  static String get parkingsEndpoint => '$baseUrl/parkings';
  // Add other endpoints as needed
}
