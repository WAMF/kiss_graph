import 'package:kiss_graph/api/graph-node-api.openapi.dart';
import 'package:kiss_graph/models/node_extensions.dart';
import 'package:kiss_graph/repositories/node_queries.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:uuid/uuid.dart';

class NodeService {
  NodeService(this._repository);
  final Repository<Node> _repository;
  final Uuid _uuid = const Uuid();

  Future<Node> createNode(NodeCreate nodeCreate) async {
    nodeCreate.validate();

    final id = _uuid.v4();
    var rootId = id;
    String pathHash;

    final previousId = nodeCreate.validPrevious;
    if (previousId != null) {
      try {
        final parentNode = await _repository.get(previousId);
        rootId = parentNode.validRoot;

        final parentPath = parentNode.validPathHash;
        final siblingCount = await _getSiblingCount(previousId);
        pathHash =
            PathHashGenerator.generateChildPath(parentPath, siblingCount + 1);
      } on RepositoryException {
        throw Exception('Parent node not found: $previousId');
      }
    } else {
      pathHash = nodeCreate.pathHash ?? PathHashGenerator.generateRootPath();
    }

    final node = NodeExtensions.create(
      id: id,
      root: rootId,
      previous: previousId,
      pathHash: pathHash,
      content: nodeCreate.content.toMap(),
    );

    node.validate();
    return _repository.add(IdentifiedObject(node.validId, node));
  }

  /// Retrieves a node by its unique ID
  Future<Node> getNode(String id) async {
    return _repository.get(id);
  }

  /// Updates a node's pathHash or content
  Future<Node> updateNode(String id, NodeUpdate nodeUpdate) async {
    return _repository.update(id, (current) {
      return current.copyWith(
        pathHash: nodeUpdate.pathHash ?? current.pathHash,
        content: nodeUpdate.content?.toMap() ?? current.contentMap,
      );
    });
  }

  /// Deletes a node if it has no children
  Future<void> deleteNode(String id) async {
    final children = await _repository.query(query: NodeChildrenQuery(id));
    if (children.isNotEmpty) {
      throw RepositoryException(
        message: 'Cannot delete node with children',
      );
    }

    await _repository.delete(id);
  }

  /// Gets all direct children of a node
  Future<List<Node>> getChildren(String id) async {
    return _repository.query(query: NodeChildrenQuery(id));
  }

  /// Traces the path from a node back to its root
  Future<List<Node>> trace(String nodeId) async {
    final path = <Node>[];
    String? currentId = nodeId;

    while (currentId != null) {
      try {
        final node = await _repository.get(currentId);
        node.validate();
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

  /// Gets all nodes with pathHash starting with the given prefix
  Future<List<Node>> getPathNodes(String pathPrefix) async {
    return _repository.query(query: NodePathQuery(pathPrefix));
  }

  Future<int> _getSiblingCount(String parentId) async {
    final children =
        await _repository.query(query: NodeChildrenQuery(parentId));
    return children.length;
  }

  Future<List<Node>> getNodesByRoot(String rootId) async {
    return _repository.query(query: NodeRootQuery(rootId));
  }

  Future<List<Node>> getAllNodes() async {
    return _repository.query();
  }

  void dispose() {
    _repository.dispose();
  }
}
