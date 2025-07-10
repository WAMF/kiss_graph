import 'package:kiss_repository/kiss_repository.dart';

import '../graph-node-api.openapi.dart';

class NodeChildrenQuery extends Query {
  final String parentId;

  const NodeChildrenQuery(this.parentId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NodeChildrenQuery && other.parentId == parentId;
  }

  @override
  int get hashCode => parentId.hashCode;
}

class NodeSpatialQuery extends Query {
  final String spatialPrefix;

  const NodeSpatialQuery(this.spatialPrefix);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NodeSpatialQuery && other.spatialPrefix == spatialPrefix;
  }

  @override
  int get hashCode => spatialPrefix.hashCode;
}

class NodeRootQuery extends Query {
  final String rootId;

  const NodeRootQuery(this.rootId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NodeRootQuery && other.rootId == rootId;
  }

  @override
  int get hashCode => rootId.hashCode;
}

class NodeQueryBuilder implements QueryBuilder<InMemoryFilterQuery<Node>> {
  @override
  InMemoryFilterQuery<Node> build(Query query) {
    if (query is NodeChildrenQuery) {
      return InMemoryFilterQuery<Node>(
          (node) => node.previous == query.parentId);
    }

    if (query is NodeSpatialQuery) {
      return InMemoryFilterQuery<Node>(
          (node) => node.spatialHash?.startsWith(query.spatialPrefix) ?? false);
    }

    if (query is NodeRootQuery) {
      return InMemoryFilterQuery<Node>((node) => node.root == query.rootId);
    }

    return InMemoryFilterQuery<Node>((node) => true);
  }
}
