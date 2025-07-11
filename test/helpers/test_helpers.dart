import 'package:kiss_graph/api/graph-node-api.openapi.dart';
import 'package:kiss_graph/models/node_extensions.dart';

/// Test data helpers for creating consistent test nodes
class TestData {
  static Node createRootNode({
    String? id,
    String? pathHash,
    Map<String, dynamic>? content,
  }) {
    final nodeId = id ?? 'root-1';
    return NodeExtensions.create(
      id: nodeId,
      root: nodeId,
      previous: null,
      pathHash: pathHash ?? '1',
      content: content ?? {'name': 'Root Node', 'type': 'root'},
    );
  }

  static Node createChildNode({
    String? id,
    required String parentId,
    required String rootId,
    String? pathHash,
    Map<String, dynamic>? content,
  }) {
    return NodeExtensions.create(
      id: id ?? 'child-1',
      root: rootId,
      previous: parentId,
      pathHash: pathHash ?? '1.1',
      content: content ?? {'name': 'Child Node', 'type': 'child'},
    );
  }

  static NodeCreate createNodeCreate({
    String? previous,
    String? pathHash,
    Map<String, dynamic>? content,
  }) {
    return NodeCreateExtensions.create(
      previous: previous,
      pathHash: pathHash,
      content: content ?? {'name': 'New Node', 'data': 42},
    );
  }

  static NodeUpdate createNodeUpdate({
    String? pathHash,
    Map<String, dynamic>? content,
  }) {
    return NodeUpdateExtensions.create(
      pathHash: pathHash,
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

      nodes.add(NodeExtensions.create(
        id: id,
        root: root,
        previous: previous,
        pathHash: i == 0 ? '1' : '1.${'.' * (i - 1)}${i + 1}',
        content: {'index': i, 'name': 'Chain Node $i'},
      ));
    }

    return nodes;
  }

  /// Creates nodes with common path prefixes for testing path queries
  static List<Node> createPathNodes() {
    return [
      NodeExtensions.create(
        id: 'path-1',
        root: 'path-1',
        previous: null,
        pathHash: '1',
        content: {'region': 'North'},
      ),
      NodeExtensions.create(
        id: 'path-2',
        root: 'path-2',
        previous: null,
        pathHash: '1.1',
        content: {'region': 'North-East'},
      ),
      NodeExtensions.create(
        id: 'path-3',
        root: 'path-3',
        previous: null,
        pathHash: '2',
        content: {'region': 'South'},
      ),
    ];
  }
}

/// Common test assertions and utilities
class TestHelpers {
  /// Validates that a node has the expected structure
  static void validateNode(Node node) {
    assert(node.validId.isNotEmpty, 'Node ID should not be empty');
    assert(node.validRoot.isNotEmpty, 'Node root should not be empty');
    assert(node.validPathHash.isNotEmpty, 'Path hash should not be empty');
    assert(node.contentMap.isNotEmpty, 'Content should not be empty');
  }

  /// Validates that a node chain is correctly linked
  static void validateChain(List<Node> nodes) {
    assert(nodes.isNotEmpty, 'Chain should not be empty');

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];

      if (i == 0) {
        // Root node
        assert(node.previous == null, 'Root node should have no previous');
        assert(
            node.validRoot == node.validId, 'Root node should be its own root');
      } else {
        // Child node
        assert(node.previous == nodes[i - 1].validId,
            'Node should link to previous');
        assert(node.validRoot == nodes[0].validId,
            'Node should have correct root');
      }
    }
  }

  /// Creates a test error message for failed assertions
  static String errorMessage(String operation, String expected, String actual) {
    return 'Failed $operation: expected $expected, got $actual';
  }
}
