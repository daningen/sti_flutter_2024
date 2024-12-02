class Config {
  static const String baseUrl = 'http://localhost:8080';

  // Define endpoints
  static String get vehiclesEndpoint => '$baseUrl/vehicles';
  static String get personsEndpoint => '$baseUrl/persons';
  static String get parkingSpacesEndpoint => '$baseUrl/parking_spaces';
  static String get parkingsEndpoint => '$baseUrl/parkings';
  // Add other endpoints as needed
}
