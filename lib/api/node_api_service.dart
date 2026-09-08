import 'dart:convert';
import 'dart:developer' as developer;

import 'package:kiss_graph/api/graph-node-api.openapi.dart';
import 'package:kiss_graph/services/node_service.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:shelf_plus/shelf_plus.dart';

/// Receives the full detail of a failure that the API handled.
///
/// The API never puts this detail in an HTTP response. Use this sink to
/// record it server-side.
typedef ApiErrorLogger = void Function(
  Object error,
  StackTrace stackTrace,
  String operation,
);

void _logToDeveloper(Object error, StackTrace stackTrace, String operation) {
  developer.log(
    'kiss_graph: $operation failed',
    name: 'kiss_graph',
    error: error,
    stackTrace: stackTrace,
  );
}

class NodeApiService {
  /// Creates the API service.
  ///
  /// [onError] receives the full detail of every failure. It defaults to
  /// `dart:developer` logging. The detail never reaches an HTTP response.
  NodeApiService(this._nodeService, {ApiErrorLogger? onError})
      : _onError = onError ?? _logToDeveloper;

  final NodeService _nodeService;
  final ApiErrorLogger _onError;

  /// The only message a client sees for a failure inside the server.
  static const String internalErrorMessage = 'Internal server error';

  /// The only message a client sees for a request body it sent wrongly.
  static const String invalidRequestMessage = 'Invalid request body';

  static const String _notFoundMessage = 'Node not found';
  static const String _parentNotFoundMessage = 'Parent node not found';
  static const String _hasChildrenMessage = NodeService.hasChildrenMessage;

  void setupRoutes(RouterPlus app) {
    app
      ..post('/nodes', _createNode)
      ..get('/nodes/<id>', _getNode)
      ..patch('/nodes/<id>', _updateNode)
      ..delete('/nodes/<id>', _deleteNode)
      ..get('/nodes/<id>/children', _getChildren)
      ..get('/nodes/<id>/trace', _trace)
      ..get('/nodes/path/<prefix>', _getPathNodes);
  }

  Future<Response> _createNode(Request request) async {
    try {
      final bodyJson = await request.body.asJson;
      final nodeCreate = NodeCreate.fromJson(bodyJson as Map<String, dynamic>);
      final node = await _nodeService.createNode(nodeCreate);

      return Response(
        201,
        body: jsonEncode(node.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      if (e is RepositoryException) {
        if (e.code == RepositoryErrorCode.notFound) {
          return _reportedResponse(
              400, _parentNotFoundMessage, e, stackTrace, 'createNode');
        }
        return _internalError(e, stackTrace, 'createNode');
      }
      // A malformed body reaches us as ArgumentError (model validation),
      // FormatException (JSON parsing) or TypeError (wrong JSON shape).
      // These are all faults in what the client sent, so they answer 400.
      if (e is ArgumentError || e is FormatException || e is TypeError) {
        return _reportedResponse(
            400, invalidRequestMessage, e, stackTrace, 'createNode');
      }
      return _internalError(e, stackTrace, 'createNode');
    }
  }

  Future<Response> _getNode(Request request) async {
    try {
      final id = request.params['id']!;
      final node = await _nodeService.getNode(id);

      return Response.ok(
        jsonEncode(node.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on RepositoryException catch (e, stackTrace) {
      if (e.code == RepositoryErrorCode.notFound) {
        return _errorResponse(404, _notFoundMessage);
      }
      return _internalError(e, stackTrace, 'getNode');
    } catch (e, stackTrace) {
      return _internalError(e, stackTrace, 'getNode');
    }
  }

  Future<Response> _updateNode(Request request) async {
    try {
      final id = request.params['id']!;
      final bodyJson = await request.body.asJson;
      final nodeUpdate = NodeUpdate.fromJson(bodyJson as Map<String, dynamic>);
      final node = await _nodeService.updateNode(id, nodeUpdate);

      return Response.ok(
        jsonEncode(node.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on RepositoryException catch (e, stackTrace) {
      if (e.code == RepositoryErrorCode.notFound) {
        return _errorResponse(404, _notFoundMessage);
      }
      return _internalError(e, stackTrace, 'updateNode');
    } catch (e, stackTrace) {
      return _internalError(e, stackTrace, 'updateNode');
    }
  }

  Future<Response> _deleteNode(Request request) async {
    try {
      final id = request.params['id']!;
      await _nodeService.deleteNode(id);

      return Response(204);
    } on RepositoryException catch (e, stackTrace) {
      if (e.message == _hasChildrenMessage) {
        return _errorResponse(409, _hasChildrenMessage);
      }
      if (e.code == RepositoryErrorCode.notFound) {
        return _errorResponse(404, _notFoundMessage);
      }
      return _internalError(e, stackTrace, 'deleteNode');
    } catch (e, stackTrace) {
      return _internalError(e, stackTrace, 'deleteNode');
    }
  }

  Future<Response> _getChildren(Request request) async {
    try {
      final id = request.params['id']!;
      final children = await _nodeService.getChildren(id);

      return Response.ok(
        jsonEncode(children.map((node) => node.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      return _internalError(e, stackTrace, 'getChildren');
    }
  }

  Future<Response> _trace(Request request) async {
    try {
      final id = request.params['id']!;
      final path = await _nodeService.trace(id);

      return Response.ok(
        jsonEncode(path.map((node) => node.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      return _internalError(e, stackTrace, 'trace');
    }
  }

  Future<Response> _getPathNodes(Request request) async {
    try {
      final prefix = request.params['prefix']!;
      final nodes = await _nodeService.getPathNodes(prefix);

      return Response.ok(
        jsonEncode(nodes.map((node) => node.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, stackTrace) {
      return _internalError(e, stackTrace, 'getPathNodes');
    }
  }

  /// Reports [error] to the server-side sink and answers with [message].
  ///
  /// [message] is a constant. It never carries text taken from [error].
  Response _reportedResponse(
    int statusCode,
    String message,
    Object error,
    StackTrace stackTrace,
    String operation,
  ) {
    _onError(error, stackTrace, operation);
    return _errorResponse(statusCode, message);
  }

  Response _internalError(
    Object error,
    StackTrace stackTrace,
    String operation,
  ) {
    return _reportedResponse(
        500, internalErrorMessage, error, stackTrace, operation);
  }

  Response _errorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: jsonEncode({'error': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
