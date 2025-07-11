import 'dart:convert';

import 'package:kiss_graph/kiss_graph.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:test/test.dart';

void main() {
  group('Simple API Integration Tests', () {
    late Handler app;
    late GraphApiConfiguration config;

    setUp(() {
      final router = Router().plus;

      config = GraphApiConfiguration.withInMemoryRepository()
        ..setupRoutes(router);

      app = router.call;
    });

    tearDown(() {
      config.dispose();
    });

    test('should create and retrieve a node', () async {
      final createRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
          'content': {'name': 'Test Node', 'description': 'A test node'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final createResponse = await app(createRequest);
      expect(createResponse.statusCode, equals(201));

      final createBody = await createResponse.readAsString();
      final createdNode = jsonDecode(createBody);

      expect(createdNode['id'], isNotEmpty);
      expect(createdNode['pathHash'], equals('1'));
      expect(createdNode['content']['name'], equals('Test Node'));
      final getRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/nodes/${createdNode['id']}'),
      );

      final getResponse = await app(getRequest);
      expect(getResponse.statusCode, equals(200));

      final getBody = await getResponse.readAsString();
      final retrievedNode = jsonDecode(getBody);

      expect(retrievedNode['id'], equals(createdNode['id']));
      expect(retrievedNode['pathHash'], equals('1'));
      expect(retrievedNode['content']['name'], equals('Test Node'));
    });

    test('should create a parent-child relationship', () async {
      final parentRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
          'content': {'type': 'parent'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final parentResponse = await app(parentRequest);
      expect(parentResponse.statusCode, equals(201));

      final parentBody = await parentResponse.readAsString();
      final parent = jsonDecode(parentBody);
      final childRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': parent['id'],
          'content': {'type': 'child'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final childResponse = await app(childRequest);
      expect(childResponse.statusCode, equals(201));

      final childBody = await childResponse.readAsString();
      final child = jsonDecode(childBody);

      expect(child['previous'], equals(parent['id']));
      expect(child['root'], equals(parent['root']));
      expect(child['pathHash'], equals('1.1'));
      expect(child['content']['type'], equals('child'));
      final childrenRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/nodes/${parent['id']}/children'),
      );

      final childrenResponse = await app(childrenRequest);
      expect(childrenResponse.statusCode, equals(200));

      final childrenBody = await childrenResponse.readAsString();
      final children = jsonDecode(childrenBody);

      expect(children, isA<List<dynamic>>());
      expect(children.length, equals(1));
      expect(children[0]['id'], equals(child['id']));
    });

    test('should update a node', () async {
      final createRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
          'content': {'status': 'original'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final createResponse = await app(createRequest);
      final createBody = await createResponse.readAsString();
      final createdNode = jsonDecode(createBody);
      final updateRequest = Request(
        'PATCH',
        Uri.parse('http://localhost:8080/nodes/${createdNode['id']}'),
        body: jsonEncode({
          'pathHash': 'updated-path',
          'content': {'status': 'updated', 'new': 'field'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final updateResponse = await app(updateRequest);
      expect(updateResponse.statusCode, equals(200));

      final updateBody = await updateResponse.readAsString();
      final updatedNode = jsonDecode(updateBody);

      expect(updatedNode['id'], equals(createdNode['id']));
      expect(updatedNode['pathHash'], equals('updated-path'));
      expect(updatedNode['content']['status'], equals('updated'));
      expect(updatedNode['content']['new'], equals('field'));
    });

    test('should delete a node', () async {
      final createRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
          'content': {'temp': 'node'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final createResponse = await app(createRequest);
      final createBody = await createResponse.readAsString();
      final createdNode = jsonDecode(createBody);
      final deleteRequest = Request(
        'DELETE',
        Uri.parse('http://localhost:8080/nodes/${createdNode['id']}'),
      );

      final deleteResponse = await app(deleteRequest);
      expect(deleteResponse.statusCode, equals(204));
      final getRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/nodes/${createdNode['id']}'),
      );

      final getResponse = await app(getRequest);
      expect(getResponse.statusCode, equals(404));
    });

    test('should trace a node path', () async {
      final rootRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
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
          'content': {'level': 1}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final child1Response = await app(child1Request);
      final child1Body = await child1Response.readAsString();
      final child1 = jsonDecode(child1Body);

      // Trace from child back to root
      final traceRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/nodes/${child1['id']}/trace'),
      );

      final traceResponse = await app(traceRequest);
      expect(traceResponse.statusCode, equals(200));

      final traceBody = await traceResponse.readAsString();
      final trace = jsonDecode(traceBody);

      expect(trace, isA<List<dynamic>>());
      expect(trace.length, equals(2)); // child1 and root
      expect(trace[0]['id'], equals(child1['id'])); // First should be child1
      expect(trace[1]['id'], equals(root['id'])); // Second should be root
    });

    test('should query nodes by path prefix', () async {
      // Create nodes with different path hashes
      final requests = [
        {
          'content': {'region': 'North'}
        },
        {
          'content': {'region': 'North-East'}
        },
        {
          'content': {'region': 'South'}
        },
      ];

      final createdNodes = <Map<String, dynamic>>[];

      // Create first node (will get path "1")
      final request1 = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
          ...requests[0],
        }),
        headers: {'Content-Type': 'application/json'},
      );
      final response1 = await app(request1);
      final body1 = await response1.readAsString();
      final node1 = jsonDecode(body1) as Map<String, dynamic>;
      createdNodes.add(node1);

      // Create second node as child of first (will get path "1.1")
      final request2 = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': node1['id'],
          ...requests[1],
        }),
        headers: {'Content-Type': 'application/json'},
      );
      final response2 = await app(request2);
      final body2 = await response2.readAsString();
      final node2 = jsonDecode(body2) as Map<String, dynamic>;
      createdNodes.add(node2);

      // Create third node as another child of first (will get path "1.2")
      final request3 = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': node1['id'], // Make it a child of node1
          ...requests[2],
        }),
        headers: {'Content-Type': 'application/json'},
      );
      final response3 = await app(request3);
      final body3 = await response3.readAsString();
      final node3 = jsonDecode(body3) as Map<String, dynamic>;
      createdNodes.add(node3);

      // Query for nodes with '1' prefix (should get nodes with paths starting with "1")
      final pathRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/nodes/path/1'),
      );

      final pathResponse = await app(pathRequest);
      expect(pathResponse.statusCode, equals(200));

      final pathBody = await pathResponse.readAsString();
      final pathNodes = jsonDecode(pathBody);

      expect(pathNodes, isA<List<dynamic>>());
      expect(pathNodes.length, equals(3)); // Should get "1", "1.1", and "1.2"

      final pathHashes =
          pathNodes.map((dynamic node) => node['pathHash']).toList();
      expect(pathHashes, contains('1'));
      expect(pathHashes, contains('1.1'));
      expect(pathHashes, contains('1.2'));
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
      // Create parent
      final parentRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': '',
          'content': {'type': 'parent'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      final parentResponse = await app(parentRequest);
      final parentBody = await parentResponse.readAsString();
      final parent = jsonDecode(parentBody);

      // Create child
      final childRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/nodes'),
        body: jsonEncode({
          'previous': parent['id'],
          'content': {'type': 'child'}
        }),
        headers: {'Content-Type': 'application/json'},
      );

      await app(childRequest);

      // Try to delete parent - should fail with 409
      final deleteRequest = Request(
        'DELETE',
        Uri.parse('http://localhost:8080/nodes/${parent['id']}'),
      );

      final deleteResponse = await app(deleteRequest);
      expect(deleteResponse.statusCode, equals(409));
    });
  });
}
