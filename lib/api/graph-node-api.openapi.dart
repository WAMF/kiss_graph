// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: prefer_initializing_formals, library_private_types_in_public_api, annotate_overrides, unused_element

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:openapi_base/openapi_base.dart';
part 'graph-node-api.openapi.g.dart';

@JsonSerializable()
@ApiUuidJsonConverter()
class NodeContent implements OpenApiContent {
  NodeContent();

  factory NodeContent.fromJson(Map<String, dynamic> jsonMap) =>
      _$NodeContentFromJson(jsonMap)
        .._additionalProperties.addEntries(
            jsonMap.entries.where((e) => !const <String>{}.contains(e.key)));

  final Map<String, Object?> _additionalProperties = <String, Object?>{};

  Map<String, dynamic> toJson() =>
      Map.from(_additionalProperties)..addAll(_$NodeContentToJson(this));

  @override
  String toString() => toJson().toString();

  Map<String, Object?> get additionalProperties => _additionalProperties;

  void operator []=(
    String key,
    Object? value,
  ) =>
      _additionalProperties[key] = value;

  Object? operator [](String key) => _additionalProperties[key];
}

@JsonSerializable()
@ApiUuidJsonConverter()
class Node implements OpenApiContent {
  const Node({
    this.id,
    this.root,
    this.previous,
    this.pathHash,
    this.content,
  });

  factory Node.fromJson(Map<String, dynamic> jsonMap) =>
      _$NodeFromJson(jsonMap);

  @JsonKey(
    name: 'id',
    includeIfNull: false,
  )
  final String? id;

  @JsonKey(
    name: 'root',
    includeIfNull: false,
  )
  final String? root;

  @JsonKey(name: 'previous')
  final String? previous;

  @JsonKey(
    name: 'pathHash',
    includeIfNull: false,
  )
  final String? pathHash;

  @JsonKey(
    name: 'content',
    includeIfNull: false,
  )
  final NodeContent? content;

  Map<String, dynamic> toJson() => _$NodeToJson(this);

  @override
  String toString() => toJson().toString();
}

@JsonSerializable()
@ApiUuidJsonConverter()
class NodeCreateContent implements OpenApiContent {
  NodeCreateContent();

  factory NodeCreateContent.fromJson(Map<String, dynamic> jsonMap) =>
      _$NodeCreateContentFromJson(jsonMap)
        .._additionalProperties.addEntries(
            jsonMap.entries.where((e) => !const <String>{}.contains(e.key)));

  final Map<String, Object?> _additionalProperties = <String, Object?>{};

  Map<String, dynamic> toJson() =>
      Map.from(_additionalProperties)..addAll(_$NodeCreateContentToJson(this));

  @override
  String toString() => toJson().toString();

  Map<String, Object?> get additionalProperties => _additionalProperties;

  void operator []=(
    String key,
    Object? value,
  ) =>
      _additionalProperties[key] = value;

  Object? operator [](String key) => _additionalProperties[key];
}

@JsonSerializable()
@ApiUuidJsonConverter()
class NodeCreate implements OpenApiContent {
  const NodeCreate({
    required this.previous,
    this.pathHash,
    required this.content,
  });

  factory NodeCreate.fromJson(Map<String, dynamic> jsonMap) =>
      _$NodeCreateFromJson(jsonMap);

  @JsonKey(name: 'previous')
  final String previous;

  @JsonKey(
    name: 'pathHash',
    includeIfNull: false,
  )
  final String? pathHash;

  @JsonKey(
    name: 'content',
    includeIfNull: false,
  )
  final NodeCreateContent content;

  Map<String, dynamic> toJson() => _$NodeCreateToJson(this);

  @override
  String toString() => toJson().toString();
}

@JsonSerializable()
@ApiUuidJsonConverter()
class NodeUpdateContent implements OpenApiContent {
  NodeUpdateContent();

  factory NodeUpdateContent.fromJson(Map<String, dynamic> jsonMap) =>
      _$NodeUpdateContentFromJson(jsonMap)
        .._additionalProperties.addEntries(
            jsonMap.entries.where((e) => !const <String>{}.contains(e.key)));

  final Map<String, Object?> _additionalProperties = <String, Object?>{};

  Map<String, dynamic> toJson() =>
      Map.from(_additionalProperties)..addAll(_$NodeUpdateContentToJson(this));

  @override
  String toString() => toJson().toString();

