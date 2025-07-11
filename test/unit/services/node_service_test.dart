import 'package:kiss_graph/kiss_graph.dart';
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

    tearDown(() {
      service.dispose();
    });

    group('Node Creation', () {
      test('should create a root node', () async {
        final nodeCreate = TestData.createNodeCreate(
          content: {'name': 'Root Node'},
        );

        final createdNode = await service.createNode(nodeCreate);

        expect(createdNode.validId, isNotEmpty);
        expect(createdNode.validRoot, equals(createdNode.validId));
        expect(createdNode.previous, isNull);
        expect(createdNode.validPathHash, equals('1'));
        expect(createdNode.contentMap['name'], equals('Root Node'));
      });

      test('should create a child node with hierarchical path', () async {
        final parentCreate = TestData.createNodeCreate(
          content: {'name': 'Parent Node'},
        );
        final parent = await service.createNode(parentCreate);

        final childCreate = TestData.createNodeCreate(
          previous: parent.validId,
          content: {'name': 'Child Node'},
        );
        final child = await service.createNode(childCreate);

        expect(child.validId, isNotEmpty);
        expect(child.validRoot, equals(parent.validId));
        expect(child.previous, equals(parent.validId));
        expect(child.validPathHash, equals('1.1'));
        expect(child.contentMap['name'], equals('Child Node'));
      });

      test('should fail to create node with invalid parent', () async {
        final nodeCreate = TestData.createNodeCreate(
          previous: 'non-existent-parent',
          content: {'name': 'Orphan Node'},
        );

        expect(
          () => service.createNode(nodeCreate),
          throwsException,
        );
      });
    });

    group('Node Retrieval', () {
      test('should get node by ID', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        final retrieved = await service.getNode(created.validId);
        expect(retrieved.validId, equals(created.validId));
        expect(retrieved.contentMap, equals(created.contentMap));
      });

      test('should handle not found error', () async {
        expect(
          () => service.getNode('non-existent'),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('Node Updates', () {
      test('should update node pathHash', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        final nodeUpdate = TestData.createNodeUpdate(
          pathHash: 'updated-hash',
        );
        final updated = await service.updateNode(created.validId, nodeUpdate);

        expect(updated.validPathHash, equals('updated-hash'));
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
        expect(updated.validPathHash, equals(created.validPathHash));
      });

      test('should update both pathHash and content', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        final nodeUpdate = TestData.createNodeUpdate(
          pathHash: 'multi-update',
          content: {'multi': 'update'},
        );
        final updated = await service.updateNode(created.validId, nodeUpdate);

        expect(updated.validPathHash, equals('multi-update'));
        expect(updated.contentMap['multi'], equals('update'));
      });

      test('should handle not found error on update', () async {
        final nodeUpdate = TestData.createNodeUpdate(
          pathHash: 'will-not-work',
        );

        expect(
          () => service.updateNode('non-existent', nodeUpdate),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('Node Deletion', () {
      test('should delete a node without children', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        await service.deleteNode(created.validId);

        expect(
          () => service.getNode(created.validId),
          throwsA(isA<RepositoryException>()),
        );
      });

      test('should prevent deletion of node with children', () async {
        final parentCreate = TestData.createNodeCreate();
        final parent = await service.createNode(parentCreate);

        final childCreate = TestData.createNodeCreate(
          previous: parent.validId,
        );
        await service.createNode(childCreate);

        expect(
          () => service.deleteNode(parent.validId),
          throwsA(predicate((e) =>
              e.toString().contains('Cannot delete node with children'))),
        );
      });

      test('should handle deletion of non-existent node gracefully', () async {
        expect(
          () => service.deleteNode('non-existent'),
          returnsNormally,
        );
      });
    });

    group('Children Query', () {
      test('should get children of a node', () async {
        final parentCreate = TestData.createNodeCreate();
        final parent = await service.createNode(parentCreate);

        final child1Create = TestData.createNodeCreate(
          previous: parent.validId,
          content: {'name': 'Child 1'},
        );
        final child2Create = TestData.createNodeCreate(
          previous: parent.validId,
          content: {'name': 'Child 2'},
        );

        final child1 = await service.createNode(child1Create);
        final child2 = await service.createNode(child2Create);

        final children = await service.getChildren(parent.validId);
        expect(children.length, equals(2));

        final childIds = children.map((child) => child.validId).toList();
        expect(childIds, containsAll([child1.validId, child2.validId]));
      });

      test('should return empty list for node with no children', () async {
        final nodeCreate = TestData.createNodeCreate();
        final node = await service.createNode(nodeCreate);

        final children = await service.getChildren(node.validId);
        expect(children, isEmpty);
      });
    });

    group('Enhanced Operations', () {
      test('should update node with complex change validation', () async {
        final nodeCreate = TestData.createNodeCreate();
        final original = await service.createNode(nodeCreate);

        final updated = await repository.update(original.validId, (current) {
          return current.copyWith(previous: 'non-existent');
        });

        expect(updated.validId, equals(original.validId));
      });
    });

    group('Trace Operations', () {
      test('should trace deep chains efficiently', () async {
        // Create a long chain
        const chainLength = 10;
        final nodes = <Node>[];

        // Create root
        final rootCreate = TestData.createNodeCreate();
        final root = await service.createNode(rootCreate);
        nodes.add(root);

        // Create chain
        var current = root;
        for (var i = 1; i < chainLength; i++) {
          final childCreate =
              TestData.createNodeCreate(previous: current.validId);
          current = await service.createNode(childCreate);
          nodes.add(current);
        }

        // Trace from the end
        final trace = await service.trace(current.validId);
        expect(trace.length, equals(chainLength));

        // Verify order (should be reverse of creation)
        for (var i = 0; i < chainLength; i++) {
          expect(trace[i].validId, equals(nodes[chainLength - 1 - i].validId));
        }
      });
    });

    group('Path Queries', () {
      test('should get nodes by path prefix', () async {
        // Create nodes with different path hashes
        await service.createNode(TestData.createNodeCreate(pathHash: '1'));
        await service.createNode(TestData.createNodeCreate(pathHash: '1.1'));
        await service.createNode(TestData.createNodeCreate(pathHash: '2'));

        final pathNodes = await service.getPathNodes('1');
        expect(pathNodes.length, equals(2));

        final pathHashes = pathNodes.map((node) => node.validPathHash).toList();
        expect(pathHashes, containsAll(['1', '1.1']));
      });

      test('should return empty for non-matching prefix', () async {
        await service.createNode(TestData.createNodeCreate(pathHash: '2.1'));

        final nodes = await service.getPathNodes('1');
        expect(nodes, isEmpty);
      });
    });

    group('Breadcrumb Operations', () {
      test('should get breadcrumbs for nested nodes', () async {
        // Create a hierarchy: root -> child -> grandchild
        final rootCreate = TestData.createNodeCreate(
          content: {'name': 'Root'},
        );
        final root = await service.createNode(rootCreate);

        final childCreate = TestData.createNodeCreate(
          previous: root.validId,
          content: {'name': 'Child'},
        );
        final child = await service.createNode(childCreate);

        final grandchildCreate = TestData.createNodeCreate(
          previous: child.validId,
          content: {'name': 'Grandchild'},
        );
        final grandchild = await service.createNode(grandchildCreate);

        // Get breadcrumbs for grandchild
        final breadcrumbs = await service.getBreadcrumbs(grandchild.validId);

        // Should return all nodes in the path
        expect(breadcrumbs.length, equals(3));
        expect(breadcrumbs.map((n) => n.contentMap['name']).toList(),
            containsAll(['Root', 'Child', 'Grandchild']));
      });
    });

    group('Stress Testing', () {
      test('should handle many concurrent node creations', () async {
        const nodeCount = 50;
        final futures = <Future<Node>>[];

        for (var i = 0; i < nodeCount; i++) {
          final nodeCreate = TestData.createNodeCreate(content: {'index': i});
          futures.add(service.createNode(nodeCreate));
        }

        final nodes = await Future.wait(futures);
        expect(nodes.length, equals(nodeCount));

        // Verify all nodes are unique
        final ids = nodes.map((node) => node.validId).toSet();
        expect(ids.length, equals(nodeCount));
      });
    });
  });
}
