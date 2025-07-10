import 'package:kiss_repository/kiss_repository.dart';
import '../models/node.dart';
import 'node_queries.dart';

class NodeRepository {
  final Repository<Node> _repository;

  NodeRepository(this._repository);

  factory NodeRepository.inMemory() {
    return NodeRepository(
      InMemoryRepository<Node>(
        queryBuilder: NodeQueryBuilder(),
        path: 'nodes',
      ),
    );
  }

  Future<Node> add(Node node) async {
    return await _repository.add(IdentifiedObject(node.id, node));
  }

  Future<Node> get(String id) async {
    return await _repository.get(id);
  }

  Future<Node> update(String id, Node Function(Node current) updater) async {
    return await _repository.update(id, updater);
  }

  Future<void> delete(String id) async {
    final children = await getChildren(id);
    if (children.isNotEmpty) {
      throw RepositoryException(
        message: 'Cannot delete node with children',
        code: RepositoryErrorCode.unknown,
      );
    }
    await _repository.delete(id);
  }

  Future<List<Node>> getChildren(String parentId) async {
    return await _repository.query(query: NodeChildrenQuery(parentId));
  }

  Future<List<Node>> getSpatialNodes(String spatialPrefix) async {
    return await _repository.query(query: NodeSpatialQuery(spatialPrefix));
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
        if (e is RepositoryException && e.code == RepositoryErrorCode.notFound) {
          break;
        }
        rethrow;
      }
    }
    
    return path;
  }

  Future<List<Node>> query({Query? query}) async {
    if (query != null) {
      return await _repository.query(query: query);
    } else {
      return await _repository.query();
    }
  }

  Stream<Node> stream(String id) {
    return _repository.stream(id);
  }

  Stream<List<Node>> streamQuery({Query? query}) {
    if (query != null) {
      return _repository.streamQuery(query: query);
    } else {
      return _repository.streamQuery();
    }
  }

  void dispose() {
    _repository.dispose();
  }
}