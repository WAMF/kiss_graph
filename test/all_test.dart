// All tests runner
// This file imports all test suites to run them together

// Integration Tests
import 'integration/simple_api_test.dart' as api_integration_tests;
// Unit Tests
import 'unit/models/node_test.dart' as node_model_tests;
import 'unit/repositories/node_repository_test.dart' as node_repository_tests;
import 'unit/services/node_service_test.dart' as node_service_tests;

void main() {
  // Run all unit tests
  node_model_tests.main();
  node_repository_tests.main();
  node_service_tests.main();

  // Run all integration tests
  api_integration_tests.main();
}
