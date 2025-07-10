// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Node _$NodeFromJson(Map<String, dynamic> json) => Node(
      id: json['id'] as String,
      root: json['root'] as String,
      previous: json['previous'] as String?,
      spatialHash: json['spatialHash'] as String,
      content: json['content'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$NodeToJson(Node instance) => <String, dynamic>{
      'id': instance.id,
      'root': instance.root,
      if (instance.previous case final value?) 'previous': value,
      'spatialHash': instance.spatialHash,
      'content': instance.content,
    };

NodeCreate _$NodeCreateFromJson(Map<String, dynamic> json) => NodeCreate(
      previous: json['previous'] as String?,
      spatialHash: json['spatialHash'] as String,
      content: json['content'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$NodeCreateToJson(NodeCreate instance) =>
    <String, dynamic>{
      if (instance.previous case final value?) 'previous': value,
      'spatialHash': instance.spatialHash,
      'content': instance.content,
    };

NodeUpdate _$NodeUpdateFromJson(Map<String, dynamic> json) => NodeUpdate(
      spatialHash: json['spatialHash'] as String?,
      content: json['content'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NodeUpdateToJson(NodeUpdate instance) =>
    <String, dynamic>{
      if (instance.spatialHash case final value?) 'spatialHash': value,
      if (instance.content case final value?) 'content': value,
    };
