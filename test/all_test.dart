import 'integration/simple_api_test.dart' as api_integration_tests;
import 'unit/api/node_api_error_handling_test.dart' as api_error_tests;
import 'unit/dependencies_test.dart' as dependencies_tests;
import 'unit/models/node_test.dart' as node_model_tests;
import 'unit/repositories/node_repository_test.dart' as node_repository_tests;
import 'unit/services/node_service_test.dart' as node_service_tests;

void main() {
  dependencies_tests.main();
  node_model_tests.main();
  node_repository_tests.main();
  node_service_tests.main();
  api_error_tests.main();
  api_integration_tests.main();
}