  Map<String, Object?> get additionalProperties => _additionalProperties;

  void operator []=(
    String key,
    Object? value,
  ) =>
      _additionalProperties[key] = value;

  Object? operator [](String key) => _additionalProperties[key];
}

@JsonSerializable()
@ApiUuidJsonConverter()
class NodeUpdate implements OpenApiContent {
  const NodeUpdate({
    this.pathHash,
    this.content,
  });

  factory NodeUpdate.fromJson(Map<String, dynamic> jsonMap) =>
      _$NodeUpdateFromJson(jsonMap);

  @JsonKey(
    name: 'pathHash',
    includeIfNull: false,
  )
  final String? pathHash;

  @JsonKey(
    name: 'content',
    includeIfNull: false,
  )
  final NodeUpdateContent? content;

  Map<String, dynamic> toJson() => _$NodeUpdateToJson(this);

  @override
  String toString() => toJson().toString();
}

class NodesPostResponse201 extends NodesPostResponse
    implements OpenApiResponseBodyJson {
  /// Node created
  NodesPostResponse201.response201(this.body)
      : status = 201,
        bodyJson = body.toJson();

  @override
  final int status;

  final Node body;

  @override
  final Map<String, dynamic> bodyJson;

  @override
  final OpenApiContentType contentType =
      OpenApiContentType.parse('application/json');

  @override
  Map<String, Object?> propertiesToString() => {
        'status': status,
        'body': body,
        'bodyJson': bodyJson,
        'contentType': contentType,
      };
}

sealed class NodesPostResponse extends OpenApiResponse
    implements HasSuccessResponse<Node> {
  NodesPostResponse();

  /// Node created
  factory NodesPostResponse.response201(Node body) =>
      NodesPostResponse201.response201(body);

  R map<R>({
    required ResponseMap<NodesPostResponse201, R> on201,
    ResponseMap<NodesPostResponse, R>? onElse,
  }) {
    if (this is NodesPostResponse201) {
      return on201((this as NodesPostResponse201));
    } else if (onElse != null) {
      return onElse(this);
    } else {
      throw StateError('Invalid instance of type $this');
    }
  }

  /// status 201:  Node created
  @override
  Node requireSuccess() {
    if (this is NodesPostResponse201) {
      return (this as NodesPostResponse201).body;
    } else {
      throw StateError('Expected success response, but got $this');
    }
  }
}

class NodesIdGetResponse200 extends NodesIdGetResponse
    implements OpenApiResponseBodyJson {
  /// Node found
  NodesIdGetResponse200.response200(this.body)
      : status = 200,
        bodyJson = body.toJson();

  @override
  final int status;

  final Node body;

  @override
  final Map<String, dynamic> bodyJson;

  @override
  final OpenApiContentType contentType =
      OpenApiContentType.parse('application/json');

  @override
  Map<String, Object?> propertiesToString() => {
        'status': status,
        'body': body,
        'bodyJson': bodyJson,
        'contentType': contentType,
      };
}

class NodesIdGetResponse404 extends NodesIdGetResponse {
  /// Node not found
  NodesIdGetResponse404.response404() : status = 404;

  @override
  final int status;

  @override
  final OpenApiContentType? contentType = null;

  @override
  Map<String, Object?> propertiesToString() => {
        'status': status,
        'contentType': contentType,
      };
}

sealed class NodesIdGetResponse extends OpenApiResponse
    implements HasSuccessResponse<Node> {
  NodesIdGetResponse();

  /// Node found
  factory NodesIdGetResponse.response200(Node body) =>
      NodesIdGetResponse200.response200(body);

  /// Node not found
  factory NodesIdGetResponse.response404() =>
      NodesIdGetResponse404.response404();

  R map<R>({
    required ResponseMap<NodesIdGetResponse200, R> on200,
    required ResponseMap<NodesIdGetResponse404, R> on404,
    ResponseMap<NodesIdGetResponse, R>? onElse,
  }) {
    if (this is NodesIdGetResponse200) {
      return on200((this as NodesIdGetResponse200));
    } else if (this is NodesIdGetResponse404) {
      return on404((this as NodesIdGetResponse404));
    } else if (onElse != null) {
      return onElse(this);
    } else {
      throw StateError('Invalid instance of type $this');
    }
  }

  /// status 200:  Node found
  @override
  Node requireSuccess() {
    if (this is NodesIdGetResponse200) {
      return (this as NodesIdGetResponse200).body;
    } else {
      throw StateError('Expected success response, but got $this');
    }
  }
}

