import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'dart:convert';

// Variable to hold the ID of the created person
int? createdPersonId;

void main() {
  final port = '8080';
  final host = 'http://localhost:$port';
  late Process serverProcess;

  setUpAll(() async {
    // Start the server process for testing
    serverProcess = await Process.start(
      'dart',
      ['run', 'bin/cli_server.dart'],
      environment: {'PORT': port},
      mode: ProcessStartMode.detachedWithStdio,
    );

    // Capture the server's stdout and print it to the main console
    serverProcess.stdout.transform(utf8.decoder).listen((data) {
      print("SERVER OUTPUT: $data");
    });

    // Ensure the server has started before proceeding
    await Future.delayed(
        const Duration(seconds: 2)); // Wait to ensure server starts
    print('Server started on port $port');
  });

  tearDownAll(() {
    serverProcess.kill(); // Kill server process after all tests
  });

  String name = 'Dan Test X';
  String ssn = '020606';

  test('Create Person', () async {
    final response = await http.post(
      Uri.parse('$host/persons'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'ssn': ssn}),
    );
    print('Create Person response: ${response.body}');
    expect(response.statusCode, 200); // Expecting 200 for successful creation

    // Extract and store the ID for use in other tests
    final responseBody = jsonDecode(response.body);
    createdPersonId = responseBody['id'];

    print('Created Person ID: $createdPersonId');
    String createdName = responseBody['name'];
    print('Created Name: $createdName');

    // Optional: Validate the name in the response matches the one sent
    expect(createdName, name,
        reason: 'Expected created name to match the input name');
  });

  test('Update Person', () async {
    // Ensure the person was created and ID is available
    expect(createdPersonId, isNotNull,
        reason: 'The person must be created before running the update test.');

    // Define the updated data
    String updatedName = 'Updated Name';
    String updatedSSN = '990910';

    // Use the created ID to update the person
    print('Updating person with ID: $createdPersonId');
    final updateResponse = await http.put(
      Uri.parse('$host/persons/$createdPersonId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': updatedName, 'ssn': updatedSSN}),
    );

    print('Update Person response: ${updateResponse.body}');
    expect(updateResponse.statusCode, 200,
        reason: 'Expected 200 OK, got ${updateResponse.statusCode}');

    // Verify the update by fetching the person
    final getResponse =
        await http.get(Uri.parse('$host/persons/$createdPersonId'));
    expect(getResponse.statusCode, 200,
        reason: 'Expected 200 OK when retrieving updated person');

    final updatedPerson = jsonDecode(getResponse.body);
    expect(updatedPerson['name'], updatedName,
        reason: 'Expected updated name to match the input name');
    expect(updatedPerson['ssn'], updatedSSN,
        reason: 'Expected updated SSN to match the input SSN');
  });

  test('Delete Person', () async {
    expect(createdPersonId, isNotNull,
        reason: 'Person ID must be available for deletion');

    // Use the created ID to delete the person
    final deleteResponse = await http.delete(
      Uri.parse('$host/persons/$createdPersonId'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Delete Person response: ${deleteResponse.body}');
    expect(deleteResponse.statusCode, 200, reason: 'Expected 200 OK');

    // Verify the deletion
    final getResponse = await http.get(
      Uri.parse('$host/persons/$createdPersonId'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Get Deleted Person response: ${getResponse.body}');
    expect(getResponse.statusCode, 404,
        reason: 'Expected 404 Not Found for deleted person');
  });

  test('Get All Persons', () async {
    final response = await http.get(Uri.parse('$host/persons'));
    print('Get All Persons response: ${response.body}');
    expect(response.statusCode, 200);

    // Parse the response to check if any person has the name "Dan Test"
    final List<dynamic> persons = jsonDecode(response.body);
    final personExists = persons
        .any((person) => person['name'] == 'lisa' && person['ssn'] == '440404');
    expect(personExists, isTrue);
  });
}
