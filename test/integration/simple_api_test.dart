import 'dart:convert';

import 'package:kiss_graph/controllers/node_controller.dart';
import 'package:kiss_graph/repositories/node_repository.dart';
import 'package:kiss_graph/services/node_service.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:test/test.dart';

void main() {
  group('Simplified API Integration Tests', () {
    late NodeRepository repository;
    late NodeService service;
    late NodeController controller;
    late Handler app;

    setUp(() {
      // Initialize dependencies
      repository = NodeRepository();
      service = NodeService(repository);
      controller = NodeController(service);

      // Create app
      final router = Router().plus;
      router.use(logRequests());
      controller.setupRoutes(router);
      app = router.call;
    });

    tearDown(() {
      repository.dispose();
      service.dispose();
    });

    group('Direct Handler Tests', () {
      test('should create and retrieve a node through handlers', () async {
        // Create a node using POST
        final createRequest = Request(
          'POST',
          Uri.parse('http://localhost:8080/nodes'),
          body: jsonEncode({
            'previous': null,
            'spatialHash': 'test123',
            'content': {'name': 'Test Node', 'type': 'test'}
          }),
          headers: {'content-type': 'application/json'},
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
        expect(retrievedNode['content']['name'], equals('Test Node'));
      });

      test('should return 404 for non-existent node', () async {
        final request = Request(
          'GET',
          Uri.parse('http://localhost:8080/nodes/non-existent'),
        );

        final response = await app(request);
        expect(response.statusCode, equals(404));
      });

      test('should update a node', () async {
        // Create a node first
        final createRequest = Request(
          'POST',
          Uri.parse('http://localhost:8080/nodes'),
          body: jsonEncode({
            'previous': null,
            'spatialHash': 'update123',
            'content': {'original': 'data'}
          }),
          headers: {'content-type': 'application/json'},
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
            'content': {'updated': 'content'}
          }),
          headers: {'content-type': 'application/json'},
        );

        final updateResponse = await app(updateRequest);
        expect(updateResponse.statusCode, equals(200));

        final updateBody = await updateResponse.readAsString();
        final updatedNode = jsonDecode(updateBody);

        expect(updatedNode['spatialHash'], equals('updated123'));
        expect(updatedNode['content']['updated'], equals('content'));
      });

      test('should get children of a node', () async {
        // Create parent
        final parentRequest = Request(
          'POST',
          Uri.parse('http://localhost:8080/nodes'),
          body: jsonEncode({
            'previous': null,
            'spatialHash': 'parent123',
            'content': {'type': 'parent'}
          }),
          headers: {'content-type': 'application/json'},
        );

        final parentResponse = await app(parentRequest);
        final parentBody = await parentResponse.readAsString();
        final parentNode = jsonDecode(parentBody);

        // Create child
        final childRequest = Request(
          'POST',
          Uri.parse('http://localhost:8080/nodes'),
          body: jsonEncode({
            'previous': parentNode['id'],
            'spatialHash': 'child123',
            'content': {'type': 'child'}
          }),
          headers: {'content-type': 'application/json'},
        );

        await app(childRequest);

        // Get children
        final childrenRequest = Request(
          'GET',
          Uri.parse('http://localhost:8080/nodes/${parentNode['id']}/children'),
        );

        final childrenResponse = await app(childrenRequest);
        expect(childrenResponse.statusCode, equals(200));

        final childrenBody = await childrenResponse.readAsString();
        final children = jsonDecode(childrenBody) as List;

        expect(children.length, equals(1));
        expect(children.first['content']['type'], equals('child'));
      });

      test('should trace path from child to root', () async {
        // Create root
        final rootRequest = Request(
          'POST',
          Uri.parse('http://localhost:8080/nodes'),
          body: jsonEncode({
            'previous': null,
            'spatialHash': 'root123',
            'content': {'level': 'root'}
          }),
          headers: {'content-type': 'application/json'},
        );

        final rootResponse = await app(rootRequest);
        final rootBody = await rootResponse.readAsString();
        final rootNode = jsonDecode(rootBody);

        // Create child
        final childRequest = Request(
          'POST',
          Uri.parse('http://localhost:8080/nodes'),
          body: jsonEncode({
            'previous': rootNode['id'],
            'spatialHash': 'child123',
            'content': {'level': 'child'}
          }),
          headers: {'content-type': 'application/json'},
        );

        final childResponse = await app(childRequest);
        final childBody = await childResponse.readAsString();
        final childNode = jsonDecode(childBody);

        // Trace from child
        final traceRequest = Request(
          'GET',
          Uri.parse('http://localhost:8080/nodes/${childNode['id']}/trace'),
        );

        final traceResponse = await app(traceRequest);
        expect(traceResponse.statusCode, equals(200));

        final traceBody = await traceResponse.readAsString();
        final trace = jsonDecode(traceBody) as List;

        expect(trace.length, equals(2));
        expect(trace[0]['id'], equals(childNode['id'])); // Child first
        expect(trace[1]['id'], equals(rootNode['id'])); // Root last
      });

      test('should query nodes by spatial prefix', () async {
        // Create nodes with different spatial hashes
        final node1Request = Request(
          'POST',
          Uri.parse('http://localhost:8080/nodes'),
          body: jsonEncode({
            'previous': null,
            'spatialHash': 'abc123',
            'content': {'region': 'north'}
          }),
          headers: {'content-type': 'application/json'},
        );

        final node2Request = Request(
          'POST',
          Uri.parse('http://localhost:8080/nodes'),
          body: jsonEncode({
            'previous': null,
            'spatialHash': 'abc456',
            'content': {'region': 'northeast'}
          }),
          headers: {'content-type': 'application/json'},
        );

        final node3Request = Request(
          'POST',
          Uri.parse('http://localhost:8080/nodes'),
          body: jsonEncode({
            'previous': null,
            'spatialHash': 'def789',
            'content': {'region': 'south'}
          }),
          headers: {'content-type': 'application/json'},
        );

        await app(node1Request);
        await app(node2Request);
        await app(node3Request);

        // Query by spatial prefix
        final spatialRequest = Request(
          'GET',
          Uri.parse('http://localhost:8080/nodes/spatial/abc'),
        );

        final spatialResponse = await app(spatialRequest);
        expect(spatialResponse.statusCode, equals(200));

        final spatialBody = await spatialResponse.readAsString();
        final spatialNodes = jsonDecode(spatialBody) as List;

        expect(spatialNodes.length, equals(2)); // abc123 and abc456
        expect(spatialNodes.every((n) => n['spatialHash'].startsWith('abc')),
            isTrue);
      });

      test('should handle error cases', () async {
        // Test invalid JSON
        final invalidRequest = Request(
          'POST',
          Uri.parse('http://localhost:8080/nodes'),
          body: 'invalid json',
          headers: {'content-type': 'application/json'},
        );

        final invalidResponse = await app(invalidRequest);
        expect(invalidResponse.statusCode, equals(400));

        // Test non-existent parent
        final orphanRequest = Request(
          'POST',
          Uri.parse('http://localhost:8080/nodes'),
          body: jsonEncode({
            'previous': 'non-existent-parent',
            'spatialHash': 'orphan123',
            'content': {'status': 'orphaned'}
          }),
          headers: {'content-type': 'application/json'},
        );

        final orphanResponse = await app(orphanRequest);
        expect(orphanResponse.statusCode, equals(400));
      });
    });
  });
}
