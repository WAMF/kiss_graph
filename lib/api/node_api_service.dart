import 'dart:convert';

import 'package:kiss_graph/api/graph-node-api.openapi.dart';
import 'package:kiss_graph/services/node_service.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:shelf_plus/shelf_plus.dart';

class NodeApiService {
  NodeApiService(this._nodeService);
  final NodeService _nodeService;

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
    } on Exception catch (e) {
      return _errorResponse(400, e.toString());
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
    } on RepositoryException catch (e) {
      if (e.code == RepositoryErrorCode.notFound) {
        return _errorResponse(404, 'Node not found');
      }
      return _errorResponse(500, e.message);
    } on Exception catch (e) {
      return _errorResponse(500, e.toString());
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
    } on RepositoryException catch (e) {
      if (e.code == RepositoryErrorCode.notFound) {
        return _errorResponse(404, 'Node not found');
      }
      return _errorResponse(500, e.message);
    } on Exception catch (e) {
      return _errorResponse(500, e.toString());
    }
  }

  Future<Response> _deleteNode(Request request) async {
    try {
      final id = request.params['id']!;
      await _nodeService.deleteNode(id);

      return Response(204);
    } catch (e) {
      if (e.toString().contains('Cannot delete node with children')) {
        return _errorResponse(409, 'Cannot delete node with children');
      }

      if (e is RepositoryException) {
        if (e.code == RepositoryErrorCode.notFound) {
          return _errorResponse(404, 'Node not found');
        }
        return _errorResponse(500, e.message);
      }

      return _errorResponse(500, e.toString());
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
    } on Exception catch (e) {
      return _errorResponse(500, e.toString());
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
    } on Exception catch (e) {
      return _errorResponse(500, e.toString());
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
    } on Exception catch (e) {
      return _errorResponse(500, e.toString());
    }
  }

  Response _errorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: jsonEncode({'error': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
