import 'package:kiss_graph/models/node.dart';

/// Test data helpers for creating consistent test nodes
class TestData {
  static Node createRootNode({
    String? id,
    String? spatialHash,
    Map<String, dynamic>? content,
  }) {
    final nodeId = id ?? 'root-1';
    return Node(
      id: nodeId,
      root: nodeId,
      previous: null,
      spatialHash: spatialHash ?? 'abc123',
      content: content ?? {'name': 'Root Node', 'type': 'root'},
    );
  }

  static Node createChildNode({
    String? id,
    required String parentId,
    required String rootId,
    String? spatialHash,
    Map<String, dynamic>? content,
  }) {
    return Node(
      id: id ?? 'child-1',
      root: rootId,
      previous: parentId,
      spatialHash: spatialHash ?? 'abc124',
      content: content ?? {'name': 'Child Node', 'type': 'child'},
    );
  }

  static NodeCreate createNodeCreate({
    String? previous,
    String? spatialHash,
    Map<String, dynamic>? content,
  }) {
    return NodeCreate(
      previous: previous,
      spatialHash: spatialHash ?? 'xyz789',
      content: content ?? {'name': 'New Node', 'data': 42},
    );
  }

  static NodeUpdate createNodeUpdate({
    String? spatialHash,
    Map<String, dynamic>? content,
  }) {
    return NodeUpdate(
      spatialHash: spatialHash,
      content: content,
    );
  }

  /// Creates a chain of nodes for testing trace functionality
  static List<Node> createNodeChain(int length) {
    final nodes = <Node>[];

    for (int i = 0; i < length; i++) {
      final id = 'node-$i';
      final previous = i == 0 ? null : 'node-${i - 1}';
      final root = 'node-0';

      nodes.add(Node(
        id: id,
        root: root,
        previous: previous,
        spatialHash: 'chain$i',
        content: {'index': i, 'name': 'Chain Node $i'},
      ));
    }

    return nodes;
  }

  /// Creates nodes with common spatial prefixes for testing spatial queries
  static List<Node> createSpatialNodes() {
    return [
      Node(
        id: 'spatial-1',
        root: 'spatial-1',
        previous: null,
        spatialHash: 'abc123',
        content: {'region': 'North'},
      ),
      Node(
        id: 'spatial-2',
        root: 'spatial-2',
        previous: null,
        spatialHash: 'abc456',
        content: {'region': 'North-East'},
      ),
      Node(
        id: 'spatial-3',
        root: 'spatial-3',
        previous: null,
        spatialHash: 'def789',
        content: {'region': 'South'},
      ),
    ];
  }
}

/// Common test assertions and utilities
class TestHelpers {
  /// Validates that a node has the expected structure
  static void validateNode(Node node) {
    assert(node.id.isNotEmpty, 'Node ID should not be empty');
    assert(node.root.isNotEmpty, 'Node root should not be empty');
    assert(node.spatialHash.isNotEmpty, 'Spatial hash should not be empty');
    assert(node.content.isNotEmpty, 'Content should not be empty');
  }

  /// Validates that a node chain is correctly linked
  static void validateChain(List<Node> nodes) {
    assert(nodes.isNotEmpty, 'Chain should not be empty');

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];

      if (i == 0) {
        // Root node
        assert(node.previous == null, 'Root node should have no previous');
        assert(node.root == node.id, 'Root node should be its own root');
      } else {
        // Child node
        assert(
            node.previous == nodes[i - 1].id, 'Node should link to previous');
        assert(node.root == nodes[0].id, 'Node should have correct root');
      }
    }
  }

  /// Creates a test error message for failed assertions
  static String errorMessage(String operation, String expected, String actual) {
    return 'Failed $operation: expected $expected, got $actual';
  }
}
