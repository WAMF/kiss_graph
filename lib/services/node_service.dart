import 'package:kiss_repository/kiss_repository.dart';
import 'package:uuid/uuid.dart';

import '../api/graph-node-api.openapi.dart';
import '../models/node_extensions.dart';
import '../repositories/node_queries.dart';

class NodeService {
  final Repository<Node> _repository;
  final Uuid _uuid = const Uuid();

  NodeService(this._repository);

  Future<Node> createNode(NodeCreate nodeCreate) async {
    nodeCreate.validate();

    String id = _uuid.v4();
    String rootId = id;
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
      } catch (e) {
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
    return await _repository.add(IdentifiedObject(node.validId, node));
  }

  Future<Node> getNode(String id) async {
    return await _repository.get(id);
  }

  Future<Node> updateNode(String id, NodeUpdate nodeUpdate) async {
    return await _repository.update(id, (current) {
      return current.copyWith(
        pathHash: nodeUpdate.pathHash ?? current.pathHash,
        content: nodeUpdate.content?.toMap() ?? current.contentMap,
      );
    });
  }

  Future<void> deleteNode(String id) async {
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

  Future<List<Node>> getPathNodes(String pathPrefix) async {
    return await _repository.query(query: NodePathQuery(pathPrefix));
  }

  /// Get all nodes in the breadcrumb path for a given node
  Future<List<Node>> getBreadcrumbs(String nodeId) async {
    final node = await _repository.get(nodeId);
    final ancestorPaths =
        PathHashGenerator.getAncestorPaths(node.validPathHash);

    final breadcrumbs = <Node>[];
    for (final path in ancestorPaths) {
      final pathNodes = await _repository.query(query: NodePathQuery(path));
      final exactMatch =
          pathNodes.where((n) => n.validPathHash == path).firstOrNull;
      if (exactMatch != null) {
        breadcrumbs.add(exactMatch);
      }
    }

    return breadcrumbs;
  }

  Future<int> _getSiblingCount(String parentId) async {
    final children =
        await _repository.query(query: NodeChildrenQuery(parentId));
    return children.length;
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
