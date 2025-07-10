import 'package:kiss_repository/kiss_repository.dart';

import '../models/node.dart';
import 'node_queries.dart';

class NodeRepository extends InMemoryRepository<Node> {
  NodeRepository()
      : super(
          queryBuilder: NodeQueryBuilder(),
          path: 'nodes',
        );

  // Domain-specific convenience methods
  Future<Node> addNode(Node node) async {
    return await add(IdentifiedObject(node.id, node));
  }

  Future<List<Node>> getChildren(String parentId) async {
    return await query(query: NodeChildrenQuery(parentId));
  }

  Future<List<Node>> getSpatialNodes(String spatialPrefix) async {
    return await query(query: NodeSpatialQuery(spatialPrefix));
  }

  Future<List<Node>> getByRoot(String rootId) async {
    return await query(query: NodeRootQuery(rootId));
  }
}
