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

      test('should create multiple child nodes with incrementing paths',
          () async {
        final rootCreate = TestData.createNodeCreate(
          content: {'name': 'Root'},
        );
        final root = await service.createNode(rootCreate);

        final child1Create = TestData.createNodeCreate(
          previous: root.validId,
          content: {'name': 'Child 1'},
        );
        final child1 = await service.createNode(child1Create);

        final child2Create = TestData.createNodeCreate(
          previous: root.validId,
          content: {'name': 'Child 2'},
        );
        final child2 = await service.createNode(child2Create);

        expect(child1.validPathHash, equals('1.1'));
        expect(child2.validPathHash, equals('1.2'));
      });

      test('should throw exception for invalid parent', () async {
        final nodeCreate = TestData.createNodeCreate(
          previous: 'non-existent-parent',
        );

        expect(
          () => service.createNode(nodeCreate),
          throwsA(isA<Exception>()),
        );
      });

      test('should validate created nodes', () async {
        final nodeCreate = TestData.createNodeCreate();
        final node = await service.createNode(nodeCreate);

        expect(node.validate, returnsNormally);
      });
    });

    group('Node Retrieval', () {
      test('should get node by ID', () async {
        final nodeCreate = TestData.createNodeCreate(
          content: {'test': 'data'},
        );
        final created = await service.createNode(nodeCreate);

        final retrieved = await service.getNode(created.validId);

        expect(retrieved.validId, equals(created.validId));
        expect(retrieved.contentMap['test'], equals('data'));
      });

      test('should throw exception for non-existent node', () async {
        expect(
          () => service.getNode('non-existent'),
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('Node Updates', () {
      test('should update node content', () async {
        final nodeCreate = TestData.createNodeCreate(
          content: {'original': 'data'},
        );
        final created = await service.createNode(nodeCreate);

        final nodeUpdate = TestData.createNodeUpdate(
          content: {'updated': 'content'},
        );

        final updated = await service.updateNode(created.validId, nodeUpdate);

        expect(updated.contentMap['updated'], equals('content'));
        expect(updated.contentMap['original'], isNull);
      });

      test('should update node pathHash', () async {
        final nodeCreate = TestData.createNodeCreate();
        final created = await service.createNode(nodeCreate);

        final nodeUpdate = TestData.createNodeUpdate(
          pathHash: 'new.path.hash',
        );

        final updated = await service.updateNode(created.validId, nodeUpdate);

        expect(updated.validPathHash, equals('new.path.hash'));
      });

      test('should preserve original values when not updated', () async {
        final nodeCreate = TestData.createNodeCreate(
          content: {'preserve': 'this'},
        );
        final created = await service.createNode(nodeCreate);

        final nodeUpdate = TestData.createNodeUpdate(
          pathHash: 'new.path',
        );

        final updated = await service.updateNode(created.validId, nodeUpdate);

        expect(updated.validPathHash, equals('new.path'));
        expect(updated.contentMap['preserve'], equals('this'));
      });
    });

    group('Node Deletion', () {
      test('should delete node without children', () async {
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
          throwsA(isA<RepositoryException>()),
        );
      });
    });

    group('Children Operations', () {
      test('should get children of a node', () async {
        final parentCreate = TestData.createNodeCreate(
          content: {'type': 'parent'},
        );
        final parent = await service.createNode(parentCreate);

        final child1Create = TestData.createNodeCreate(
          previous: parent.validId,
          content: {'type': 'child1'},
        );
        final child1 = await service.createNode(child1Create);

        final child2Create = TestData.createNodeCreate(
          previous: parent.validId,
          content: {'type': 'child2'},
        );
        final child2 = await service.createNode(child2Create);

        final children = await service.getChildren(parent.validId);

        expect(children.length, equals(2));
        expect(children.map((c) => c.validId),
            containsAll([child1.validId, child2.validId]));
      });

      test('should return empty list for node without children', () async {
        final nodeCreate = TestData.createNodeCreate();
        final node = await service.createNode(nodeCreate);

        final children = await service.getChildren(node.validId);

        expect(children, isEmpty);
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
