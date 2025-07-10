import 'package:shelf_plus/shelf_plus.dart';
import 'controllers/node_controller.dart';
import 'repositories/node_repository.dart';
import 'services/node_service.dart';

void main() => shelfRun(init);

Handler init() {
  final app = Router().plus;
  
  // Initialize dependencies
  final nodeRepository = NodeRepository.inMemory();
  final nodeService = NodeService(nodeRepository);
  final nodeController = NodeController(nodeService);
  
  // Add logging middleware
  app.use(logRequests());
  
  // Setup routes
  nodeController.setupRoutes(app);
  
  return app.call;
}