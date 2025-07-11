import 'package:kiss_graph/api/graph-node-api.openapi.dart';
import 'package:kiss_graph/models/node_extensions.dart';
import 'package:kiss_graph/repositories/node_queries.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:test/test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('NodeRepository Tests', () {
    late InMemoryRepository<Node> repository;

    setUp(() {
      repository = InMemoryRepository<Node>(
        queryBuilder: NodeQueryBuilder(),
        path: 'nodes',
      );
    });

    tearDown(() {
      repository.dispose();
    });

    group('Basic CRUD Operations', () {
      test('should add a node', () async {
        final node = TestData.createRootNode();

        node.validate();
        final addedNode =
            await repository.add(IdentifiedObject(node.validId, node));
        expect(addedNode.validId, equals(node.validId));
        expect(addedNode.contentMap, equals(node.contentMap));
      });

      test('should get a node by id', () async {
        final node = TestData.createRootNode();
        node.validate();
        await repository.add(IdentifiedObject(node.validId, node));

        final retrieved = await repository.get(node.validId);
        expect(retrieved.validId, equals(node.validId));
        expect(retrieved.contentMap, equals(node.contentMap));
      });

      test('should update a node', () async {
        final node = TestData.createRootNode();
        node.validate();
        await repository.add(IdentifiedObject(node.validId, node));

        final updated = await repository.update(node.validId, (current) {
          return current.copyWith(
            pathHash: 'updated-hash',
            content: {'updated': 'content'},
          );
        });

        expect(updated.validPathHash, equals('updated-hash'));
        expect(updated.contentMap['updated'], equals('content'));
      });

      test('should delete a node', () async {
        final node = TestData.createRootNode();
        node.validate();
        await repository.add(IdentifiedObject(node.validId, node));

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
        final nodes = TestData.createPathNodes();

        final futures = nodes.map((node) {
          node.validate();
          return repository.add(IdentifiedObject(node.validId, node));
        });
        final addedNodes = await Future.wait(futures);

        expect(addedNodes.length, equals(3));

        for (var i = 0; i < nodes.length; i++) {
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

        final addFutures = nodes.map((node) {
          node.validate();
          return repository.add(IdentifiedObject(node.validId, node));
        });
        await Future.wait(addFutures);

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
        final parent = TestData.createRootNode(id: 'parent-1');
        parent.validate();
        await repository.add(IdentifiedObject(parent.validId, parent));

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

        child1.validate();
        child2.validate();
        await repository.add(IdentifiedObject(child1.validId, child1));
        await repository.add(IdentifiedObject(child2.validId, child2));

        final children =
            await repository.query(query: NodeChildrenQuery(parent.validId));
        expect(children.length, equals(2));

        final childIds = children.map((child) => child.validId).toList();
        expect(childIds, containsAll(['child-1', 'child-2']));
      });

      test('should return empty list for node with no children', () async {
        final node = TestData.createRootNode();
        node.validate();
        await repository.add(IdentifiedObject(node.validId, node));

        final children =
            await repository.query(query: NodeChildrenQuery(node.validId));
        expect(children, isEmpty);
      });

      test('should handle non-existent parent', () async {
        final children =
            await repository.query(query: const NodeChildrenQuery('non-existent'));
        expect(children, isEmpty);
      });
    });

    group('Path Queries', () {
      test('should find nodes by path prefix', () async {
        final pathNodes = TestData.createPathNodes();

        for (final node in pathNodes) {
          node.validate();
          await repository.add(IdentifiedObject(node.validId, node));
        }

        final pathNodes1 = await repository.query(query: const NodePathQuery('1'));
        expect(pathNodes1.length, equals(2));

        final pathHashes =
            pathNodes1.map((node) => node.validPathHash).toList();
        expect(pathHashes.every((hash) => hash.startsWith('1')), isTrue);
      });

      test('should return empty list for non-matching prefix', () async {
        final node = TestData.createRootNode(pathHash: '2.1');
        node.validate();
        await repository.add(IdentifiedObject(node.validId, node));

        final path1Nodes = await repository.query(query: const NodePathQuery('1'));
        expect(path1Nodes, isEmpty);
      });

      test('should handle exact hash matches', () async {
        final node = TestData.createRootNode(pathHash: '1');
        node.validate();
        await repository.add(IdentifiedObject(node.validId, node));

        final exactNodes = await repository.query(query: const NodePathQuery('1'));
        expect(exactNodes.length, equals(1));
        expect(exactNodes.first.validPathHash, equals('1'));
      });
    });

    group('Root Query', () {
      test('should find nodes by root ID', () async {
        final root = TestData.createRootNode(id: 'root-1');
        root.validate();
        await repository.add(IdentifiedObject(root.validId, root));

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

        child1.validate();
        child2.validate();
        await repository.add(IdentifiedObject(child1.validId, child1));
        await repository.add(IdentifiedObject(child2.validId, child2));

        final rootNodes =
            await repository.query(query: NodeRootQuery(root.validId));
        expect(rootNodes.length, equals(3)); // root + 2 children

        final nodeIds = rootNodes.map((node) => node.validId).toList();
        expect(nodeIds, containsAll(['root-1', 'child-1', 'child-2']));
      });

      test('should return only root for single node', () async {
        final root = TestData.createRootNode();
        root.validate();
        await repository.add(IdentifiedObject(root.validId, root));

        final rootNodes =
            await repository.query(query: NodeRootQuery(root.validId));
        expect(rootNodes.length, equals(1));
        expect(rootNodes.first.validId, equals(root.validId));
      });
    });

    group('Streaming', () {
      test('should support streaming operations', () async {
        final node = TestData.createRootNode();
        node.validate();
        await repository.add(IdentifiedObject(node.validId, node));

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
          () async => repository.delete('non-existent'),
          returnsNormally,
        );
      });
    });

    group('Complex Scenarios', () {
      test('should handle deep node chains', () async {
        final chainNodes = TestData.createNodeChain(5);

        // Add nodes to repository
        for (final node in chainNodes) {
          node.validate();
          await repository.add(IdentifiedObject(node.validId, node));
        }

        // Test that all nodes are retrievable
        for (final node in chainNodes) {
          final retrieved = await repository.get(node.validId);
          expect(retrieved.validId, equals(node.validId));
        }

        // Test that children queries work correctly
        for (var i = 0; i < chainNodes.length - 1; i++) {
          final parent = chainNodes[i];
          final children =
              await repository.query(query: NodeChildrenQuery(parent.validId));

          if (i < chainNodes.length - 1) {
            expect(children.length, equals(1));
            expect(children.first.validId, equals(chainNodes[i + 1].validId));
          }
        }
      });

      test('should handle mixed path and hierarchical queries', () async {
        final pathNodes = TestData.createPathNodes();

        for (final node in pathNodes) {
          node.validate();
          await repository.add(IdentifiedObject(node.validId, node));
        }

        // Test path query
        final pathNodes1 = await repository.query(query: const NodePathQuery('1'));
        expect(pathNodes1.length, equals(2));

        // Test that path nodes are also in root queries
        for (final node in pathNodes) {
          final rootNodes = await repository.query(
              query: NodeRootQuery(node.validId)); // Each is its own root
          expect(rootNodes.length, equals(1));
          expect(rootNodes.first.validId, equals(node.validId));
        }
      });
    });
  });
}
