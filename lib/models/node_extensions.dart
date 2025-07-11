import 'package:kiss_graph/api/graph-node-api.openapi.dart';

/// Extensions for OpenAPI Node model to add business logic capabilities
extension NodeExtensions on Node {
  /// Validates that this node has all required fields for business operations
  void validate() {
    if (id == null || id!.isEmpty) {
      throw ArgumentError('Node ID cannot be null or empty');
    }
    if (root == null || root!.isEmpty) {
      throw ArgumentError('Node root cannot be null or empty');
    }
    if (pathHash == null || pathHash!.isEmpty) {
      throw ArgumentError('Node pathHash cannot be null or empty');
    }
    if (content == null) {
      throw ArgumentError('Node content cannot be null');
    }
  }

  /// Get the ID with validation (throws if null)
  String get validId {
    if (id == null || id!.isEmpty) {
      throw StateError('Node ID is null or empty');
    }
    return id!;
  }

  /// Get the root with validation (throws if null)
  String get validRoot {
    if (root == null || root!.isEmpty) {
      throw StateError('Node root is null or empty');
    }
    return root!;
  }

  /// Get the pathHash with validation (throws if null)
  String get validPathHash {
    if (pathHash == null || pathHash!.isEmpty) {
      throw StateError('Node pathHash is null or empty');
    }
    return pathHash!;
  }

  /// Get the content as a Map<String, dynamic>
  Map<String, dynamic> get contentMap {
    return content?.additionalProperties.cast<String, dynamic>() ??
        <String, dynamic>{};
  }

  /// Create a copy of this node with updated fields
  Node copyWith({
    String? id,
    String? root,
    String? previous,
    String? pathHash,
    Map<String, dynamic>? content,
  }) {
    final newContent = NodeContent();
    final contentToUse = content ?? contentMap;
    contentToUse.forEach((key, value) {
      newContent[key] = value;
    });

    return Node(
      id: id ?? this.id,
      root: root ?? this.root,
      previous: previous ?? this.previous,
      pathHash: pathHash ?? this.pathHash,
      content: newContent,
    );
  }

  /// Create a Node from basic parameters with validation
  static Node create({
    required String id,
    required String root,
    required String pathHash, required Map<String, dynamic> content, String? previous,
  }) {
    final nodeContent = NodeContent();
    content.forEach((key, value) {
      nodeContent[key] = value;
    });

    final node = Node(
      id: id,
      root: root,
      previous: previous,
      pathHash: pathHash,
      content: nodeContent,
    );

    node.validate();
    return node;
  }
}

/// Extensions for NodeContent to provide Map-like operations
extension NodeContentExtensions on NodeContent {
  /// Create NodeContent from a Map
  static NodeContent fromMap(Map<String, dynamic> map) {
    final content = NodeContent();
    map.forEach((key, value) {
      content[key] = value;
    });
    return content;
  }

  /// Convert to Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return additionalProperties.cast<String, dynamic>();
  }

  /// Check if content is empty
  bool get isEmpty => additionalProperties.isEmpty;

  /// Check if content is not empty
  bool get isNotEmpty => additionalProperties.isNotEmpty;
}

/// Extensions for NodeCreate to add validation and helpers
extension NodeCreateExtensions on NodeCreate {
  /// Validates NodeCreate
  void validate() {
    if (pathHash != null && pathHash!.isEmpty) {
      throw ArgumentError('NodeCreate pathHash cannot be empty');
    }
    if (content.additionalProperties.isEmpty) {
      throw ArgumentError('NodeCreate content cannot be empty');
    }
  }

  /// Get previous as nullable (converts empty string to null)
  String? get validPrevious {
    return previous.isEmpty ? null : previous;
  }

  /// Create NodeCreate from basic parameters
  static NodeCreate create({
    required Map<String, dynamic> content, String? previous,
    String? pathHash,
  }) {
    final nodeCreate = NodeCreate(
      previous: previous ?? '',
      pathHash: pathHash,
      content: NodeCreateContentExtensions.fromMap(content),
    );

    nodeCreate.validate();
    return nodeCreate;
  }
}

/// Extensions for NodeCreateContent
extension NodeCreateContentExtensions on NodeCreateContent {
  /// Create NodeCreateContent from a Map
  static NodeCreateContent fromMap(Map<String, dynamic> map) {
    final content = NodeCreateContent();
    map.forEach((key, value) {
      content[key] = value;
    });
    return content;
  }

  /// Convert to Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return additionalProperties.cast<String, dynamic>();
  }
}

/// Extensions for NodeUpdate to add validation and helpers
extension NodeUpdateExtensions on NodeUpdate {
  /// Create NodeUpdate from basic parameters
  static NodeUpdate create({
    String? pathHash,
    Map<String, dynamic>? content,
  }) {
    return NodeUpdate(
      pathHash: pathHash,
      content:
          content != null ? NodeUpdateContentExtensions.fromMap(content) : null,
    );
  }
}

/// Extensions for NodeUpdateContent
extension NodeUpdateContentExtensions on NodeUpdateContent {
  /// Create NodeUpdateContent from a Map
  static NodeUpdateContent fromMap(Map<String, dynamic> map) {
    final content = NodeUpdateContent();
    map.forEach((key, value) {
      content[key] = value;
    });
    return content;
  }

  /// Convert to Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return additionalProperties.cast<String, dynamic>();
  }
}

/// Utility class for generating hierarchical path hashes for breadcrumb navigation
class PathHashGenerator {
  /// Generates the root path hash for a new root node
  static String generateRootPath() {
    return '1';
  }

  /// Generates a child path hash based on parent's path and child position
  /// Examples:
  /// - First child of root "1" becomes "1.1"
  /// - Second child of root "1" becomes "1.2"
  /// - First child of "1.1" becomes "1.1.1"
  static String generateChildPath(String parentPath, int childPosition) {
    if (childPosition < 1) {
      throw ArgumentError('Child position must be 1 or greater');
    }
    return '$parentPath.$childPosition';
  }

  /// Extracts the parent path from a child path
  /// Examples:
  /// - "1.1.2" returns "1.1"
  /// - "1.1" returns "1"
  /// - "1" returns null (root has no parent)
  static String? getParentPath(String childPath) {
    final lastDotIndex = childPath.lastIndexOf('.');
    if (lastDotIndex == -1) {
      return null; // Root node has no parent
    }
    return childPath.substring(0, lastDotIndex);
  }

  /// Gets the depth level of a path (number of dots + 1)
  /// Examples:
  /// - "1" returns 1 (root level)
  /// - "1.1" returns 2 (first child level)
  /// - "1.1.1" returns 3 (grandchild level)
  static int getPathDepth(String path) {
    return path.split('.').length;
  }

  /// Gets all ancestor paths for breadcrumb navigation
  /// Examples:
  /// - "1.1.2" returns ["1", "1.1", "1.1.2"]
  /// - "1" returns ["1"]
  static List<String> getAncestorPaths(String path) {
    final parts = path.split('.');
    final ancestors = <String>[];

    for (var i = 1; i <= parts.length; i++) {
      ancestors.add(parts.take(i).join('.'));
    }

    return ancestors;
  }

  /// Validates if a path hash follows the correct hierarchical format
  static bool isValidPathHash(String pathHash) {
    if (pathHash.isEmpty) return false;

    final parts = pathHash.split('.');
    for (final part in parts) {
      if (part.isEmpty || int.tryParse(part) == null || int.parse(part) < 1) {
        return false;
      }
    }
    return true;
  }
}
