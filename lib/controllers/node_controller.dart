import 'dart:convert';

import 'package:kiss_repository/kiss_repository.dart';
import 'package:shelf_plus/shelf_plus.dart';

import '../graph-node-api.openapi.dart';
import '../services/node_service.dart';

class NodeController {
  final NodeService _nodeService;

  NodeController(this._nodeService);

  void setupRoutes(RouterPlus app) {
    app.post('/nodes', _createNode);
    app.get('/nodes/<id>', _getNode);
    app.patch('/nodes/<id>', _updateNode);
    app.delete('/nodes/<id>', _deleteNode);
    app.get('/nodes/<id>/children', _getChildren);
    app.get('/nodes/<id>/trace', _trace);
    app.get('/nodes/spatial/<prefix>', _getSpatialNodes);
  }

  Future<Response> _createNode(Request request) async {
    try {
      final bodyJson = await request.body.asJson;
      final nodeCreate = NodeCreate.fromJson(bodyJson);
      final node = await _nodeService.createNode(nodeCreate);

      return Response(
        201,
        body: jsonEncode(node.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
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
    } catch (e) {
      return _errorResponse(500, e.toString());
    }
  }

  Future<Response> _updateNode(Request request) async {
    try {
      final id = request.params['id']!;
      final bodyJson = await request.body.asJson;
      final nodeUpdate = NodeUpdate.fromJson(bodyJson);
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
    } catch (e) {
      return _errorResponse(500, e.toString());
    }
  }

  Future<Response> _deleteNode(Request request) async {
    try {
      final id = request.params['id']!;
      await _nodeService.deleteNode(id);

      return Response(204);
    } catch (e) {
      // Check for specific business rule violations first
      if (e.toString().contains('Cannot delete node with children')) {
        return _errorResponse(409, 'Cannot delete node with children');
      }

      // Then handle repository exceptions
      if (e is RepositoryException) {
        if (e.code == RepositoryErrorCode.notFound) {
          return _errorResponse(404, 'Node not found');
        }
        return _errorResponse(500, e.message);
      }

      // Handle any other exceptions
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
    } catch (e) {
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
    } catch (e) {
      return _errorResponse(500, e.toString());
    }
  }

  Future<Response> _getSpatialNodes(Request request) async {
    try {
      final prefix = request.params['prefix']!;
      final nodes = await _nodeService.getSpatialNodes(prefix);

      return Response.ok(
        jsonEncode(nodes.map((node) => node.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
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
