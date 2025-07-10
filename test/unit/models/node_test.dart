import 'package:kiss_graph/graph-node-api.openapi.dart';
import 'package:kiss_graph/models/node_extensions.dart';
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
        final node = NodeExtensions.create(
          id: 'test-id',
          root: 'test-root',
          previous: null,
          spatialHash: 'test-hash',
          content: {'data': 'test'},
        );

        expect(node.validId, equals('test-id'));
        expect(node.validRoot, equals('test-root'));
        expect(node.previous, isNull);
        expect(node.validSpatialHash, equals('test-hash'));
        expect(node.contentMap, equals({'data': 'test'}));
      });

      test('should create node with previous reference', () {
        final node = NodeExtensions.create(
          id: 'child-id',
          root: 'root-id',
          previous: 'parent-id',
          spatialHash: 'child-hash',
          content: {'type': 'child'},
        );

        expect(node.previous, equals('parent-id'));
        expect(node.validRoot, equals('root-id'));
      });

      test('should create root node (previous is null)', () {
        final rootNode = TestData.createRootNode();

        expect(rootNode.previous, isNull);
        expect(rootNode.validRoot, equals(rootNode.validId));
      });
    });

    group('JSON Serialization', () {
      test('should serialize node to JSON correctly', () {
        final node = TestData.createRootNode(
          id: 'serialize-test',
          spatialHash: 'hash123',
        );
        final json = node.toJson();

        expect(json['id'], equals('serialize-test'));
        expect(json['spatialHash'], equals('hash123'));
        expect(json['content'], isNotNull);
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
        // Content handling is different with OpenAPI models
        final contentMap = node.contentMap;
        expect(contentMap['key'], equals('value'));
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
        final contentMap = node.contentMap;
        expect(contentMap['nested']['data'], equals(123));
        expect(contentMap['array'], equals([1, 2, 3]));
        expect(contentMap['string'], equals('test'));
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
        expect(deserializedNode.contentMap, equals(originalNode.contentMap));
      });
    });

    group('copyWith Method', () {
      test('should copy with new spatialHash', () {
        final originalNode = TestData.createRootNode();
        final updatedNode = originalNode.copyWith(spatialHash: 'new-hash');

        expect(updatedNode.validSpatialHash, equals('new-hash'));
        expect(updatedNode.validId, equals(originalNode.validId));
        expect(updatedNode.validRoot, equals(originalNode.validRoot));
        expect(updatedNode.previous, equals(originalNode.previous));
        expect(updatedNode.contentMap, equals(originalNode.contentMap));
      });

      test('should copy with new content', () {
        final originalNode = TestData.createRootNode();
        final newContent = {'updated': 'content'};
        final updatedNode = originalNode.copyWith(content: newContent);

        expect(updatedNode.contentMap, equals(newContent));
        expect(updatedNode.validId, equals(originalNode.validId));
        expect(updatedNode.validSpatialHash,
            equals(originalNode.validSpatialHash));
      });

      test('should copy with multiple fields updated', () {
        final originalNode = TestData.createRootNode();
        final newContent = {'multi': 'update'};
        final updatedNode = originalNode.copyWith(
          spatialHash: 'multi-hash',
          content: newContent,
        );

        expect(updatedNode.validSpatialHash, equals('multi-hash'));
        expect(updatedNode.contentMap, equals(newContent));
        expect(updatedNode.validId, equals(originalNode.validId));
      });

      test('should return same instance when no changes', () {
        final originalNode = TestData.createRootNode();
        final unchangedNode = originalNode.copyWith();

        expect(unchangedNode.validId, equals(originalNode.validId));
        expect(unchangedNode.validRoot, equals(originalNode.validRoot));
        expect(unchangedNode.previous, equals(originalNode.previous));
        expect(unchangedNode.validSpatialHash,
            equals(originalNode.validSpatialHash));
        expect(unchangedNode.contentMap, equals(originalNode.contentMap));
      });
    });

    group('Node Validation', () {
      test('should validate complete node', () {
        final node = TestData.createRootNode();
        expect(() => node.validate(), returnsNormally);
      });

      test('should throw on invalid node (null ID)', () {
        final node = Node(
            id: null,
            root: 'root',
            previous: null,
            spatialHash: 'hash',
            content: null);
        expect(() => node.validate(), throwsArgumentError);
      });

      test('should throw on invalid node (empty spatialHash)', () {
        final node = Node(
            id: 'id',
            root: 'root',
            previous: null,
            spatialHash: '',
            content: null);
        expect(() => node.validate(), throwsArgumentError);
      });
    });
  });

  group('NodeCreate Model Tests', () {
    test('should create NodeCreate with all fields', () {
      final nodeCreate = NodeCreateExtensions.create(
        previous: 'parent-id',
        spatialHash: 'create-hash',
        content: {'new': 'data'},
      );

      expect(nodeCreate.validPrevious, equals('parent-id'));
      expect(nodeCreate.spatialHash, equals('create-hash'));
      expect(nodeCreate.content.toMap(), equals({'new': 'data'}));
    });

    test('should create NodeCreate with null previous (root)', () {
      final nodeCreate = NodeCreateExtensions.create(
        previous: null,
        spatialHash: 'root-hash',
        content: {'root': 'data'},
      );

      expect(nodeCreate.validPrevious, isNull);
    });

    test('should serialize/deserialize NodeCreate correctly', () {
      final original = TestData.createNodeCreate();
      final json = original.toJson();
      final deserialized = NodeCreate.fromJson(json);

      expect(deserialized.previous, equals(original.previous));
      expect(deserialized.spatialHash, equals(original.spatialHash));
      expect(deserialized.content.toMap(), equals(original.content.toMap()));
    });
  });

  group('NodeUpdate Model Tests', () {
    test('should create NodeUpdate with partial fields', () {
      final nodeUpdate = NodeUpdateExtensions.create(
        spatialHash: 'updated-hash',
        content: null,
      );

      expect(nodeUpdate.spatialHash, equals('updated-hash'));
      expect(nodeUpdate.content, isNull);
    });

    test('should create NodeUpdate with only content', () {
      final nodeUpdate = NodeUpdateExtensions.create(
        spatialHash: null,
        content: {'updated': 'content'},
      );

      expect(nodeUpdate.spatialHash, isNull);
      expect(nodeUpdate.content?.toMap(), equals({'updated': 'content'}));
    });

    test('should serialize/deserialize NodeUpdate correctly', () {
      final original = TestData.createNodeUpdate(
        spatialHash: 'update-hash',
        content: {'test': 'update'},
      );
      final json = original.toJson();
      final deserialized = NodeUpdate.fromJson(json);

      expect(deserialized.spatialHash, equals(original.spatialHash));
      expect(deserialized.content?.toMap(), equals(original.content?.toMap()));
    });

    test('should handle null fields in NodeUpdate serialization', () {
      final nodeUpdate =
          NodeUpdateExtensions.create(spatialHash: null, content: null);
      final json = nodeUpdate.toJson();
      final deserialized = NodeUpdate.fromJson(json);

      expect(deserialized.spatialHash, isNull);
      expect(deserialized.content, isNull);
    });
  });
}
