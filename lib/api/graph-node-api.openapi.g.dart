// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graph-node-api.openapi.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NodeContent _$NodeContentFromJson(Map<String, dynamic> json) => NodeContent();

Map<String, dynamic> _$NodeContentToJson(NodeContent instance) =>
    <String, dynamic>{};

Node _$NodeFromJson(Map<String, dynamic> json) => Node(
      id: json['id'] as String?,
      root: json['root'] as String?,
      previous: json['previous'] as String?,
      pathHash: json['pathHash'] as String?,
      content: json['content'] == null
          ? null
          : NodeContent.fromJson(json['content'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NodeToJson(Node instance) => <String, dynamic>{
      if (instance.id case final value?) 'id': value,
      if (instance.root case final value?) 'root': value,
      if (instance.previous case final value?) 'previous': value,
      if (instance.pathHash case final value?) 'pathHash': value,
      if (instance.content?.toJson() case final value?) 'content': value,
    };

NodeCreateContent _$NodeCreateContentFromJson(Map<String, dynamic> json) =>
    NodeCreateContent();

Map<String, dynamic> _$NodeCreateContentToJson(NodeCreateContent instance) =>
    <String, dynamic>{};

NodeCreate _$NodeCreateFromJson(Map<String, dynamic> json) => NodeCreate(
      previous: json['previous'] as String,
      pathHash: json['pathHash'] as String?,
      content:
          NodeCreateContent.fromJson(json['content'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NodeCreateToJson(NodeCreate instance) =>
    <String, dynamic>{
      'previous': instance.previous,
      if (instance.pathHash case final value?) 'pathHash': value,
      'content': instance.content.toJson(),
    };

NodeUpdateContent _$NodeUpdateContentFromJson(Map<String, dynamic> json) =>
    NodeUpdateContent();

Map<String, dynamic> _$NodeUpdateContentToJson(NodeUpdateContent instance) =>
    <String, dynamic>{};

NodeUpdate _$NodeUpdateFromJson(Map<String, dynamic> json) => NodeUpdate(
      pathHash: json['pathHash'] as String?,
      content: json['content'] == null
          ? null
          : NodeUpdateContent.fromJson(json['content'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NodeUpdateToJson(NodeUpdate instance) =>
    <String, dynamic>{
      if (instance.pathHash case final value?) 'pathHash': value,
      if (instance.content?.toJson() case final value?) 'content': value,
    };
