import 'package:kiss_graph/api/graph-node-api.openapi.dart';
import 'package:kiss_graph/api/node_api_service.dart';
import 'package:kiss_graph/repositories/node_queries.dart';
import 'package:kiss_graph/services/node_service.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:shelf_plus/shelf_plus.dart';

/// Configuration class for the KISS Graph library.
///
/// This class provides a simple way to configure dependency injection
/// for the graph node service, allowing users to inject their own
/// repository implementations while providing sensible defaults.
///
/// Example usage:
/// ```dart
/// // With custom repository
/// final config = GraphApiConfiguration(
///   repository: myCustomRepository,
/// );
/// final apiService = config.createApiService();
///
/// // With default in-memory repository
/// final config = GraphApiConfiguration.withInMemoryRepository();
/// final apiService = config.createApiService();
/// ```
class GraphApiConfiguration {

  /// Create a configuration with a custom repository.
  GraphApiConfiguration({required Repository<Node> repository})
      : _repository = repository {
    _nodeService = NodeService(_repository);
    _nodeApiService = NodeApiService(_nodeService);
  }

  /// Create a configuration with an in-memory repository for testing/demos.
  ///
  /// This uses the default InMemoryRepository with NodeQueryBuilder
  /// which is suitable for development, testing, and demos.
  factory GraphApiConfiguration.withInMemoryRepository({String? path}) {
    final repository = InMemoryRepository<Node>(
      queryBuilder: NodeQueryBuilder(),
      path: path ?? 'nodes',
    );
    return GraphApiConfiguration(repository: repository);
  }
  final Repository<Node> _repository;
  late final NodeService _nodeService;
  late final NodeApiService _nodeApiService;

  /// Get the configured repository instance.
  Repository<Node> get repository => _repository;

  /// Get the configured node service instance.
  NodeService get nodeService => _nodeService;

  /// Get the configured API service instance.
  NodeApiService get nodeApiService => _nodeApiService;

  /// Create and return the API service ready for use.
  ///
  /// This is a convenience method that returns the fully configured
  /// NodeApiService instance.
  NodeApiService createApiService() => _nodeApiService;

  /// Set up routes on a Router instance.
  ///
  /// This is a convenience method that calls setupRoutes on the
  /// configured NodeApiService.
  void setupRoutes(RouterPlus app) {
    _nodeApiService.setupRoutes(app);
  }

  /// Dispose of all resources.
  ///
  /// This should be called when the application is shutting down
  /// to properly clean up resources like streams and connections.
  void dispose() {
    _nodeService.dispose();
  }
}
