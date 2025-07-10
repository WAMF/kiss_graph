import 'package:json_annotation/json_annotation.dart';

part 'node.g.dart';

@JsonSerializable()
class Node {
  final String id;
  final String root;
  final String? previous;
  final String spatialHash;
  final Map<String, dynamic> content;

  const Node({
    required this.id,
    required this.root,
    required this.previous,
    required this.spatialHash,
    required this.content,
  });

  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);

  Map<String, dynamic> toJson() => _$NodeToJson(this);

  Node copyWith({
    String? id,
    String? root,
    String? previous,
    String? spatialHash,
    Map<String, dynamic>? content,
  }) {
    return Node(
      id: id ?? this.id,
      root: root ?? this.root,
      previous: previous ?? this.previous,
      spatialHash: spatialHash ?? this.spatialHash,
      content: content ?? this.content,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Node &&
        other.id == id &&
        other.root == root &&
        other.previous == previous &&
        other.spatialHash == spatialHash &&
        _mapEquals(other.content, content);
  }

  @override
  int get hashCode => 
      id.hashCode ^
      root.hashCode ^
      previous.hashCode ^
      spatialHash.hashCode ^
      content.hashCode;

  bool _mapEquals(Map<String, dynamic> map1, Map<String, dynamic> map2) {
    if (map1.length != map2.length) return false;
    for (final key in map1.keys) {
      if (!map2.containsKey(key) || map1[key] != map2[key]) {
        return false;
      }
    }
    return true;
  }
}

@JsonSerializable()
class NodeCreate {
  final String? previous;
  final String spatialHash;
  final Map<String, dynamic> content;

  const NodeCreate({
    required this.previous,
    required this.spatialHash,
    required this.content,
  });

  factory NodeCreate.fromJson(Map<String, dynamic> json) => _$NodeCreateFromJson(json);

  Map<String, dynamic> toJson() => _$NodeCreateToJson(this);
}

@JsonSerializable()
class NodeUpdate {
  final String? spatialHash;
  final Map<String, dynamic>? content;

  const NodeUpdate({
    this.spatialHash,
    this.content,
  });

  factory NodeUpdate.fromJson(Map<String, dynamic> json) => _$NodeUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$NodeUpdateToJson(this);
}