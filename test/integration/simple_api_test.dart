import 'dart:convert';

import 'package:kiss_graph/main.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('Simple API Integration Tests', () {
    late Handler app;

    setUp(() {
      app = init();
    });

    test('should create and retrieve a node', () async {
      // Create a node using POST
      final createRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
          'spatialHash': 'test123',
          'content': {'name': 'Test Node', 'description': 'A test node'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final createResponse = await app(createRequest);
      expect(createResponse.statusCode, equals(201));

      final createBody = await createResponse.readAsString();
      final createdNode = jsonDecode(createBody);

      expect(createdNode['id'], isNotEmpty);
      expect(createdNode['spatialHash'], equals('test123'));
      expect(createdNode['content']['name'], equals('Test Node'));

      // Retrieve the node using GET
      final getRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/nodes/${createdNode['id']}'),
      );

      final getResponse = await app(getRequest);
      expect(getResponse.statusCode, equals(200));

      final getBody = await getResponse.readAsString();
      final retrievedNode = jsonDecode(getBody);

      expect(retrievedNode['id'], equals(createdNode['id']));
      expect(retrievedNode['spatialHash'], equals('test123'));
      expect(retrievedNode['content']['name'], equals('Test Node'));
    });

    test('should create a parent-child relationship', () async {
      // Create parent node
      final parentRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
          'spatialHash': 'parent123',
          'content': {'type': 'parent'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final parentResponse = await app(parentRequest);
      expect(parentResponse.statusCode, equals(201));

      final parentBody = await parentResponse.readAsString();
      final parent = jsonDecode(parentBody);

      // Create child node
      final childRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': parent['id'],
          'spatialHash': 'child123',
          'content': {'type': 'child'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final childResponse = await app(childRequest);
      expect(childResponse.statusCode, equals(201));

      final childBody = await childResponse.readAsString();
      final child = jsonDecode(childBody);

      expect(child['previous'], equals(parent['id']));
      expect(child['root'], equals(parent['root'])); // Should inherit root
      expect(child['content']['type'], equals('child'));

      // Get children of parent
      final childrenRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/nodes/${parent['id']}/children'),
      );

      final childrenResponse = await app(childrenRequest);
      expect(childrenResponse.statusCode, equals(200));

      final childrenBody = await childrenResponse.readAsString();
      final children = jsonDecode(childrenBody);

      expect(children, isA<List>());
      expect(children.length, equals(1));
      expect(children[0]['id'], equals(child['id']));
    });

    test('should update a node', () async {
      // Create a node first
      final createRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
          'spatialHash': 'update123',
          'content': {'status': 'original'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final createResponse = await app(createRequest);
      final createBody = await createResponse.readAsString();
      final createdNode = jsonDecode(createBody);

      // Update the node
      final updateRequest = Request(
        'PATCH',
        Uri.parse('http://localhost:8080/nodes/${createdNode['id']}'),
        body: jsonEncode({
          'spatialHash': 'updated123',
          'content': {'status': 'updated', 'new': 'field'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final updateResponse = await app(updateRequest);
      expect(updateResponse.statusCode, equals(200));

      final updateBody = await updateResponse.readAsString();
      final updatedNode = jsonDecode(updateBody);

      expect(updatedNode['id'], equals(createdNode['id']));
      expect(updatedNode['spatialHash'], equals('updated123'));
      expect(updatedNode['content']['status'], equals('updated'));
      expect(updatedNode['content']['new'], equals('field'));
    });

    test('should delete a node', () async {
      // Create a node first
      final createRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
          'spatialHash': 'delete123',
          'content': {'temp': 'node'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final createResponse = await app(createRequest);
      final createBody = await createResponse.readAsString();
      final createdNode = jsonDecode(createBody);

      // Delete the node
      final deleteRequest = Request(
        'DELETE',
        Uri.parse('http://localhost:8080/nodes/${createdNode['id']}'),
      );

      final deleteResponse = await app(deleteRequest);
      expect(deleteResponse.statusCode, equals(204));

      // Verify node is gone
      final getRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/nodes/${createdNode['id']}'),
      );

      final getResponse = await app(getRequest);
      expect(getResponse.statusCode, equals(404));
    });

    test('should trace a node path', () async {
      // Create a chain of nodes
      final rootRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
          'spatialHash': 'root123',
          'content': {'level': 0}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final rootResponse = await app(rootRequest);
      final rootBody = await rootResponse.readAsString();
      final root = jsonDecode(rootBody);

      final child1Request = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': root['id'],
          'spatialHash': 'child1123',
          'content': {'level': 1}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final child1Response = await app(child1Request);
      final child1Body = await child1Response.readAsString();
      final child1 = jsonDecode(child1Body);

      // Trace from child1 back to root
      final traceRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/nodes/${child1['id']}/trace'),
      );

      final traceResponse = await app(traceRequest);
      expect(traceResponse.statusCode, equals(200));

      final traceBody = await traceResponse.readAsString();
      final trace = jsonDecode(traceBody);

      expect(trace, isA<List>());
      expect(trace.length, equals(2));
      expect(trace[0]['id'], equals(child1['id'])); // Starts with child1
      expect(trace[1]['id'], equals(root['id'])); // Ends with root
    });

    test('should query nodes by spatial prefix', () async {
      // Create nodes with different spatial hashes
      final requests = [
        {
          'spatialHash': 'abc123',
          'content': {'region': 'North'}
        },
        {
          'spatialHash': 'abc456',
          'content': {'region': 'North-East'}
        },
        {
          'spatialHash': 'def789',
          'content': {'region': 'South'}
        },
      ];

      final createdNodes = <Map<String, dynamic>>[];
      for (final requestData in requests) {
        final request = Request(
          'POST',
          Uri.parse('http://localhost:8080/nodes'),
          body: jsonEncode({
            'previous': '',
            ...requestData,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        final response = await app(request);
        final body = await response.readAsString();
        createdNodes.add(jsonDecode(body));
      }

      // Query for nodes with 'abc' prefix
      final spatialRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/nodes/spatial/abc'),
      );

      final spatialResponse = await app(spatialRequest);
      expect(spatialResponse.statusCode, equals(200));

      final spatialBody = await spatialResponse.readAsString();
      final spatialNodes = jsonDecode(spatialBody);

      expect(spatialNodes, isA<List>());
      expect(spatialNodes.length, equals(2)); // abc123 and abc456

      final spatialHashes =
          spatialNodes.map((node) => node['spatialHash']).toList();
      expect(spatialHashes, containsAll(['abc123', 'abc456']));
      expect(spatialHashes, isNot(contains('def789')));
    });

    test('should handle 404 for non-existent node', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8080/nodes/non-existent-id'),
      );

      final response = await app(request);
      expect(response.statusCode, equals(404));
    });

    test('should handle 409 when trying to delete node with children',
        () async {
      // Create parent node
      final parentRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
          'spatialHash': 'parent123',
          'content': {'type': 'parent'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final parentResponse = await app(parentRequest);
      final parentBody = await parentResponse.readAsString();
      final parent = jsonDecode(parentBody);

      // Create child node
      final childRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': parent['id'],
          'spatialHash': 'child123',
          'content': {'type': 'child'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      await app(childRequest);

      // Try to delete parent (should fail)
      final deleteRequest = Request(
        'DELETE',
        Uri.parse('http://localhost:8080/nodes/${parent['id']}'),
      );

      final deleteResponse = await app(deleteRequest);
      expect(deleteResponse.statusCode, equals(409));
    });
  });
}
