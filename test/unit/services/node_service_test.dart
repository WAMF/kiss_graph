import 'package:kiss_graph/graph-node-api.openapi.dart';
import 'package:kiss_graph/models/node_extensions.dart';
import 'package:kiss_graph/repositories/node_queries.dart';
import 'package:kiss_graph/services/node_service.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:test/test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('NodeService Tests', () {
    late Repository<Node> repository;
    late NodeService service;

    setUp(() {
      repository = InMemoryRepository<Node>(
        queryBuilder: NodeQueryBuilder(),
        path: 'nodes',
      );
      service = NodeService(repository);
    });

    tearDown(() async {
      // Ensure all async operations complete before disposal
      await Future.delayed(Duration(milliseconds: 10));
      repository.dispose();
    });

    group('Node Creation', () {
      test('should create a root node', () async {
        final nodeCreate = TestData.createNodeCreate(
          previous: null,
          spatialHash: 'root123',
          content: {'type': 'root'},
        );

        final createdNode = await service.createNode(nodeCreate);

        expect(createdNode.validId, isNotEmpty);
        expect(createdNode.validRoot,
            equals(createdNode.validId)); // Root node's root is itself
        expect(createdNode.previous, isNull);
        expect(createdNode.validSpatialHash, equals('root123'));
        expect(createdNode.contentMap['type'], equals('root'));
      });

      test('should create a child node with parent reference', () async {
        // Create parent first
        final parentCreate = TestData.createNodeCreate(
          previous: null,
          spatialHash: 'parent123',
          content: {'type': 'parent'},
        );
        final parent = await service.createNode(parentCreate);

        // Create child
        final childCreate = TestData.createNodeCreate(
          previous: parent.validId,
          spatialHash: 'child123',
          content: {'type': 'child'},
        );
        final child = await service.createNode(childCreate);

        expect(child.validId, isNotEmpty);
        expect(child.previous, equals(parent.validId));
        expect(
            child.validRoot, equals(parent.validRoot)); // Should inherit root
        expect(child.validSpatialHash, equals('child123'));
        expect(child.contentMap['type'], equals('child'));
      });

      test('should throw exception for invalid parent', () async {
        final nodeCreate = TestData.createNodeCreate(
          previous: 'non-existent-parent',
          spatialHash: 'invalid123',
          content: {'type': 'invalid'},
        );

        expect(
          () => service.createNode(nodeCreate),
          throwsA(
              predicate((e) => e.toString().contains('Parent node not found'))),
        );
      });

      test('should auto-generate unique IDs', () async {
        final nodeCreate1 = TestData.createNodeCreate();
        final nodeCreate2 = TestData.createNodeCreate();

        final node1 = await service.createNode(nodeCreate1);
        final node2 = await service.createNode(nodeCreate2);

        expect(node1.validId, isNot(equals(node2.validId)));
        expect(node1.validId, isNotEmpty);
        expect(node2.validId, isNotEmpty);
      });
    });

    group('Node Retrieval', () {
      test('should get existing node', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        final retrieved = await service.getNode(created.validId);
        expect(retrieved.validId, equals(created.validId));
        expect(retrieved.contentMap, equals(created.contentMap));
      });

      test('should throw exception for non-existent node', () async {
        expect(
          () => service.getNode('non-existent'),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('Node Updates', () {
      test('should update node spatialHash', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        final nodeUpdate = TestData.createNodeUpdate(
          spatialHash: 'updated-hash',
        );
        final updated = await service.updateNode(created.validId, nodeUpdate);

        expect(updated.validSpatialHash, equals('updated-hash'));
        expect(updated.validId, equals(created.validId));
        expect(updated.contentMap, equals(created.contentMap));
      });

      test('should update node content', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        final nodeUpdate = TestData.createNodeUpdate(
          content: {'updated': 'content', 'new': 'field'},
        );
        final updated = await service.updateNode(created.validId, nodeUpdate);

        expect(updated.contentMap['updated'], equals('content'));
        expect(updated.contentMap['new'], equals('field'));
        expect(updated.validId, equals(created.validId));
        expect(updated.validSpatialHash, equals(created.validSpatialHash));
      });

      test('should update both spatialHash and content', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        final nodeUpdate = TestData.createNodeUpdate(
          spatialHash: 'multi-update',
          content: {'multi': 'update'},
        );
        final updated = await service.updateNode(created.validId, nodeUpdate);

        expect(updated.validSpatialHash, equals('multi-update'));
        expect(updated.contentMap['multi'], equals('update'));
      });

      test('should throw exception for non-existent node update', () async {
        final nodeUpdate = TestData.createNodeUpdate();

        expect(
          () => service.updateNode('non-existent', nodeUpdate),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('Node Deletion', () {
      test('should delete childless node', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        await service.deleteNode(created.validId);

        expect(
          () => service.getNode(created.validId),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('should prevent deletion of node with children', () async {
        // Create parent
        final parentCreate = TestData.createNodeCreate();
        final parent = await service.createNode(parentCreate);

        // Create child
        final childCreate = TestData.createNodeCreate(previous: parent.validId);
        await service.createNode(childCreate);

        // Try to delete parent - should fail
        expect(
          () => service.deleteNode(parent.validId),
          throwsA(predicate((e) =>
              e.toString().contains('Cannot delete node with children'))),
        );
      });

      test('should allow deletion after children are removed', () async {
        // Create parent and child
        final parentCreate = TestData.createNodeCreate();
        final parent = await service.createNode(parentCreate);

        final childCreate = TestData.createNodeCreate(previous: parent.validId);
        final child = await service.createNode(childCreate);

        // Delete child first
        await service.deleteNode(child.validId);

        // Now parent can be deleted
        expect(() => service.deleteNode(parent.validId), returnsNormally);
      });
    });

    group('Children Queries', () {
      test('should get children of node', () async {
        // Create parent
        final parentCreate = TestData.createNodeCreate();
        final parent = await service.createNode(parentCreate);

        // Create children
        final child1Create =
            TestData.createNodeCreate(previous: parent.validId);
        final child2Create =
            TestData.createNodeCreate(previous: parent.validId);

        final child1 = await service.createNode(child1Create);
        final child2 = await service.createNode(child2Create);

        final children = await service.getChildren(parent.validId);
        expect(children.length, equals(2));

        final childIds = children.map((child) => child.validId).toSet();
        expect(childIds, containsAll([child1.validId, child2.validId]));
      });

      test('should return empty list for childless node', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        final children = await service.getChildren(created.validId);
        expect(children, isEmpty);
      });
    });

    group('Trace Functionality', () {
      test('should trace single node to itself', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        final trace = await service.trace(created.validId);
        expect(trace.length, equals(1));
        expect(trace.first.validId, equals(created.validId));
      });

      test('should trace child back to root', () async {
        // Create chain: root -> child1 -> child2
        final rootCreate = TestData.createNodeCreate();
        final root = await service.createNode(rootCreate);

        final child1Create = TestData.createNodeCreate(previous: root.validId);
        final child1 = await service.createNode(child1Create);

        final child2Create =
            TestData.createNodeCreate(previous: child1.validId);
        final child2 = await service.createNode(child2Create);

        final trace = await service.trace(child2.validId);
        expect(trace.length, equals(3));
        expect(trace[0].validId, equals(child2.validId)); // Start from child2
        expect(trace[1].validId, equals(child1.validId)); // Then child1
        expect(trace[2].validId, equals(root.validId)); // End at root
      });

      test('should handle broken chain gracefully', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        // Manually create a reference to non-existent parent
        await repository.update(created.validId, (current) {
          return current.copyWith(previous: 'non-existent');
        });

        final trace = await service.trace(created.validId);
        expect(trace.length,
            equals(1)); // Should stop at the node with broken reference
        expect(trace.first.validId, equals(created.validId));
      });

      test('should trace deep chains efficiently', () async {
        // Create a long chain
        const chainLength = 10;
        final nodes = <Node>[];

        // Create root
        final rootCreate = TestData.createNodeCreate();
        final root = await service.createNode(rootCreate);
        nodes.add(root);

        // Create chain
        Node current = root;
        for (int i = 1; i < chainLength; i++) {
          final childCreate =
              TestData.createNodeCreate(previous: current.validId);
          current = await service.createNode(childCreate);
          nodes.add(current);
        }

        // Trace from the end
        final trace = await service.trace(current.validId);
        expect(trace.length, equals(chainLength));

        // Verify order (should be reverse of creation)
        for (int i = 0; i < chainLength; i++) {
          expect(trace[i].validId, equals(nodes[chainLength - 1 - i].validId));
        }
      });
    });

    group('Spatial Queries', () {
      test('should get nodes by spatial prefix', () async {
        // Create nodes with different spatial hashes

        await service
            .createNode(TestData.createNodeCreate(spatialHash: 'abc123'));
        await service
            .createNode(TestData.createNodeCreate(spatialHash: 'abc456'));
        await service
            .createNode(TestData.createNodeCreate(spatialHash: 'def789'));

        final abcNodes = await service.getSpatialNodes('abc');
        expect(abcNodes.length, equals(2));

        final spatialHashes =
            abcNodes.map((node) => node.validSpatialHash).toList();
        expect(spatialHashes, containsAll(['abc123', 'abc456']));
      });

      test('should return empty for non-matching prefix', () async {
        await service
            .createNode(TestData.createNodeCreate(spatialHash: 'xyz123'));

        final nodes = await service.getSpatialNodes('abc');
        expect(nodes, isEmpty);
      });
    });

    group('Service Lifecycle', () {
      test('should dispose without errors', () {
        expect(() => service.dispose(), returnsNormally);
      });

      test('should handle multiple operations concurrently', () async {
        final futures = List.generate(
            5,
            (i) => service.createNode(TestData.createNodeCreate(
                spatialHash: 'concurrent-$i', content: {'index': i})));

        final nodes = await Future.wait(futures);
        expect(nodes.length, equals(5));

        // Verify all nodes were created with unique IDs
        final ids = nodes.map((node) => node.validId).toSet();
        expect(ids.length, equals(5)); // All unique
      });
    });
  });
}