class NodesIdDeleteResponse204 extends NodesIdDeleteResponse {
  /// Node deleted
  NodesIdDeleteResponse204.response204() : status = 204;

  @override
  final int status;

  @override
  final OpenApiContentType? contentType = null;

  @override
  Map<String, Object?> propertiesToString() => {
        'status': status,
        'contentType': contentType,
      };
}

class NodesIdDeleteResponse409 extends NodesIdDeleteResponse {
  /// Node has children (deletion blocked)
  NodesIdDeleteResponse409.response409() : status = 409;

  @override
  final int status;

  @override
  final OpenApiContentType? contentType = null;

  @override
  Map<String, Object?> propertiesToString() => {
        'status': status,
        'contentType': contentType,
      };
}

sealed class NodesIdDeleteResponse extends OpenApiResponse
    implements HasSuccessResponse<void> {
  NodesIdDeleteResponse();

  /// Node deleted
  factory NodesIdDeleteResponse.response204() =>
      NodesIdDeleteResponse204.response204();

  /// Node has children (deletion blocked)
  factory NodesIdDeleteResponse.response409() =>
      NodesIdDeleteResponse409.response409();

  R map<R>({
    required ResponseMap<NodesIdDeleteResponse204, R> on204,
    required ResponseMap<NodesIdDeleteResponse409, R> on409,
    ResponseMap<NodesIdDeleteResponse, R>? onElse,
  }) {
    if (this is NodesIdDeleteResponse204) {
      return on204((this as NodesIdDeleteResponse204));
    } else if (this is NodesIdDeleteResponse409) {
      return on409((this as NodesIdDeleteResponse409));
    } else if (onElse != null) {
      return onElse(this);
    } else {
      throw StateError('Invalid instance of type $this');
    }
  }

  /// status 204:  Node deleted
  @override
  void requireSuccess() {
    if (this is NodesIdDeleteResponse204) {
      return;
    } else {
      throw StateError('Expected success response, but got $this');
    }
  }
}

class NodesIdPatchResponse200 extends NodesIdPatchResponse
    implements OpenApiResponseBodyJson {
  /// Node updated
  NodesIdPatchResponse200.response200(this.body)
      : status = 200,
        bodyJson = body.toJson();

  @override
  final int status;

  final Node body;

  @override
  final Map<String, dynamic> bodyJson;

  @override
  final OpenApiContentType contentType =
      OpenApiContentType.parse('application/json');

  @override
  Map<String, Object?> propertiesToString() => {
        'status': status,
        'body': body,
        'bodyJson': bodyJson,
        'contentType': contentType,
      };
}

sealed class NodesIdPatchResponse extends OpenApiResponse
    implements HasSuccessResponse<Node> {
  NodesIdPatchResponse();

  /// Node updated
  factory NodesIdPatchResponse.response200(Node body) =>
      NodesIdPatchResponse200.response200(body);

  R map<R>({
    required ResponseMap<NodesIdPatchResponse200, R> on200,
    ResponseMap<NodesIdPatchResponse, R>? onElse,
  }) {
    if (this is NodesIdPatchResponse200) {
      return on200((this as NodesIdPatchResponse200));
    } else if (onElse != null) {
      return onElse(this);
    } else {
      throw StateError('Invalid instance of type $this');
    }
  }

  /// status 200:  Node updated
  @override
  Node requireSuccess() {
    if (this is NodesIdPatchResponse200) {
      return (this as NodesIdPatchResponse200).body;
    } else {
      throw StateError('Expected success response, but got $this');
    }
  }
}

class NodesIdChildrenGetResponse200 extends NodesIdChildrenGetResponse
    implements OpenApiResponseBodyJson {
  /// List of child nodes
  NodesIdChildrenGetResponse200.response200(this.body)
      : status = 200,
        bodyJson = {};

  @override
  final int status;

  final List<Node> body;

  @override
  final Map<String, dynamic> bodyJson;

  @override
  final OpenApiContentType contentType =
      OpenApiContentType.parse('application/json');

  @override
  Map<String, Object?> propertiesToString() => {
        'status': status,
        'body': body,
        'bodyJson': bodyJson,
        'contentType': contentType,
      };
}

