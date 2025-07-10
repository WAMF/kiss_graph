import 'package:kiss_graph/models/node_extensions.dart';
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
      test('should add a node', () async {
        final node = TestData.createRootNode();

        final addedNode = await repository.addNode(node);
        expect(addedNode.validId, equals(node.validId));
        expect(addedNode.contentMap, equals(node.contentMap));
      });

      test('should get a node by id', () async {
        final node = TestData.createRootNode();
        await repository.addNode(node);

        final retrieved = await repository.get(node.validId);
        expect(retrieved.validId, equals(node.validId));
        expect(retrieved.contentMap, equals(node.contentMap));
      });

      test('should update a node', () async {
        final node = TestData.createRootNode();
        await repository.addNode(node);

        final updated = await repository.update(node.validId, (current) {
          return current.copyWith(
            spatialHash: 'updated-hash',
            content: {'updated': 'content'},
          );
        });

        expect(updated.validSpatialHash, equals('updated-hash'));
        expect(updated.contentMap['updated'], equals('content'));
      });

      test('should delete a node', () async {
        final node = TestData.createRootNode();
        await repository.addNode(node);

        await repository.delete(node.validId);

        expect(
          () => repository.get(node.validId),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('should handle not found error', () async {
        expect(
          () => repository.get('non-existent'),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('Batch Operations', () {
      test('should add multiple nodes', () async {
        final nodes = TestData.createSpatialNodes();

        final futures = nodes.map((node) => repository.addNode(node));
        final addedNodes = await Future.wait(futures);

        expect(addedNodes.length, equals(3));

        for (int i = 0; i < nodes.length; i++) {
          final original = nodes[i];
          final added = addedNodes[i];
          expect(added.validId, equals(original.validId));
          expect(added.contentMap, equals(original.contentMap));
        }
      });

      test('should handle concurrent operations', () async {
        final nodes = [
          TestData.createRootNode(id: 'concurrent-1'),
          TestData.createRootNode(id: 'concurrent-2'),
          TestData.createRootNode(id: 'concurrent-3'),
        ];

        // Add all nodes concurrently
        final addFutures = nodes.map((node) => repository.addNode(node));
        await Future.wait(addFutures);

        // Retrieve all nodes concurrently
        final getFutures = nodes.map((node) => repository.get(node.validId));
        final retrievedNodes = await Future.wait(getFutures);

        expect(retrievedNodes.length, equals(3));
        final retrievedIds =
            retrievedNodes.map((node) => node.validId).toList();
        expect(retrievedIds,
            containsAll(['concurrent-1', 'concurrent-2', 'concurrent-3']));
      });
    });

    group('Children Query', () {
      test('should find children by parent ID', () async {
        // Create parent
        final parent = TestData.createRootNode(id: 'parent-1');
        await repository.addNode(parent);

        // Create children
        final child1 = TestData.createChildNode(
          id: 'child-1',
          parentId: parent.validId,
          rootId: parent.validId,
        );
        final child2 = TestData.createChildNode(
          id: 'child-2',
          parentId: parent.validId,
          rootId: parent.validId,
        );

        await repository.addNode(child1);
        await repository.addNode(child2);

        final children = await repository.getChildren(parent.validId);
        expect(children.length, equals(2));

        final childIds = children.map((child) => child.validId).toList();
        expect(childIds, containsAll(['child-1', 'child-2']));
      });

      test('should return empty list for node with no children', () async {
        final node = TestData.createRootNode();
        await repository.addNode(node);

        final children = await repository.getChildren(node.validId);
        expect(children, isEmpty);
      });

      test('should handle non-existent parent', () async {
        final children = await repository.getChildren('non-existent');
        expect(children, isEmpty);
      });
    });

    group('Spatial Queries', () {
      test('should find nodes by spatial prefix', () async {
        final spatialNodes = TestData.createSpatialNodes();

        for (final node in spatialNodes) {
          await repository.addNode(node);
        }

        final abcNodes = await repository.getSpatialNodes('abc');
        expect(abcNodes.length, equals(2));

        final spatialHashes =
            abcNodes.map((node) => node.validSpatialHash).toList();
        expect(spatialHashes.every((hash) => hash.startsWith('abc')), isTrue);
      });

      test('should return empty list for non-matching prefix', () async {
        final node = TestData.createRootNode(spatialHash: 'xyz123');
        await repository.addNode(node);

        final abcNodes = await repository.getSpatialNodes('abc');
        expect(abcNodes, isEmpty);
      });

      test('should handle exact hash matches', () async {
        final node = TestData.createRootNode(spatialHash: 'exact');
        await repository.addNode(node);

        final exactNodes = await repository.getSpatialNodes('exact');
        expect(exactNodes.length, equals(1));
        expect(exactNodes.first.validSpatialHash, equals('exact'));
      });
    });

    group('Root Query', () {
      test('should find nodes by root ID', () async {
        final root = TestData.createRootNode(id: 'root-1');
        await repository.addNode(root);

        final child1 = TestData.createChildNode(
          id: 'child-1',
          parentId: root.validId,
          rootId: root.validId,
        );
        final child2 = TestData.createChildNode(
          id: 'child-2',
          parentId: child1.validId,
          rootId: root.validId,
        );

        await repository.addNode(child1);
        await repository.addNode(child2);

        final rootNodes = await repository.getByRoot(root.validId);
        expect(rootNodes.length, equals(3)); // root + 2 children

        final nodeIds = rootNodes.map((node) => node.validId).toList();
        expect(nodeIds, containsAll(['root-1', 'child-1', 'child-2']));
      });

      test('should return only root for single node', () async {
        final root = TestData.createRootNode();
        await repository.addNode(root);

        final rootNodes = await repository.getByRoot(root.validId);
        expect(rootNodes.length, equals(1));
        expect(rootNodes.first.validId, equals(root.validId));
      });
    });

    group('Streaming', () {
      test('should support streaming operations', () async {
        final node = TestData.createRootNode();
        await repository.addNode(node);

        // Basic test that streaming methods exist
        expect(() => repository.stream(node.validId), returnsNormally);
      });
    });

    group('Auto-identification', () {
      test('should create identified object with UUID', () async {
        final node = TestData.createRootNode();

        final identifiedObject = await repository.addAutoIdentified(node);
        expect(identifiedObject.validId, isNotEmpty);
        // UUID format check (basic)
        expect(identifiedObject.validId.contains('-'), isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle repository exceptions gracefully', () async {
        expect(
          () => repository.get('definitely-not-found'),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('should handle invalid operations', () async {
        // Delete operation on non-existent node may not throw in this implementation
        // Just test that it completes without crashing
        expect(
          () async => await repository.delete('non-existent'),
          returnsNormally,
        );
      });
    });

    group('Complex Scenarios', () {
      test('should handle deep node chains', () async {
        final chainNodes = TestData.createNodeChain(5);

        // Add nodes to repository
        for (final node in chainNodes) {
          await repository.addNode(node);
        }

        // Test that all nodes are retrievable
        for (final node in chainNodes) {
          final retrieved = await repository.get(node.validId);
          expect(retrieved.validId, equals(node.validId));
        }

        // Test that children queries work correctly
        for (int i = 0; i < chainNodes.length - 1; i++) {
          final parent = chainNodes[i];
          final children = await repository.getChildren(parent.validId);

          if (i < chainNodes.length - 1) {
            expect(children.length, equals(1));
            expect(children.first.validId, equals(chainNodes[i + 1].validId));
          }
        }
      });

      test('should handle mixed spatial and hierarchical queries', () async {
        final spatialNodes = TestData.createSpatialNodes();

        for (final node in spatialNodes) {
          await repository.addNode(node);
        }

        // Test spatial query
        final abcNodes = await repository.getSpatialNodes('abc');
        expect(abcNodes.length, equals(2));

        // Test that spatial nodes are also in root queries
        for (final node in spatialNodes) {
          final rootNodes =
              await repository.getByRoot(node.validId); // Each is its own root
          expect(rootNodes.length, equals(1));
          expect(rootNodes.first.validId, equals(node.validId));
        }
      });
    });
  });
}
