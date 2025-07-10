import 'package:kiss_graph/repositories/node_repository.dart';
import 'package:kiss_graph/services/node_service.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:test/test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('NodeService Tests', () {
    late NodeService service;
    late NodeRepository repository;

    setUp(() {
      repository = NodeRepository();
      service = NodeService(repository);
    });

    tearDown(() {
      repository.dispose();
      service.dispose();
    });

    group('Node Creation', () {
      test('should create root node successfully', () async {
        final nodeCreate = TestData.createNodeCreate(
          previous: null,
          spatialHash: 'root123',
          content: {'type': 'root', 'name': 'Test Root'},
        );

        final createdNode = await service.createNode(nodeCreate);

        expect(createdNode.id, isNotEmpty);
        expect(
            createdNode.root, equals(createdNode.id)); // Root points to itself
        expect(createdNode.previous, isNull);
        expect(createdNode.spatialHash, equals('root123'));
        expect(
            createdNode.content, equals({'type': 'root', 'name': 'Test Root'}));
      });

      test('should create child node with valid parent', () async {
        // First create a parent node
        final parentCreate = TestData.createNodeCreate(
          previous: null,
          spatialHash: 'parent123',
          content: {'type': 'parent'},
        );
        final parentNode = await service.createNode(parentCreate);

        // Then create child node
        final childCreate = TestData.createNodeCreate(
          previous: parentNode.id,
          spatialHash: 'child123',
          content: {'type': 'child'},
        );
        final childNode = await service.createNode(childCreate);

        expect(childNode.id, isNotEmpty);
        expect(childNode.root,
            equals(parentNode.root)); // Inherits root from parent
        expect(childNode.previous, equals(parentNode.id));
        expect(childNode.spatialHash, equals('child123'));
      });

      test('should generate unique IDs for multiple nodes', () async {
        final nodeCreate = TestData.createNodeCreate();

        final node1 = await service.createNode(nodeCreate);
        final node2 = await service.createNode(nodeCreate);

        expect(node1.id, isNot(equals(node2.id)));
      });

      test('should throw exception when parent node not found', () async {
        final nodeCreate = TestData.createNodeCreate(
          previous: 'non-existent-parent',
          spatialHash: 'orphan123',
          content: {'type': 'orphan'},
        );

        expect(
          () => service.createNode(nodeCreate),
          throwsA(isA<Exception>()),
        );
      });

      test('should inherit root from grandparent in chain', () async {
        // Create grandparent (root)
        final grandparent = await service.createNode(TestData.createNodeCreate(
          previous: null,
          content: {'generation': 'grandparent'},
        ));

        // Create parent
        final parent = await service.createNode(TestData.createNodeCreate(
          previous: grandparent.id,
          content: {'generation': 'parent'},
        ));

        // Create child
        final child = await service.createNode(TestData.createNodeCreate(
          previous: parent.id,
          content: {'generation': 'child'},
        ));

        expect(child.root, equals(grandparent.id));
        expect(parent.root, equals(grandparent.id));
        expect(grandparent.root, equals(grandparent.id));
      });
    });

    group('Node Retrieval', () {
      test('should get existing node', () async {
        final nodeCreate = TestData.createNodeCreate();
        final createdNode = await service.createNode(nodeCreate);

        final retrievedNode = await service.getNode(createdNode.id);

        expect(retrievedNode.id, equals(createdNode.id));
        expect(retrievedNode.content, equals(createdNode.content));
      });

      test('should throw RepositoryException for non-existent node', () async {
        expect(
          () => service.getNode('non-existent'),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('Node Updates', () {
      test('should update node spatialHash', () async {
        final nodeCreate = TestData.createNodeCreate();
        final createdNode = await service.createNode(nodeCreate);

        final nodeUpdate = TestData.createNodeUpdate(
          spatialHash: 'updated-hash',
          content: null,
        );

        final updatedNode =
            await service.updateNode(createdNode.id, nodeUpdate);

        expect(updatedNode.spatialHash, equals('updated-hash'));
        expect(updatedNode.content, equals(createdNode.content)); // Unchanged
        expect(updatedNode.id, equals(createdNode.id)); // Unchanged
      });

      test('should update node content', () async {
        final nodeCreate = TestData.createNodeCreate();
        final createdNode = await service.createNode(nodeCreate);

        final nodeUpdate = TestData.createNodeUpdate(
          spatialHash: null,
          content: {'updated': true, 'new': 'value'},
        );

        final updatedNode =
            await service.updateNode(createdNode.id, nodeUpdate);

        expect(updatedNode.content, equals({'updated': true, 'new': 'value'}));
        expect(updatedNode.spatialHash,
            equals(createdNode.spatialHash)); // Unchanged
      });

      test('should update both spatialHash and content', () async {
        final nodeCreate = TestData.createNodeCreate();
        final createdNode = await service.createNode(nodeCreate);

        final nodeUpdate = TestData.createNodeUpdate(
          spatialHash: 'both-updated',
          content: {'both': 'updated'},
        );

        final updatedNode =
            await service.updateNode(createdNode.id, nodeUpdate);

        expect(updatedNode.spatialHash, equals('both-updated'));
        expect(updatedNode.content, equals({'both': 'updated'}));
      });

      test('should handle null updates (no changes)', () async {
        final nodeCreate = TestData.createNodeCreate();
        final createdNode = await service.createNode(nodeCreate);

        final nodeUpdate = TestData.createNodeUpdate(
          spatialHash: null,
          content: null,
        );

        final updatedNode =
            await service.updateNode(createdNode.id, nodeUpdate);

        expect(updatedNode.spatialHash, equals(createdNode.spatialHash));
        expect(updatedNode.content, equals(createdNode.content));
      });
    });

    group('Node Deletion', () {
      test('should delete leaf node (no children)', () async {
        final nodeCreate = TestData.createNodeCreate();
        final createdNode = await service.createNode(nodeCreate);

        await service.deleteNode(createdNode.id);

        expect(
          () => service.getNode(createdNode.id),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('should prevent deletion of node with children', () async {
        // Create parent
        final parentCreate = TestData.createNodeCreate();
        final parentNode = await service.createNode(parentCreate);

        // Create child
        final childCreate = TestData.createNodeCreate(previous: parentNode.id);
        await service.createNode(childCreate);

        // Try to delete parent - should fail
        expect(
          () => service.deleteNode(parentNode.id),
          throwsA(isA<RepositoryException>()),
        );

        // Parent should still exist
        final stillExists = await service.getNode(parentNode.id);
        expect(stillExists.id, equals(parentNode.id));
      });

      test('should allow deletion after children are removed', () async {
        // Create parent
        final parentCreate = TestData.createNodeCreate();
        final parentNode = await service.createNode(parentCreate);

        // Create child
        final childCreate = TestData.createNodeCreate(previous: parentNode.id);
        final childNode = await service.createNode(childCreate);

        // Delete child first
        await service.deleteNode(childNode.id);

        // Now parent can be deleted
        await service.deleteNode(parentNode.id);

        expect(
          () => service.getNode(parentNode.id),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('Children Queries', () {
      test('should get children of a node', () async {
        final parentCreate = TestData.createNodeCreate();
        final parentNode = await service.createNode(parentCreate);

        final child1Create = TestData.createNodeCreate(previous: parentNode.id);
        final child2Create = TestData.createNodeCreate(previous: parentNode.id);

        final child1 = await service.createNode(child1Create);
        final child2 = await service.createNode(child2Create);

        final children = await service.getChildren(parentNode.id);

        expect(children.length, equals(2));
        expect(children.map((c) => c.id), containsAll([child1.id, child2.id]));
      });

      test('should return empty list for childless node', () async {
        final nodeCreate = TestData.createNodeCreate();
        final node = await service.createNode(nodeCreate);

        final children = await service.getChildren(node.id);

        expect(children, isEmpty);
      });
    });

    group('Trace Functionality', () {
      test('should trace single node (root)', () async {
        final rootCreate = TestData.createNodeCreate();
        final rootNode = await service.createNode(rootCreate);

        final trace = await service.trace(rootNode.id);

        expect(trace.length, equals(1));
        expect(trace.first.id, equals(rootNode.id));
      });

      test('should trace node chain to root', () async {
        // Create chain: root -> child1 -> child2 -> child3
        final rootNode = await service.createNode(TestData.createNodeCreate(
          content: {'position': 'root'},
        ));

        final child1 = await service.createNode(TestData.createNodeCreate(
          previous: rootNode.id,
          content: {'position': 'child1'},
        ));

        final child2 = await service.createNode(TestData.createNodeCreate(
          previous: child1.id,
          content: {'position': 'child2'},
        ));

        final child3 = await service.createNode(TestData.createNodeCreate(
          previous: child2.id,
          content: {'position': 'child3'},
        ));

        final trace = await service.trace(child3.id);

        expect(trace.length, equals(4));
        expect(trace[0].id, equals(child3.id)); // Start from child3
        expect(trace[1].id, equals(child2.id));
        expect(trace[2].id, equals(child1.id));
        expect(trace[3].id, equals(rootNode.id)); // End at root
      });

      test('should handle broken chain gracefully', () async {
        final rootNode = await service.createNode(TestData.createNodeCreate());
        final childNode = await service.createNode(TestData.createNodeCreate(
          previous: rootNode.id,
        ));

        // Delete the root node to break the chain
        await repository.delete(rootNode.id);

        final trace = await service.trace(childNode.id);

        expect(trace.length,
            equals(1)); // Should stop at child when root is missing
        expect(trace.first.id, equals(childNode.id));
      });

      test('should handle trace from non-existent node', () async {
        final trace = await service.trace('non-existent');

        expect(trace, isEmpty);
      });
    });

    group('Spatial Queries', () {
      test('should get nodes by spatial prefix', () async {
        final node1 = await service.createNode(TestData.createNodeCreate(
          spatialHash: 'abc123',
        ));
        final node2 = await service.createNode(TestData.createNodeCreate(
          spatialHash: 'abc456',
        ));
        final node3 = await service.createNode(TestData.createNodeCreate(
          spatialHash: 'def789',
        ));

        final abcNodes = await service.getSpatialNodes('abc');

        expect(abcNodes.length, equals(2));
        expect(abcNodes.map((n) => n.id), containsAll([node1.id, node2.id]));
        expect(abcNodes.map((n) => n.id), isNot(contains(node3.id)));
      });

      test('should return empty list for non-matching prefix', () async {
        await service
            .createNode(TestData.createNodeCreate(spatialHash: 'abc123'));

        final nodes = await service.getSpatialNodes('xyz');

        expect(nodes, isEmpty);
      });
    });

    group('Root Queries', () {
      test('should get all nodes in a tree by root', () async {
        final rootNode = await service.createNode(TestData.createNodeCreate());
        final child1 = await service.createNode(TestData.createNodeCreate(
          previous: rootNode.id,
        ));
        final child2 = await service.createNode(TestData.createNodeCreate(
          previous: child1.id,
        ));

        // Create another tree
        final otherRoot = await service.createNode(TestData.createNodeCreate());

        final nodesInTree = await service.getNodesByRoot(rootNode.id);

        expect(nodesInTree.length, equals(3));
        expect(
            nodesInTree.map((n) => n.id),
            containsAll([
              rootNode.id,
              child1.id,
              child2.id,
            ]));
        expect(nodesInTree.map((n) => n.id), isNot(contains(otherRoot.id)));
      });
    });

    group('Get All Nodes', () {
      test('should get all nodes in repository', () async {
        final node1 = await service.createNode(TestData.createNodeCreate());
        final node2 = await service.createNode(TestData.createNodeCreate());
        final node3 = await service.createNode(TestData.createNodeCreate());

        final allNodes = await service.getAllNodes();

        expect(allNodes.length, equals(3));
        expect(
            allNodes.map((n) => n.id),
            containsAll([
              node1.id,
              node2.id,
              node3.id,
            ]));
      });

      test('should return empty list when no nodes exist', () async {
        final allNodes = await service.getAllNodes();

        expect(allNodes, isEmpty);
      });
    });

    group('Service Lifecycle', () {
      test('should dispose without errors', () {
        expect(() => service.dispose(), returnsNormally);
      });
    });
  });
}