sealed class NodesIdChildrenGetResponse extends OpenApiResponse
    implements HasSuccessResponse<List<Node>> {
  NodesIdChildrenGetResponse();

  /// List of child nodes
  factory NodesIdChildrenGetResponse.response200(List<Node> body) =>
      NodesIdChildrenGetResponse200.response200(body);

  R map<R>({
    required ResponseMap<NodesIdChildrenGetResponse200, R> on200,
    ResponseMap<NodesIdChildrenGetResponse, R>? onElse,
  }) {
    if (this is NodesIdChildrenGetResponse200) {
      return on200((this as NodesIdChildrenGetResponse200));
    } else if (onElse != null) {
      return onElse(this);
    } else {
      throw StateError('Invalid instance of type $this');
    }
  }

  /// status 200:  List of child nodes
  @override
  List<Node> requireSuccess() {
    if (this is NodesIdChildrenGetResponse200) {
      return (this as NodesIdChildrenGetResponse200).body;
    } else {
      throw StateError('Expected success response, but got $this');
    }
  }
}

class NodesIdTraceGetResponse200 extends NodesIdTraceGetResponse
    implements OpenApiResponseBodyJson {
  /// List of ancestor nodes
  NodesIdTraceGetResponse200.response200(this.body)
      : status = 200,
        bodyJson = {};

  @override
  final int status;

  final List<Node> body;

  @override
  final Map<String, dynamic> bodyJson;

  @override
  final OpenApiContentType contentType =
      OpenApiContentType.parse('application/json');

  @override
  Map<String, Object?> propertiesToString() => {
        'status': status,
        'body': body,
        'bodyJson': bodyJson,
        'contentType': contentType,
      };
}

sealed class NodesIdTraceGetResponse extends OpenApiResponse
    implements HasSuccessResponse<List<Node>> {
  NodesIdTraceGetResponse();

  /// List of ancestor nodes
  factory NodesIdTraceGetResponse.response200(List<Node> body) =>
      NodesIdTraceGetResponse200.response200(body);

  R map<R>({
    required ResponseMap<NodesIdTraceGetResponse200, R> on200,
    ResponseMap<NodesIdTraceGetResponse, R>? onElse,
  }) {
    if (this is NodesIdTraceGetResponse200) {
      return on200((this as NodesIdTraceGetResponse200));
    } else if (onElse != null) {
      return onElse(this);
    } else {
      throw StateError('Invalid instance of type $this');
    }
  }

  /// status 200:  List of ancestor nodes
  @override
  List<Node> requireSuccess() {
    if (this is NodesIdTraceGetResponse200) {
      return (this as NodesIdTraceGetResponse200).body;
    } else {
      throw StateError('Expected success response, but got $this');
    }
  }
}

class NodesPathPrefixGetResponse200 extends NodesPathPrefixGetResponse
    implements OpenApiResponseBodyJson {
  /// List of matching nodes
  NodesPathPrefixGetResponse200.response200(this.body)
      : status = 200,
        bodyJson = {};

  @override
  final int status;

  final List<Node> body;

  @override
  final Map<String, dynamic> bodyJson;

  @override
  final OpenApiContentType contentType =
      OpenApiContentType.parse('application/json');

  @override
  Map<String, Object?> propertiesToString() => {
        'status': status,
        'body': body,
        'bodyJson': bodyJson,
        'contentType': contentType,
      };
}

sealed class NodesPathPrefixGetResponse extends OpenApiResponse
    implements HasSuccessResponse<List<Node>> {
  NodesPathPrefixGetResponse();

  /// List of matching nodes
  factory NodesPathPrefixGetResponse.response200(List<Node> body) =>
      NodesPathPrefixGetResponse200.response200(body);

  R map<R>({
    required ResponseMap<NodesPathPrefixGetResponse200, R> on200,
    ResponseMap<NodesPathPrefixGetResponse, R>? onElse,
  }) {
    if (this is NodesPathPrefixGetResponse200) {
      return on200((this as NodesPathPrefixGetResponse200));
    } else if (onElse != null) {
      return onElse(this);
    } else {
      throw StateError('Invalid instance of type $this');
    }
  }

  /// status 200:  List of matching nodes
  @override
  List<Node> requireSuccess() {
    if (this is NodesPathPrefixGetResponse200) {
      return (this as NodesPathPrefixGetResponse200).body;
    } else {
      throw StateError('Expected success response, but got $this');
    }
  }
}

