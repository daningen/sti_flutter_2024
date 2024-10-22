// config.dart

const String baseUrl = 'http://localhost:8080';

// Endpoints for vehicles
const String vehiclesEndpoint = '$baseUrl/vehicles';

// Function to get a vehicle by its ID (replace ':id' dynamically)
String vehicleByIdEndpoint(int id) => '$vehiclesEndpoint/$id';

// Endpoints for persons
const String personsEndpoint = '$baseUrl/persons';

// Function to get a person by their ID (replace ':id' dynamically)
String personByIdEndpoint(int id) => '$personsEndpoint/$id';

// Endpoints for parking spaces
const String parkingSpacesEndpoint = '$baseUrl/parking-spaces';

// Function to get a parking space by its ID (replace ':id' dynamically)
String parkingSpaceByIdEndpoint(int id) => '$parkingSpacesEndpoint/$id';

// Endpoints for parkings
const String parkingsEndpoint = '$baseUrl/parkings';

// Function to get a parking session by its ID (replace ':id' dynamically)
String parkingByIdEndpoint(int id) => '$parkingsEndpoint/$id';

// Function to get parking by vehicle's license plate (if API supports it)
String parkingByLicensePlateEndpoint(String licensePlate) =>
    '$parkingsEndpoint?licensePlate=$licensePlate';
