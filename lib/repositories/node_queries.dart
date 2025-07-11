import 'package:kiss_graph/api/graph-node-api.openapi.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:meta/meta.dart';

@immutable
class NodeChildrenQuery extends Query {
  const NodeChildrenQuery(this.parentId);
  final String parentId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NodeChildrenQuery && other.parentId == parentId;
  }

  @override
  int get hashCode => parentId.hashCode;
}

@immutable
class NodePathQuery extends Query {
  const NodePathQuery(this.pathPrefix);
  final String pathPrefix;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NodePathQuery && other.pathPrefix == pathPrefix;
  }

  @override
  int get hashCode => pathPrefix.hashCode;
}

@immutable
class NodeRootQuery extends Query {
  const NodeRootQuery(this.rootId);
  final String rootId;

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

    if (query is NodePathQuery) {
      return InMemoryFilterQuery<Node>(
          (node) => node.pathHash?.startsWith(query.pathPrefix) ?? false);
    }

    if (query is NodeRootQuery) {
      return InMemoryFilterQuery<Node>((node) => node.root == query.rootId);
    }

    return InMemoryFilterQuery<Node>((node) => true);
  }
}