abstract class GraphNodeApi implements ApiEndpoint {
  /// Create a new node
  /// post: /nodes
  Future<NodesPostResponse> nodesPost(NodeCreate body);

  /// Get a node by ID
  /// get: /nodes/{id}
  Future<NodesIdGetResponse> nodesIdGet({required String id});

  /// Delete a node
  /// delete: /nodes/{id}
  Future<NodesIdDeleteResponse> nodesIdDelete({required String id});

  /// Update a node (content or pathHash only)
  /// patch: /nodes/{id}
  Future<NodesIdPatchResponse> nodesIdPatch(
    NodeUpdate body, {
    required String id,
  });

  /// Get children of a node
  /// get: /nodes/{id}/children
  Future<NodesIdChildrenGetResponse> nodesIdChildrenGet({required String id});

  /// Trace the node path back to the root
  /// get: /nodes/{id}/trace
  Future<NodesIdTraceGetResponse> nodesIdTraceGet({required String id});

  /// Get nodes by pathHash prefix (breadcrumbs)
  /// get: /nodes/path/{prefix}
  Future<NodesPathPrefixGetResponse> nodesPathPrefixGet(
      {required String prefix});
}

abstract class GraphNodeApiClient implements OpenApiClient {
  factory GraphNodeApiClient(
    Uri baseUri,
    OpenApiRequestSender requestSender,
  ) =>
      _GraphNodeApiClientImpl._(
        baseUri,
        requestSender,
      );

  /// Create a new node
  /// post: /nodes
  ///
  Future<NodesPostResponse> nodesPost(NodeCreate body);

  /// Get a node by ID
  /// get: /nodes/{id}
  ///
  Future<NodesIdGetResponse> nodesIdGet({required String id});

  /// Delete a node
  /// delete: /nodes/{id}
  ///
  Future<NodesIdDeleteResponse> nodesIdDelete({required String id});

  /// Update a node (content or pathHash only)
  /// patch: /nodes/{id}
  ///
  Future<NodesIdPatchResponse> nodesIdPatch(
    NodeUpdate body, {
    required String id,
  });

  /// Get children of a node
  /// get: /nodes/{id}/children
  ///
  Future<NodesIdChildrenGetResponse> nodesIdChildrenGet({required String id});

  /// Trace the node path back to the root
  /// get: /nodes/{id}/trace
  ///
  Future<NodesIdTraceGetResponse> nodesIdTraceGet({required String id});

  /// Get nodes by pathHash prefix (breadcrumbs)
  /// get: /nodes/path/{prefix}
  ///
  Future<NodesPathPrefixGetResponse> nodesPathPrefixGet(
      {required String prefix});
}

