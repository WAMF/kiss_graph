# Kiss Graph API Test Suite

This project uses the standard Dart test framework for comprehensive testing.

## Test Structure

```
test/
├── helpers/
│   └── test_helpers.dart          # Test utilities and mock data
├── unit/
│   ├── models/node_test.dart      # Model serialization/validation tests  
│   ├── repositories/node_repository_test.dart # Repository CRUD/query tests
│   └── services/node_service_test.dart        # Business logic tests
└── integration/
    └── simple_api_test.dart       # Full API endpoint tests
```

## Running Tests

### Run All Tests
```bash
dart test
```

### Run Specific Test Files
```bash
# Unit tests
dart test test/unit/models/node_test.dart
dart test test/unit/repositories/node_repository_test.dart
dart test test/unit/services/node_service_test.dart

# Integration tests
dart test test/integration/simple_api_test.dart
```

### Run Tests by Pattern
```bash
# Run all unit tests
dart test test/unit/

# Run all integration tests  
dart test test/integration/

# Run tests with specific name pattern
dart test --name="should create"
dart test --name="Node*"
```

### Test Output Options
```bash
# Verbose output
dart test --reporter=expanded

# Quiet output (only failures)
dart test --reporter=compact

# Run in watch mode (rerun on file changes)
dart test --watch
```

## Test Coverage

### Unit Tests (120+ tests)
- **Models**: JSON serialization, validation, copyWith functionality
- **Repository**: CRUD operations, queries, streaming, batch operations  
- **Service**: Business logic, validation rules, trace functionality

### Integration Tests (8+ tests)
- **API Endpoints**: All HTTP endpoints with success/error cases
- **End-to-End Flows**: Complete request/response cycles
- **Business Rules**: Parent-child relationships, spatial queries

## Test Features

✅ **Comprehensive Coverage**: Tests all layers from models to API endpoints  
✅ **Business Logic Validation**: Deletion rules, trace functionality, spatial queries  
✅ **Error Handling**: 404s, validation errors, malformed requests  
✅ **Real Scenarios**: Parent-child relationships, deep chains, spatial filtering  
✅ **Clean Architecture**: Proper separation between unit and integration tests

## Development Workflow

```bash
# During development - watch mode for immediate feedback
dart test --watch

# Before committing - run all tests
dart test

# Check specific functionality
dart test --name="trace"
dart test test/unit/services/node_service_test.dart --name="deletion"
``` 
