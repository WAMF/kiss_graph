import 'integration/simple_api_test.dart' as api_integration_tests;
import 'unit/models/node_test.dart' as node_model_tests;
import 'unit/repositories/node_repository_test.dart' as node_repository_tests;
import 'unit/services/node_service_test.dart' as node_service_tests;

void main() {
  node_model_tests.main();
  node_repository_tests.main();
  node_service_tests.main();
  api_integration_tests.main();
}
