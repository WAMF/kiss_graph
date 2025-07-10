import 'package:kiss_graph/models/node.dart';
import 'package:kiss_graph/repositories/node_queries.dart';
import 'package:kiss_graph/repositories/node_repository.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:test/test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('NodeRepository Tests', () {
    late NodeRepository repository;

    setUp(() {
      repository = NodeRepository();
    });

    tearDown(() {
      repository.dispose();
    });

    group('Basic CRUD Operations', () {
      test('should add and retrieve a node', () async {
        final node = TestData.createRootNode(id: 'test-1');

        final addedNode = await repository.addNode(node);
        expect(addedNode.id, equals(node.id));

        final retrievedNode = await repository.get('test-1');
        expect(retrievedNode.id, equals('test-1'));
        expect(retrievedNode.content, equals(node.content));
      });

      test('should add node using generic add method', () async {
        final node = TestData.createRootNode(id: 'test-2');

        final addedNode = await repository.add(IdentifiedObject(node.id, node));
        expect(addedNode.id, equals(node.id));
      });

      test('should throw RepositoryException when getting non-existent node',
          () async {
        expect(
          () => repository.get('non-existent'),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('should update a node', () async {
        final node = TestData.createRootNode(id: 'update-test');
        await repository.addNode(node);

        final updatedNode = await repository.update('update-test', (current) {
          return current.copyWith(
            spatialHash: 'updated-hash',
            content: {'updated': true},
          );
        });

        expect(updatedNode.spatialHash, equals('updated-hash'));
        expect(updatedNode.content, equals({'updated': true}));
        expect(updatedNode.id, equals('update-test'));
      });

      test('should delete a node', () async {
        final node = TestData.createRootNode(id: 'delete-test');
        await repository.addNode(node);

        await repository.delete('delete-test');

        expect(
          () => repository.get('delete-test'),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('Batch Operations', () {
      test('should add multiple nodes', () async {
        final nodes = TestData.createSpatialNodes();
        final identifiedObjects =
            nodes.map((n) => IdentifiedObject(n.id, n)).toList();

        final addedNodes = await repository.addAll(identifiedObjects);
        expect(addedNodes.length, equals(3));

        for (final node in nodes) {
          final retrieved = await repository.get(node.id);
          expect(retrieved.id, equals(node.id));
        }
      });

      test('should update multiple nodes', () async {
        final nodes = TestData.createSpatialNodes();
        for (final node in nodes) {
          await repository.addNode(node);
        }

        final updates = nodes
            .map((n) => IdentifiedObject(n.id,
                n.copyWith(content: {'updated': true, 'original': n.content})))
            .toList();

        await repository.updateAll(updates);

        for (final node in nodes) {
          final retrieved = await repository.get(node.id);
          expect(retrieved.content['updated'], isTrue);
          expect(retrieved.content['original'], equals(node.content));
        }
      });

      test('should delete multiple nodes', () async {
        final nodes = TestData.createSpatialNodes();
        for (final node in nodes) {
          await repository.addNode(node);
        }

        final ids = nodes.map((n) => n.id).toList();
        await repository.deleteAll(ids);

        for (final id in ids) {
          expect(
            () => repository.get(id),
            throwsA(isA<RepositoryException>()),
          );
        }
      });
    });

    group('Query Operations', () {
      test('should query all nodes', () async {
        final nodes = TestData.createSpatialNodes();
        for (final node in nodes) {
          await repository.addNode(node);
        }

        final allNodes = await repository.query();
        expect(allNodes.length, equals(3));

        final ids = allNodes.map((n) => n.id).toSet();
        expect(ids, containsAll(nodes.map((n) => n.id)));
      });

      test('should query with custom query', () async {
        final nodes = TestData.createSpatialNodes();
        for (final node in nodes) {
          await repository.addNode(node);
        }

        final spatialNodes =
            await repository.query(query: NodeSpatialQuery('abc'));

        expect(spatialNodes.length, equals(2)); // abc123 and abc456
        expect(
            spatialNodes.every((n) => n.spatialHash.startsWith('abc')), isTrue);
      });
    });

    group('Children Query', () {
      test('should get children of a node', () async {
        final rootNode = TestData.createRootNode(id: 'root');
        await repository.addNode(rootNode);

        final child1 = TestData.createChildNode(
          id: 'child-1',
          parentId: 'root',
          rootId: 'root',
        );
        final child2 = TestData.createChildNode(
          id: 'child-2',
          parentId: 'root',
          rootId: 'root',
        );

        await repository.addNode(child1);
        await repository.addNode(child2);

        final children = await repository.getChildren('root');
        expect(children.length, equals(2));
        expect(children.map((c) => c.id), containsAll(['child-1', 'child-2']));
      });

      test('should return empty list for node with no children', () async {
        final node = TestData.createRootNode(id: 'lonely');
        await repository.addNode(node);

        final children = await repository.getChildren('lonely');
        expect(children, isEmpty);
      });

      test('should return empty list for non-existent parent', () async {
        final children = await repository.getChildren('non-existent');
        expect(children, isEmpty);
      });
    });

    group('Spatial Queries', () {
      test('should get nodes by spatial prefix', () async {
        final nodes = TestData.createSpatialNodes();
        for (final node in nodes) {
          await repository.addNode(node);
        }

        final abcNodes = await repository.getSpatialNodes('abc');
        expect(abcNodes.length, equals(2));
        expect(abcNodes.every((n) => n.spatialHash.startsWith('abc')), isTrue);

        final defNodes = await repository.getSpatialNodes('def');
        expect(defNodes.length, equals(1));
        expect(defNodes.first.spatialHash, equals('def789'));
      });

      test('should return empty list for non-matching spatial prefix',
          () async {
        final nodes = TestData.createSpatialNodes();
        for (final node in nodes) {
          await repository.addNode(node);
        }

        final nodesFound = await repository.getSpatialNodes('xyz');
        expect(nodesFound, isEmpty);
      });

      test('should handle exact spatial hash match', () async {
        final node = TestData.createRootNode(
          id: 'exact-match',
          spatialHash: 'exact123',
        );
        await repository.addNode(node);

        final exactMatches = await repository.getSpatialNodes('exact123');
        expect(exactMatches.length, equals(1));
        expect(exactMatches.first.id, equals('exact-match'));
      });
    });

    group('Root Queries', () {
      test('should get nodes by root', () async {
        final rootNode = TestData.createRootNode(id: 'root-1');
        await repository.addNode(rootNode);

        final child1 = TestData.createChildNode(
          id: 'child-1',
          parentId: 'root-1',
          rootId: 'root-1',
        );
        final child2 = TestData.createChildNode(
          id: 'child-2',
          parentId: 'child-1',
          rootId: 'root-1',
        );

        await repository.addNode(child1);
        await repository.addNode(child2);

        // Create another tree
        final otherRoot = TestData.createRootNode(id: 'root-2');
        await repository.addNode(otherRoot);

        final nodesInTree1 = await repository.getByRoot('root-1');
        expect(nodesInTree1.length, equals(3)); // root + 2 children
        expect(nodesInTree1.every((n) => n.root == 'root-1'), isTrue);

        final nodesInTree2 = await repository.getByRoot('root-2');
        expect(nodesInTree2.length, equals(1)); // just the root
      });

      test('should return empty list for non-existent root', () async {
        final nodes = await repository.getByRoot('non-existent-root');
        expect(nodes, isEmpty);
      });
    });

    group('Streaming', () {
      test('should stream single node updates', () async {
        final node = TestData.createRootNode(id: 'stream-test');
        await repository.addNode(node);

        final stream = repository.stream('stream-test');
        final updates = <Node>[];

        final subscription = stream.listen((updatedNode) {
          updates.add(updatedNode);
        });

        // Wait a bit for initial value
        await Future.delayed(Duration(milliseconds: 10));

        // Update the node
        await repository.update('stream-test', (current) {
          return current.copyWith(content: {'streamed': true});
        });

        // Wait for stream update
        await Future.delayed(Duration(milliseconds: 10));

        await subscription.cancel();

        expect(updates.length, greaterThan(0));
        expect(updates.last.content['streamed'], isTrue);
      });

      test('should stream query results', () async {
        final nodes = TestData.createSpatialNodes();

        final stream = repository.streamQuery(query: NodeSpatialQuery('abc'));
        final queryResults = <List<Node>>[];

        final subscription = stream.listen((results) {
          queryResults.add(results);
        });

        // Wait for initial empty result
        await Future.delayed(Duration(milliseconds: 10));

        // Add nodes that match the query
        for (final node
            in nodes.where((n) => n.spatialHash.startsWith('abc'))) {
          await repository.addNode(node);
          await Future.delayed(Duration(milliseconds: 10));
        }

        await subscription.cancel();

        expect(queryResults.length, greaterThan(0));
        expect(queryResults.last.length, equals(2)); // abc123 and abc456
      });
    });

    group('Auto-identification', () {
      test('should create identified object with auto-generated ID', () {
        final node = TestData.createRootNode();

        final identifiedObject = repository.autoIdentify(node);
        expect(identifiedObject.id, isNotEmpty);
        expect(identifiedObject.object.content, equals(node.content));
        expect(identifiedObject.object.spatialHash, equals(node.spatialHash));
      });
    });

    group('Repository Properties', () {
      test('should have correct path', () {
        expect(repository.path, equals('nodes'));
      });

      test('should dispose without errors', () {
        expect(() => repository.dispose(), returnsNormally);
      });
    });
  });
}