class _GraphNodeApiClientImpl extends OpenApiClientBase
    implements GraphNodeApiClient {
  _GraphNodeApiClientImpl._(
    this.baseUri,
    this.requestSender,
  );

  @override
  final Uri baseUri;

  @override
  final OpenApiRequestSender requestSender;

  /// Create a new node
  /// post: /nodes
  ///
  @override
  Future<NodesPostResponse> nodesPost(NodeCreate body) async {
    final request = OpenApiClientRequest(
      'post',
      '/nodes',
      [],
    );
    request.setHeader(
      'content-type',
      'application/json',
    );
    request.setBody(OpenApiClientRequestBodyJson(body.toJson()));
    return await sendRequest(
      request,
      {
        '201': (OpenApiClientResponse response) async =>
            NodesPostResponse201.response201(
                Node.fromJson(await response.responseBodyJson()))
      },
    );
  }

  /// Get a node by ID
  /// get: /nodes/{id}
  ///
  @override
  Future<NodesIdGetResponse> nodesIdGet({required String id}) async {
    final request = OpenApiClientRequest(
      'get',
      '/nodes/{id}',
      [],
    );
    request.addPathParameter(
      'id',
      encodeString(id),
    );
    return await sendRequest(
      request,
      {
        '200': (OpenApiClientResponse response) async =>
            NodesIdGetResponse200.response200(
                Node.fromJson(await response.responseBodyJson())),
        '404': (OpenApiClientResponse response) async =>
            NodesIdGetResponse404.response404(),
      },
    );
  }

  /// Delete a node
  /// delete: /nodes/{id}
  ///
  @override
  Future<NodesIdDeleteResponse> nodesIdDelete({required String id}) async {
    final request = OpenApiClientRequest(
      'delete',
      '/nodes/{id}',
      [],
    );
    request.addPathParameter(
      'id',
      encodeString(id),
    );
    return await sendRequest(
      request,
      {
        '204': (OpenApiClientResponse response) async =>
            NodesIdDeleteResponse204.response204(),
        '409': (OpenApiClientResponse response) async =>
            NodesIdDeleteResponse409.response409(),
      },
    );
  }

  /// Update a node (content or pathHash only)
  /// patch: /nodes/{id}
  ///
  @override
  Future<NodesIdPatchResponse> nodesIdPatch(
    NodeUpdate body, {
    required String id,
  }) async {
    final request = OpenApiClientRequest(
      'patch',
      '/nodes/{id}',
      [],
    );
    request.addPathParameter(
      'id',
      encodeString(id),
    );
    request.setHeader(
      'content-type',
      'application/json',
    );
    request.setBody(OpenApiClientRequestBodyJson(body.toJson()));
    return await sendRequest(
      request,
      {
        '200': (OpenApiClientResponse response) async =>
            NodesIdPatchResponse200.response200(
                Node.fromJson(await response.responseBodyJson()))
      },
    );
  }

  /// Get children of a node
  /// get: /nodes/{id}/children
  ///
  @override
  Future<NodesIdChildrenGetResponse> nodesIdChildrenGet(
      {required String id}) async {
    final request = OpenApiClientRequest(
      'get',
      '/nodes/{id}/children',
      [],
    );
    request.addPathParameter(
      'id',
      encodeString(id),
    );
    return await sendRequest(
      request,
      {
        '200': (OpenApiClientResponse response) async =>
            NodesIdChildrenGetResponse200.response200((await response
                    .responseBodyJsonDynamic() as List<dynamic>)
                .map((item) => Node.fromJson((item as Map<String, dynamic>)))
                .toList())
      },
    );
  }

  /// Trace the node path back to the root
  /// get: /nodes/{id}/trace
  ///
  @override
  Future<NodesIdTraceGetResponse> nodesIdTraceGet({required String id}) async {
    final request = OpenApiClientRequest(
      'get',
      '/nodes/{id}/trace',
      [],
    );
    request.addPathParameter(
      'id',
      encodeString(id),
    );
    return await sendRequest(
      request,
      {
        '200': (OpenApiClientResponse response) async =>
            NodesIdTraceGetResponse200.response200((await response
                    .responseBodyJsonDynamic() as List<dynamic>)
                .map((item) => Node.fromJson((item as Map<String, dynamic>)))
                .toList())
      },
    );
  }

  /// Get nodes by pathHash prefix (breadcrumbs)
  /// get: /nodes/path/{prefix}
  ///
  @override
  Future<NodesPathPrefixGetResponse> nodesPathPrefixGet(
      {required String prefix}) async {
    final request = OpenApiClientRequest(
      'get',
      '/nodes/path/{prefix}',
      [],
    );
    request.addPathParameter(
      'prefix',
      encodeString(prefix),
    );
    return await sendRequest(
      request,
      {
        '200': (OpenApiClientResponse response) async =>
            NodesPathPrefixGetResponse200.response200((await response
                    .responseBodyJsonDynamic() as List<dynamic>)
                .map((item) => Node.fromJson((item as Map<String, dynamic>)))
                .toList())
      },
    );
  }
}

class GraphNodeApiUrlResolve with OpenApiUrlEncodeMixin {
  /// Create a new node
  /// post: /nodes
  ///
  OpenApiClientRequest nodesPost() {
    final request = OpenApiClientRequest(
      'post',
      '/nodes',
      [],
    );
    return request;
  }

  /// Get a node by ID
  /// get: /nodes/{id}
  ///
  OpenApiClientRequest nodesIdGet({required String id}) {
    final request = OpenApiClientRequest(
      'get',
      '/nodes/{id}',
      [],
    );
    request.addPathParameter(
      'id',
      encodeString(id),
    );
    return request;
  }

  /// Delete a node
  /// delete: /nodes/{id}
  ///
  OpenApiClientRequest nodesIdDelete({required String id}) {
    final request = OpenApiClientRequest(
      'delete',
      '/nodes/{id}',
      [],
    );
    request.addPathParameter(
      'id',
      encodeString(id),
    );
    return request;
  }

