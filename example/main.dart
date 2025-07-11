import 'package:kiss_graph/kiss_graph.dart';
import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  final app = Router().plus;

  final config = GraphApiConfiguration.withInMemoryRepository();

  app.use(logRequests());
  config.setupRoutes(app);

  return app.call;
}
