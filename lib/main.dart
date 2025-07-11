import 'package:kiss_graph/api/graph-node-api.openapi.dart';
import 'package:kiss_graph/api/node_api_service.dart';
import 'package:kiss_graph/repositories/node_queries.dart';
import 'package:kiss_graph/services/node_service.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  final app = Router().plus;

  // Initialize dependencies
  final nodeRepository = InMemoryRepository<Node>(
    queryBuilder: NodeQueryBuilder(),
    path: 'nodes',
  );
  final nodeService = NodeService(nodeRepository);
  final nodeApiService = NodeApiService(nodeService);

  // Add logging middleware
  app.use(logRequests());

  // Setup routes
  nodeApiService.setupRoutes(app);

  return app.call;
}