  /// Update a node (content or pathHash only)
  /// patch: /nodes/{id}
  ///
  OpenApiClientRequest nodesIdPatch({required String id}) {
    final request = OpenApiClientRequest(
      'patch',
      '/nodes/{id}',
      [],
    );
    request.addPathParameter(
      'id',
      encodeString(id),
    );
    return request;
  }

  /// Get children of a node
  /// get: /nodes/{id}/children
  ///
  OpenApiClientRequest nodesIdChildrenGet({required String id}) {
    final request = OpenApiClientRequest(
      'get',
      '/nodes/{id}/children',
      [],
    );
    request.addPathParameter(
      'id',
      encodeString(id),
    );
    return request;
  }

  /// Trace the node path back to the root
  /// get: /nodes/{id}/trace
  ///
  OpenApiClientRequest nodesIdTraceGet({required String id}) {
    final request = OpenApiClientRequest(
      'get',
      '/nodes/{id}/trace',
      [],
    );
    request.addPathParameter(
      'id',
      encodeString(id),
    );
    return request;
  }

  /// Get nodes by pathHash prefix (breadcrumbs)
  /// get: /nodes/path/{prefix}
  ///
  OpenApiClientRequest nodesPathPrefixGet({required String prefix}) {
    final request = OpenApiClientRequest(
      'get',
      '/nodes/path/{prefix}',
      [],
    );
    request.addPathParameter(
      'prefix',
      encodeString(prefix),
    );
    return request;
  }
}

class GraphNodeApiRouter extends OpenApiServerRouterBase {
  GraphNodeApiRouter(this.impl);

  final ApiEndpointProvider<GraphNodeApi> impl;

  @override
  void configure() {
    addRoute(
      '/nodes',
      'post',
      (OpenApiRequest request) async {
        return await impl.invoke(
          request,
          (GraphNodeApi impl) async =>
              impl.nodesPost(NodeCreate.fromJson(await request.readJsonBody())),
        );
      },
      security: [],
    );
    addRoute(
      '/nodes/{id}',
      'get',
      (OpenApiRequest request) async {
        return await impl.invoke(
          request,
          (GraphNodeApi impl) async => impl.nodesIdGet(
              id: paramRequired(
            name: 'id',
            value: request.pathParameter('id'),
            decode: (value) => paramToString(value),
          )),
        );
      },
      security: [],
    );
    addRoute(
      '/nodes/{id}',
      'delete',
      (OpenApiRequest request) async {
        return await impl.invoke(
          request,
          (GraphNodeApi impl) async => impl.nodesIdDelete(
              id: paramRequired(
            name: 'id',
            value: request.pathParameter('id'),
            decode: (value) => paramToString(value),
          )),
        );
      },
      security: [],
    );
    addRoute(
      '/nodes/{id}',
      'patch',
      (OpenApiRequest request) async {
        return await impl.invoke(
          request,
          (GraphNodeApi impl) async => impl.nodesIdPatch(
            NodeUpdate.fromJson(await request.readJsonBody()),
            id: paramRequired(
              name: 'id',
              value: request.pathParameter('id'),
              decode: (value) => paramToString(value),
            ),
          ),
        );
      },
      security: [],
    );
    addRoute(
      '/nodes/{id}/children',
      'get',
      (OpenApiRequest request) async {
        return await impl.invoke(
          request,
          (GraphNodeApi impl) async => impl.nodesIdChildrenGet(
              id: paramRequired(
            name: 'id',
            value: request.pathParameter('id'),
            decode: (value) => paramToString(value),
          )),
        );
      },
      security: [],
    );
    addRoute(
      '/nodes/{id}/trace',
      'get',
      (OpenApiRequest request) async {
        return await impl.invoke(
          request,
          (GraphNodeApi impl) async => impl.nodesIdTraceGet(
              id: paramRequired(
            name: 'id',
            value: request.pathParameter('id'),
            decode: (value) => paramToString(value),
          )),
        );
      },
      security: [],
    );
    addRoute(
      '/nodes/path/{prefix}',
      'get',
      (OpenApiRequest request) async {
        return await impl.invoke(
          request,
          (GraphNodeApi impl) async => impl.nodesPathPrefixGet(
              prefix: paramRequired(
            name: 'prefix',
            value: request.pathParameter('prefix'),
            decode: (value) => paramToString(value),
          )),
        );
      },
      security: [],
    );
  }
}

class SecuritySchemes {}

T _throwStateError<T>(String message) => throw StateError(message);
