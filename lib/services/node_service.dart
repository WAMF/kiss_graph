import 'package:kiss_repository/kiss_repository.dart';
import 'package:uuid/uuid.dart';

import '../graph-node-api.openapi.dart';
import '../models/node_extensions.dart';
import '../repositories/node_queries.dart';

class NodeService {
  final Repository<Node> _repository;
  final Uuid _uuid = const Uuid();

  NodeService(this._repository);

  Future<Node> createNode(NodeCreate nodeCreate) async {
    nodeCreate.validate(); // Validate input

    String id = _uuid.v4();
    String rootId = id;

    final previousId = nodeCreate.validPrevious;
    if (previousId != null) {
      try {
        final parentNode = await _repository.get(previousId);
        rootId = parentNode.validRoot;
      } catch (e) {
        throw Exception('Parent node not found: $previousId');
      }
    }

    final node = NodeExtensions.create(
      id: id,
      root: rootId,
      previous: previousId,
      spatialHash: nodeCreate.spatialHash,
      content: nodeCreate.content.toMap(),
    );

    // Use generic repository interface
    node.validate(); // Ensure node has valid required fields
    return await _repository.add(IdentifiedObject(node.validId, node));
  }

  Future<Node> getNode(String id) async {
    return await _repository.get(id);
  }

  Future<Node> updateNode(String id, NodeUpdate nodeUpdate) async {
    return await _repository.update(id, (current) {
      return current.copyWith(
        spatialHash: nodeUpdate.spatialHash ?? current.spatialHash,
        content: nodeUpdate.content?.toMap() ?? current.contentMap,
      );
    });
  }

  Future<void> deleteNode(String id) async {
    // Business logic: prevent deletion of nodes with children
    final children = await _repository.query(query: NodeChildrenQuery(id));
    if (children.isNotEmpty) {
      throw RepositoryException(
        message: 'Cannot delete node with children',
        code: RepositoryErrorCode.unknown,
      );
    }

    await _repository.delete(id);
  }

  Future<List<Node>> getChildren(String id) async {
    return await _repository.query(query: NodeChildrenQuery(id));
  }

  Future<List<Node>> trace(String nodeId) async {
    final List<Node> path = [];
    String? currentId = nodeId;

    while (currentId != null) {
      try {
        final node = await _repository.get(currentId);
        node.validate(); // Ensure we have a valid node
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
    return await _repository.query(query: NodeSpatialQuery(spatialPrefix));
  }

  Future<List<Node>> getNodesByRoot(String rootId) async {
    return await _repository.query(query: NodeRootQuery(rootId));
  }

  Future<List<Node>> getAllNodes() async {
    return await _repository.query();
  }

  void dispose() {
    _repository.dispose();
  }
}
