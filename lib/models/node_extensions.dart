import '../graph-node-api.openapi.dart';

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
    if (spatialHash == null || spatialHash!.isEmpty) {
      throw ArgumentError('Node spatialHash cannot be null or empty');
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

  /// Get the spatialHash with validation (throws if null)
  String get validSpatialHash {
    if (spatialHash == null || spatialHash!.isEmpty) {
      throw StateError('Node spatialHash is null or empty');
    }
    return spatialHash!;
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
    String? spatialHash,
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
      spatialHash: spatialHash ?? this.spatialHash,
      content: newContent,
    );
  }

  /// Create a Node from basic parameters with validation
  static Node create({
    required String id,
    required String root,
    String? previous,
    required String spatialHash,
    required Map<String, dynamic> content,
  }) {
    final nodeContent = NodeContent();
    content.forEach((key, value) {
      nodeContent[key] = value;
    });

    final node = Node(
      id: id,
      root: root,
      previous: previous,
      spatialHash: spatialHash,
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
    if (spatialHash.isEmpty) {
      throw ArgumentError('NodeCreate spatialHash cannot be empty');
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
    String? previous,
    required String spatialHash,
    required Map<String, dynamic> content,
  }) {
    final nodeCreate = NodeCreate(
      previous: previous ?? '',
      spatialHash: spatialHash,
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
    String? spatialHash,
    Map<String, dynamic>? content,
  }) {
    return NodeUpdate(
      spatialHash: spatialHash,
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
