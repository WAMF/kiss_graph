import 'package:kiss_repository/kiss_repository.dart';
import 'package:uuid/uuid.dart';

import '../models/node.dart';
import '../repositories/node_repository.dart';

class NodeService {
  final NodeRepository _repository;
  final Uuid _uuid = const Uuid();

  NodeService(this._repository);

  Future<Node> createNode(NodeCreate nodeCreate) async {
    String id = _uuid.v4();
    String rootId = id;

    if (nodeCreate.previous != null) {
      try {
        final parentNode = await _repository.get(nodeCreate.previous!);
        rootId = parentNode.root;
      } catch (e) {
        throw Exception('Parent node not found: ${nodeCreate.previous}');
      }
    }

    final node = Node(
      id: id,
      root: rootId,
      previous: nodeCreate.previous,
      spatialHash: nodeCreate.spatialHash,
      content: nodeCreate.content,
    );

    return await _repository.addNode(node);
  }

  Future<Node> getNode(String id) async {
    return await _repository.get(id);
  }

  Future<Node> updateNode(String id, NodeUpdate nodeUpdate) async {
    return await _repository.update(id, (current) {
      return current.copyWith(
        spatialHash: nodeUpdate.spatialHash ?? current.spatialHash,
        content: nodeUpdate.content ?? current.content,
      );
    });
  }

  Future<void> deleteNode(String id) async {
    // Business logic: prevent deletion of nodes with children
    final children = await _repository.getChildren(id);
    if (children.isNotEmpty) {
      throw RepositoryException(
        message: 'Cannot delete node with children',
        code: RepositoryErrorCode.unknown,
      );
    }

    await _repository.delete(id);
  }

  Future<List<Node>> getChildren(String id) async {
    return await _repository.getChildren(id);
  }

  Future<List<Node>> trace(String nodeId) async {
    final List<Node> path = [];
    String? currentId = nodeId;

    while (currentId != null) {
      try {
        final node = await _repository.get(currentId);
        path.add(node);
        currentId = node.previous;
      } catch (e) {
        if (e is RepositoryException &&
            e.code == RepositoryErrorCode.notFound) {
          break;
        }
        rethrow;
      }
    }

    return path;
  }

  Future<List<Node>> getSpatialNodes(String spatialPrefix) async {
    return await _repository.getSpatialNodes(spatialPrefix);
  }

  Future<List<Node>> getNodesByRoot(String rootId) async {
    return await _repository.getByRoot(rootId);
  }

  Future<List<Node>> getAllNodes() async {
    return await _repository.query();
  }

  void dispose() {
    _repository.dispose();
  }
}
