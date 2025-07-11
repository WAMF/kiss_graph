/// A graph node service library with dependency injection support.
///
/// This library provides a complete graph node service implementation
/// that can work with any Repository<Node> implementation from kiss_repository.
///
/// Example usage:
/// ```dart
/// import 'package:kiss_graph/kiss_graph.dart';
/// import 'package:kiss_repository/kiss_repository.dart';
///
/// final repository = InMemoryRepository<Node>(
///   queryBuilder: NodeQueryBuilder(),
///   path: 'nodes',
/// );
///
/// final nodeService = NodeService(repository);
/// final nodeApiService = NodeApiService(nodeService);
///
/// nodeApiService.setupRoutes(app);
/// ```
library;

export 'api/graph-node-api.openapi.dart';
export 'api/graph_api_configuration.dart';
export 'api/node_api_service.dart';
export 'models/node_extensions.dart';
export 'repositories/node_queries.dart';
export 'services/node_service.dart';
