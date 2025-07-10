import 'package:kiss_graph/models/node.dart';
import 'package:test/test.dart';

import '../../helpers/test_helpers.dart';

void main() {
  group('Node Model Tests', () {
    late Node testNode;
    late Map<String, dynamic> testJson;

    setUp(() {
      testNode = TestData.createRootNode();
      testJson = {
        'id': 'test-id',
        'root': 'test-root',
        'previous': null,
        'spatialHash': 'test-hash',
        'content': {'key': 'value'}
      };
    });

    group('Node Creation', () {
      test('should create node with all required fields', () {
        final node = Node(
          id: 'test-id',
          root: 'test-root',
          previous: null,
          spatialHash: 'test-hash',
          content: {'data': 'test'},
        );

        expect(node.id, equals('test-id'));
        expect(node.root, equals('test-root'));
        expect(node.previous, isNull);
        expect(node.spatialHash, equals('test-hash'));
        expect(node.content, equals({'data': 'test'}));
      });

      test('should create node with previous reference', () {
        final node = Node(
          id: 'child-id',
          root: 'root-id',
          previous: 'parent-id',
          spatialHash: 'child-hash',
          content: {'type': 'child'},
        );

        expect(node.previous, equals('parent-id'));
        expect(node.root, equals('root-id'));
      });

      test('should create root node (previous is null)', () {
        final rootNode = TestData.createRootNode();

        expect(rootNode.previous, isNull);
        expect(rootNode.root, equals(rootNode.id));
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final json = testNode.toJson();

        expect(json['id'], equals(testNode.id));
        expect(json['root'], equals(testNode.root));
        expect(json['previous'], equals(testNode.previous));
        expect(json['spatialHash'], equals(testNode.spatialHash));
        expect(json['content'], equals(testNode.content));
      });

      test('should serialize node with previous reference', () {
        final childNode = TestData.createChildNode(
          parentId: 'parent-1',
          rootId: 'root-1',
        );
        final json = childNode.toJson();

        expect(json['previous'], equals('parent-1'));
        expect(json['root'], equals('root-1'));
      });

      test('should handle null previous in JSON', () {
        final json = testNode.toJson();
        // JSON serialization may exclude null values or include them as null
        if (json.containsKey('previous')) {
          expect(json['previous'], isNull);
        }
        // The key behavior is that it deserializes correctly
        final deserializedNode = Node.fromJson(json);
        expect(deserializedNode.previous, isNull);
      });
    });

    group('JSON Deserialization', () {
      test('should deserialize from JSON correctly', () {
        final node = Node.fromJson(testJson);

        expect(node.id, equals(testJson['id']));
        expect(node.root, equals(testJson['root']));
        expect(node.previous, equals(testJson['previous']));
        expect(node.spatialHash, equals(testJson['spatialHash']));
        expect(node.content, equals(testJson['content']));
      });

      test('should handle complex content in JSON', () {
        final complexJson = {
          ...testJson,
          'content': {
            'nested': {'data': 123},
            'array': [1, 2, 3],
            'string': 'test'
          }
        };

        final node = Node.fromJson(complexJson);
        expect(node.content['nested']['data'], equals(123));
        expect(node.content['array'], equals([1, 2, 3]));
        expect(node.content['string'], equals('test'));
      });
    });

    group('Round-trip Serialization', () {
      test('should maintain data integrity through JSON round-trip', () {
        final originalNode = TestData.createChildNode(
          id: 'round-trip-test',
          parentId: 'parent-test',
          rootId: 'root-test',
          spatialHash: 'hash-test',
          content: {
            'complex': {'nested': 'data'},
            'numbers': [1, 2.5, 3],
            'boolean': true
          },
        );

        final json = originalNode.toJson();
        final deserializedNode = Node.fromJson(json);

        expect(deserializedNode.id, equals(originalNode.id));
        expect(deserializedNode.root, equals(originalNode.root));
        expect(deserializedNode.previous, equals(originalNode.previous));
        expect(deserializedNode.spatialHash, equals(originalNode.spatialHash));
        expect(deserializedNode.content, equals(originalNode.content));
      });
    });

    group('copyWith Method', () {
      test('should copy with new spatialHash', () {
        final originalNode = TestData.createRootNode();
        final updatedNode = originalNode.copyWith(spatialHash: 'new-hash');

        expect(updatedNode.spatialHash, equals('new-hash'));
        expect(updatedNode.id, equals(originalNode.id));
        expect(updatedNode.root, equals(originalNode.root));
        expect(updatedNode.previous, equals(originalNode.previous));
        expect(updatedNode.content, equals(originalNode.content));
      });

      test('should copy with new content', () {
        final originalNode = TestData.createRootNode();
        final newContent = {'updated': 'content'};
        final updatedNode = originalNode.copyWith(content: newContent);

        expect(updatedNode.content, equals(newContent));
        expect(updatedNode.id, equals(originalNode.id));
        expect(updatedNode.spatialHash, equals(originalNode.spatialHash));
      });

      test('should copy with multiple fields updated', () {
        final originalNode = TestData.createRootNode();
        final newContent = {'multi': 'update'};
        final updatedNode = originalNode.copyWith(
          spatialHash: 'multi-hash',
          content: newContent,
        );

        expect(updatedNode.spatialHash, equals('multi-hash'));
        expect(updatedNode.content, equals(newContent));
        expect(updatedNode.id, equals(originalNode.id));
      });

      test('should return same instance when no changes', () {
        final originalNode = TestData.createRootNode();
        final unchangedNode = originalNode.copyWith();

        expect(unchangedNode.id, equals(originalNode.id));
        expect(unchangedNode.root, equals(originalNode.root));
        expect(unchangedNode.previous, equals(originalNode.previous));
        expect(unchangedNode.spatialHash, equals(originalNode.spatialHash));
        expect(unchangedNode.content, equals(originalNode.content));
      });
    });
  });

  group('NodeCreate Model Tests', () {
    test('should create NodeCreate with all fields', () {
      final nodeCreate = NodeCreate(
        previous: 'parent-id',
        spatialHash: 'create-hash',
        content: {'new': 'data'},
      );

      expect(nodeCreate.previous, equals('parent-id'));
      expect(nodeCreate.spatialHash, equals('create-hash'));
      expect(nodeCreate.content, equals({'new': 'data'}));
    });

    test('should create NodeCreate with null previous (root)', () {
      final nodeCreate = NodeCreate(
        previous: null,
        spatialHash: 'root-hash',
        content: {'root': 'data'},
      );

      expect(nodeCreate.previous, isNull);
    });

    test('should serialize/deserialize NodeCreate correctly', () {
      final original = TestData.createNodeCreate();
      final json = original.toJson();
      final deserialized = NodeCreate.fromJson(json);

      expect(deserialized.previous, equals(original.previous));
      expect(deserialized.spatialHash, equals(original.spatialHash));
      expect(deserialized.content, equals(original.content));
    });
  });

  group('NodeUpdate Model Tests', () {
    test('should create NodeUpdate with partial fields', () {
      final nodeUpdate = NodeUpdate(
        spatialHash: 'updated-hash',
        content: null,
      );

      expect(nodeUpdate.spatialHash, equals('updated-hash'));
      expect(nodeUpdate.content, isNull);
    });

    test('should create NodeUpdate with only content', () {
      final nodeUpdate = NodeUpdate(
        spatialHash: null,
        content: {'updated': 'content'},
      );

      expect(nodeUpdate.spatialHash, isNull);
      expect(nodeUpdate.content, equals({'updated': 'content'}));
    });

    test('should serialize/deserialize NodeUpdate correctly', () {
      final original = TestData.createNodeUpdate(
        spatialHash: 'update-hash',
        content: {'test': 'update'},
      );
      final json = original.toJson();
      final deserialized = NodeUpdate.fromJson(json);

      expect(deserialized.spatialHash, equals(original.spatialHash));
      expect(deserialized.content, equals(original.content));
    });

    test('should handle null fields in NodeUpdate serialization', () {
      final nodeUpdate = NodeUpdate(spatialHash: null, content: null);
      final json = nodeUpdate.toJson();
      final deserialized = NodeUpdate.fromJson(json);

      expect(deserialized.spatialHash, isNull);
      expect(deserialized.content, isNull);
    });
  });
}
