// config.dart

const String baseUrl = 'http://localhost:8080';

// vehicle endpoint
const String vehiclesEndpoint = '$baseUrl/vehicles';

String vehicleByIdEndpoint(int id) => '$vehiclesEndpoint/$id';
// Person endpoint
const String personsEndpoint = '$baseUrl/persons';

String personByIdEndpoint(int id) => '$personsEndpoint/$id';
// Parkingspace endpoint
const String parkingSpacesEndpoint = '$baseUrl/parking-spaces';

String parkingSpaceByIdEndpoint(int id) => '$parkingSpacesEndpoint/$id';
//parking end point
const String parkingsEndpoint = '$baseUrl/parkings';

String parkingByIdEndpoint(int id) => '$parkingsEndpoint/$id';
