import 'package:kiss_graph/graph-node-api.openapi.dart';
import 'package:kiss_graph/repositories/node_queries.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:shelf_plus/shelf_plus.dart';

import 'controllers/node_controller.dart';
import 'services/node_service.dart';

void main() => shelfRun(init);

Handler init() {
  final app = Router().plus;

  // Initialize dependencies
  final nodeRepository = InMemoryRepository<Node>(
    queryBuilder: NodeQueryBuilder(),
    path: 'nodes',
  );
  final nodeService = NodeService(nodeRepository);
  final nodeController = NodeController(nodeService);

  // Add logging middleware
  app.use(logRequests());

  // Setup routes
  nodeController.setupRoutes(app);

  return app.call;
}
