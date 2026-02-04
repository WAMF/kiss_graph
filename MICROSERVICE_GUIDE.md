# KISS Microservice Development Guide

A comprehensive guide for building microservices using the kiss_repository ecosystem and clean architecture principles, following a consistent, scalable pattern.

## Table of Contents

1. [Overview](#overview)
2. [Architecture Pattern](#architecture-pattern)
3. [Project Structure](#project-structure)
4. [Dependencies](#dependencies)
5. [Implementation Steps](#implementation-steps)
6. [Code Patterns](#code-patterns)
7. [Testing Strategy](#testing-strategy)
8. [API Documentation](#api-documentation)
9. [Configuration & DI](#configuration--dependency-injection)
10. [Best Practices](#best-practices)
11. [Examples](#examples)

## Overview

This guide outlines how to build microservices that follow a consistent architectural pattern, emphasizing:

- **Clean Architecture**: Clear separation of concerns across layers
- **Repository Pattern**: Consistent data access via `kiss_repository`
- **Dependency Injection**: Flexible configuration through DI
- **API-First**: OpenAPI specification-driven development
- **Comprehensive Testing**: Unit, integration, and API tests
- **Package Design**: Reusable libraries with example implementations

## Architecture Pattern

### Layer Structure

```
┌─────────────────┐
│   API Layer     │  ← HTTP endpoints, request/response handling
├─────────────────┤
│ Service Layer   │  ← Business logic, orchestration
├─────────────────┤
│Repository Layer │  ← Data access abstraction (kiss_repository)
├─────────────────┤
│  Model Layer    │  ← Domain objects, extensions, validation
└─────────────────┘
```

### Key Principles

1. **Repository Pattern**: All data access through `Repository<T>` interfaces
2. **Service Layer**: Business logic separate from HTTP concerns
3. **Configuration Pattern**: DI through configuration classes
4. **Validation**: Domain validation in models, API validation at boundaries
5. **Error Handling**: Consistent error responses across all endpoints

## Project Structure

```
your_service/
├── lib/
│   ├── main.dart                    # Library exports
│   ├── your_service.dart           # Main library file
│   ├── api/
│   │   ├── service-api.openapi.dart    # Generated OpenAPI client
│   │   ├── service-api.openapi.g.dart  # Generated serialization
│   │   ├── service-api.openapi.yaml    # OpenAPI spec copy
│   │   ├── service_api_configuration.dart  # DI configuration
│   │   └── service_api_service.dart     # HTTP endpoint handlers
│   ├── models/
│   │   └── model_extensions.dart      # Domain model extensions
│   ├── repositories/
│   │   └── model_queries.dart         # Custom query implementations
│   └── services/
│       └── business_service.dart      # Business logic
├── example/
│   ├── main.dart                   # Example server implementation
│   ├── pubspec.yaml               # Example dependencies
│   └── README.md                  # Usage examples
├── test/
│   ├── all_test.dart             # Test runner
│   ├── helpers/
│   │   └── test_helpers.dart     # Test utilities and data
│   ├── integration/
│   │   └── api_test.dart         # End-to-end API tests
│   └── unit/
│       ├── models/
│       ├── repositories/
│       └── services/
├── service-api.yaml              # OpenAPI specification
├── pubspec.yaml                  # Package configuration
├── build.yaml                    # Code generation config
└── README.md                     # Package documentation
```

## Dependencies

### Core Dependencies

```yaml
dependencies:
  # Kiss ecosystem
  kiss_repository: ^0.11.0
  
  # HTTP server
  shelf_plus: ^1.6.0
  
  # JSON/OpenAPI
  freezed_annotation: ^3.1.0
  json_annotation: ^4.8.1
  openapi_base: ^2.0.0
  
  # Utilities
  meta: ^1.12.0
  uuid: ^4.1.0

dev_dependencies:
  # Code generation
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  openapi_code_builder: ^1.6.0+2
  
  # Testing
  test: ^1.24.0
  
  # Linting
  very_good_analysis: ^9.0.0
```

### Build Configuration

Create `build.yaml`:

```yaml
targets:
  $default:
    builders:
      openapi_code_builder:
        generate_for:
          - lib/api/*.openapi.yaml
        options:
          output_directory: lib/api/
```

## OpenAPI Code Generation Workflow

### 1. Specification-First Development

This architectural pattern follows a **specification-first** approach where you define your API contract before implementing the code. This ensures consistency and enables automatic code generation.

### 2. OpenAPI Specification Setup

Create your OpenAPI specification file in the project root (e.g., `your-service-api.yaml`):

```yaml
openapi: 3.0.3
info:
  title: Your Service API
  version: 1.0.0
  description: A microservice following the KISS architectural pattern

paths:
  /models:
    post:
      summary: Create a new model
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/YourModelCreate'
      responses:
        '201':
          description: Model created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/YourModel'

components:
  schemas:
    YourModel:
      type: object
      required: [id, name]
      properties:
        id:
          type: string
          description: Unique identifier
        name:
          type: string
          description: Model name
        content:
          type: object
          additionalProperties: true
          description: Flexible JSON content
    
    YourModelCreate:
      type: object
      required: [name]
      properties:
        name:
          type: string
          description: Model name
        content:
          type: object
          additionalProperties: true
          description: Optional content
```

### 3. Code Generation Process

#### Step 1: Copy Specification to lib/api/
Copy your OpenAPI spec to the `lib/api/` directory with a `.openapi.yaml` extension:

```bash
cp your-service-api.yaml lib/api/your-service-api.openapi.yaml
```

#### Step 2: Run Code Generation
Use the build runner to generate Dart classes from your OpenAPI specification:

```bash
# Generate once
dart run build_runner build

# Watch for changes and regenerate automatically
dart run build_runner watch
```

#### Step 3: Generated Files
The code generation creates several files in `lib/api/`:

- `your-service-api.openapi.dart` - Main model classes and API definitions
- `your-service-api.openapi.g.dart` - JSON serialization code

### 4. Using Generated Models

The generated models include:

```dart
// Generated model class
class YourModel {
  const YourModel({
    required this.id,
    required this.name,
    this.content = const {},
  });

  final String id;
  final String name;
  final Map<String, dynamic> content;

  // Generated JSON serialization
  factory YourModel.fromJson(Map<String, dynamic> json) => 
      _$YourModelFromJson(json);
  Map<String, dynamic> toJson() => _$YourModelToJson(this);

  // Generated copyWith method
  YourModel copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? content,
  }) => YourModel(
    id: id ?? this.id,
    name: name ?? this.name,
    content: content ?? this.content,
  );
}
```

### 5. Development Workflow

1. **Design API** - Define endpoints and schemas in OpenAPI spec
2. **Generate Models** - Run `dart run build_runner build`
3. **Implement Extensions** - Add domain logic in model extensions
4. **Build Services** - Implement business logic using generated models
5. **Create API Handlers** - Use generated models in HTTP endpoints
6. **Iterate** - Update spec, regenerate, and refactor as needed

### 6. Best Practices for Code Generation

#### Keep Specifications Organized
```yaml
# Use clear, descriptive schema names
YourModelCreate:     # For creation requests
YourModelUpdate:     # For update requests  
YourModelResponse:   # For API responses
YourModelList:       # For list responses
```

#### Use Consistent Naming
```yaml
# Follow consistent patterns
components:
  schemas:
    User:           # Main entity
    UserCreate:     # Creation DTO
    UserUpdate:     # Update DTO
    UserList:       # List response
    UserSearch:     # Search criteria
```

#### Document Everything
```yaml
# Add descriptions to all schemas and properties
YourModel:
  type: object
  description: Represents a business entity in the system
  properties:
    id:
      type: string
      description: Unique identifier generated by the system
      example: "uuid-v4-string"
    name:
      type: string
      description: Human-readable name for the entity
      example: "My Business Entity"
```

### 7. Regeneration Strategy

When updating your API specification:

1. **Update the spec file** in project root
2. **Copy to lib/api/** directory
3. **Run code generation**: `dart run build_runner build --delete-conflicting-outputs`
4. **Update model extensions** if needed
5. **Fix any breaking changes** in services/API layers
6. **Run tests** to ensure compatibility

### 8. Generated Code Integration

The generated models integrate seamlessly with the Repository pattern:

```dart
// Generated model works directly with Repository<T>
final repository = InMemoryRepository<YourModel>(
  queryBuilder: YourModelQueryBuilder(),
  path: 'models',
);

// Generated fromJson/toJson enables easy serialization
final model = YourModel.fromJson(jsonData);
final jsonData = model.toJson();

// Generated copyWith enables repository updates
return repository.update(id, (current) => current.copyWith(
  name: update.name ?? current.name,
  content: update.content ?? current.content,
));
```

## Implementation Steps

### 1. Define Your Domain Model

Start with your core domain objects following the OpenAPI specification pattern:

```dart
// In your-service-api.yaml
components:
  schemas:
    YourModel:
      type: object
      required: [id, name]
      properties:
        id:
          type: string
          description: Unique identifier
        name:
          type: string
          description: Model name
        content:
          type: object
          additionalProperties: true
          description: Flexible content
    
    YourModelCreate:
      type: object
      required: [name]
      properties:
        name:
          type: string
        content:
          type: object
          additionalProperties: true
    
    YourModelUpdate:
      type: object
      properties:
        name:
          type: string
        content:
          type: object
          additionalProperties: true
```

### 2. Create Model Extensions

```dart
// lib/models/model_extensions.dart
import 'package:your_service/api/service-api.openapi.dart';

extension YourModelExtensions on YourModel {
  static YourModel create({
    required String id,
    required String name,
    Map<String, dynamic>? content,
  }) {
    return YourModel(
      id: id,
      name: name,
      content: content ?? {},
    );
  }

  void validate() {
    if (id.isEmpty) throw ArgumentError('ID cannot be empty');
    if (name.isEmpty) throw ArgumentError('Name cannot be empty');
  }

  String get validId {
    validate();
    return id;
  }

  String get validName {
    validate();
    return name;
  }
}

extension YourModelCreateExtensions on YourModelCreate {
  static YourModelCreate create({
    required String name,
    Map<String, dynamic>? content,
  }) {
    return YourModelCreate(
      name: name,
      content: content ?? {},
    );
  }

  void validate() {
    if (name.isEmpty) throw ArgumentError('Name cannot be empty');
  }

  String get validName {
    validate();
    return name;
  }
}
```

### 3. Implement Repository Queries

```dart
// lib/repositories/model_queries.dart
import 'package:kiss_repository/kiss_repository.dart';
import 'package:your_service/api/service-api.openapi.dart';

class YourModelQueryBuilder extends QueryBuilder<YourModel> {
  @override
  bool filter(YourModel item, Query query) {
    if (query is YourModelByNameQuery) {
      return item.name.toLowerCase().contains(query.name.toLowerCase());
    }
    return super.filter(item, query);
  }

  @override
  int compare(YourModel a, YourModel b, Query query) {
    if (query is YourModelSortByNameQuery) {
      return a.name.compareTo(b.name);
    }
    return super.compare(a, b, query);
  }
}

class YourModelByNameQuery extends Query {
  const YourModelByNameQuery(this.name);
  final String name;
}

class YourModelSortByNameQuery extends Query {
  const YourModelSortByNameQuery();
}
```

### 4. Create Service Layer

```dart
// lib/services/your_service.dart
import 'package:kiss_repository/kiss_repository.dart';
import 'package:your_service/api/service-api.openapi.dart';
import 'package:your_service/models/model_extensions.dart';
import 'package:your_service/repositories/model_queries.dart';
import 'package:uuid/uuid.dart';

class YourService {
  YourService(this._repository);
  final Repository<YourModel> _repository;
  final Uuid _uuid = const Uuid();

  Future<YourModel> createModel(YourModelCreate modelCreate) async {
    modelCreate.validate();

    final id = _uuid.v4();
    
    final model = YourModelExtensions.create(
      id: id,
      name: modelCreate.validName,
      content: modelCreate.content?.toMap() ?? {},
    );

    model.validate();
    return _repository.add(IdentifiedObject(model.validId, model));
  }

  Future<YourModel> getModel(String id) async {
    return _repository.get(id);
  }

  Future<YourModel> updateModel(String id, YourModelUpdate modelUpdate) async {
    return _repository.update(id, (current) {
      return current.copyWith(
        name: modelUpdate.name ?? current.name,
        content: modelUpdate.content?.toMap() ?? current.content,
      );
    });
  }

  Future<void> deleteModel(String id) async {
    await _repository.delete(id);
  }

  Future<List<YourModel>> searchModels(String nameQuery) async {
    return _repository.query(query: YourModelByNameQuery(nameQuery));
  }

  Future<List<YourModel>> getAllModels() async {
    return _repository.query(query: YourModelSortByNameQuery());
  }

  void dispose() {
    _repository.dispose();
  }
}
```

### 5. Implement API Layer

```dart
// lib/api/service_api_service.dart
import 'dart:convert';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:your_service/api/service-api.openapi.dart';
import 'package:your_service/services/your_service.dart';

class YourApiService {
  YourApiService(this._yourService);
  final YourService _yourService;

  void setupRoutes(RouterPlus app) {
    app
      ..post('/models', _createModel)
      ..get('/models/<id>', _getModel)
      ..patch('/models/<id>', _updateModel)
      ..delete('/models/<id>', _deleteModel)
      ..get('/models', _getAllModels)
      ..get('/models/search/<query>', _searchModels);
  }

  Future<Response> _createModel(Request request) async {
    try {
      final bodyJson = await request.body.asJson;
      final modelCreate = YourModelCreate.fromJson(bodyJson as Map<String, dynamic>);
      final model = await _yourService.createModel(modelCreate);

      return Response(
        201,
        body: jsonEncode(model.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on Exception catch (e) {
      return _errorResponse(400, e.toString());
    }
  }

  Future<Response> _getModel(Request request) async {
    try {
      final id = request.params['id']!;
      final model = await _yourService.getModel(id);

      return Response.ok(
        jsonEncode(model.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on RepositoryException catch (e) {
      if (e.code == RepositoryErrorCode.notFound) {
        return _errorResponse(404, 'Model not found');
      }
      return _errorResponse(500, e.message);
    } on Exception catch (e) {
      return _errorResponse(500, e.toString());
    }
  }

  Future<Response> _updateModel(Request request) async {
    try {
      final id = request.params['id']!;
      final bodyJson = await request.body.asJson;
      final modelUpdate = YourModelUpdate.fromJson(bodyJson as Map<String, dynamic>);
      final model = await _yourService.updateModel(id, modelUpdate);

      return Response.ok(
        jsonEncode(model.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on RepositoryException catch (e) {
      if (e.code == RepositoryErrorCode.notFound) {
        return _errorResponse(404, 'Model not found');
      }
      return _errorResponse(500, e.message);
    } on Exception catch (e) {
      return _errorResponse(500, e.toString());
    }
  }

  Future<Response> _deleteModel(Request request) async {
    try {
      final id = request.params['id']!;
      await _yourService.deleteModel(id);

      return Response(204);
    } on RepositoryException catch (e) {
      if (e.code == RepositoryErrorCode.notFound) {
        return _errorResponse(404, 'Model not found');
      }
      return _errorResponse(500, e.message);
    } on Exception catch (e) {
      return _errorResponse(500, e.toString());
    }
  }

  Future<Response> _getAllModels(Request request) async {
    try {
      final models = await _yourService.getAllModels();

      return Response.ok(
        jsonEncode(models.map((model) => model.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } on Exception catch (e) {
      return _errorResponse(500, e.toString());
    }
  }

  Future<Response> _searchModels(Request request) async {
    try {
      final query = request.params['query']!;
      final models = await _yourService.searchModels(query);

      return Response.ok(
        jsonEncode(models.map((model) => model.toJson()).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } on Exception catch (e) {
      return _errorResponse(500, e.toString());
    }
  }

  Response _errorResponse(int statusCode, String message) {
    return Response(
      statusCode,
      body: jsonEncode({'error': message}),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
```

### 6. Create Configuration Class

```dart
// lib/api/service_api_configuration.dart
import 'package:kiss_repository/kiss_repository.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:your_service/api/service-api.openapi.dart';
import 'package:your_service/api/service_api_service.dart';
import 'package:your_service/repositories/model_queries.dart';
import 'package:your_service/services/your_service.dart';

/// Configuration class for the Your Service library.
///
/// This class provides dependency injection configuration
/// for the service, allowing users to inject their own
/// repository implementations while providing sensible defaults.
class YourServiceConfiguration {

  /// Create a configuration with a custom repository.
  YourServiceConfiguration({required Repository<YourModel> repository})
      : _repository = repository {
    _yourService = YourService(_repository);
    _yourApiService = YourApiService(_yourService);
  }

  /// Create a configuration with an in-memory repository for testing/demos.
  factory YourServiceConfiguration.withInMemoryRepository({String? path}) {
    final repository = InMemoryRepository<YourModel>(
      queryBuilder: YourModelQueryBuilder(),
      path: path ?? 'models',
    );
    return YourServiceConfiguration(repository: repository);
  }

  final Repository<YourModel> _repository;
  late final YourService _yourService;
  late final YourApiService _yourApiService;

  /// Get the configured repository instance.
  Repository<YourModel> get repository => _repository;

  /// Get the configured service instance.
  YourService get yourService => _yourService;

  /// Get the configured API service instance.
  YourApiService get apiService => _yourApiService;

  /// Set up routes on a Router instance.
  void setupRoutes(RouterPlus app) {
    _yourApiService.setupRoutes(app);
  }

  /// Dispose of all resources.
  void dispose() {
    _yourService.dispose();
  }
}
```

### 7. Create Library Exports

```dart
// lib/your_service.dart
/// A service library with dependency injection support.
///
/// This library provides a complete service implementation
/// that can work with any Repository<YourModel> implementation from kiss_repository.
library;

export 'api/service-api.openapi.dart';
export 'api/service_api_configuration.dart';
export 'api/service_api_service.dart';
export 'models/model_extensions.dart';
export 'repositories/model_queries.dart';
export 'services/your_service.dart';
```

```dart
// lib/main.dart
import 'package:shelf_plus/shelf_plus.dart';
import 'package:your_service/your_service.dart';

void main() => shelfRun(init);

Handler init() {
  final app = Router().plus;

  final config = YourServiceConfiguration.withInMemoryRepository();

  app.use(logRequests());
  config.setupRoutes(app);

  return app.call;
}
```

## Testing Strategy

### Test Helpers

```dart
// test/helpers/test_helpers.dart
import 'package:your_service/api/service-api.openapi.dart';
import 'package:your_service/models/model_extensions.dart';

class TestData {
  static YourModel createTestModel({
    String? id,
    String? name,
    Map<String, dynamic>? content,
  }) {
    return YourModelExtensions.create(
      id: id ?? 'test-id',
      name: name ?? 'Test Model',
      content: content ?? {'test': 'data'},
    );
  }

  static YourModelCreate createModelCreate({
    String? name,
    Map<String, dynamic>? content,
  }) {
    return YourModelCreateExtensions.create(
      name: name ?? 'New Model',
      content: content ?? {'type': 'test'},
    );
  }

  static YourModelUpdate createModelUpdate({
    String? name,
    Map<String, dynamic>? content,
  }) {
    return YourModelUpdate(
      name: name,
      content: content,
    );
  }
}

class TestHelpers {
  static void validateModel(YourModel model) {
    assert(model.id.isNotEmpty, 'Model ID should not be empty');
    assert(model.name.isNotEmpty, 'Model name should not be empty');
    assert(model.content.isNotEmpty, 'Content should not be empty');
  }
}
```

### Unit Tests

```dart
// test/unit/services/your_service_test.dart
import 'package:kiss_repository/kiss_repository.dart';
import 'package:test/test.dart';
import 'package:your_service/your_service.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('YourService Tests', () {
    late Repository<YourModel> repository;
    late YourService service;

    setUp(() {
      repository = InMemoryRepository<YourModel>(
        queryBuilder: YourModelQueryBuilder(),
        path: 'models',
      );
      service = YourService(repository);
    });

    tearDown(() {
      service.dispose();
    });

    group('Model Creation', () {
      test('should create a model', () async {
        final modelCreate = TestData.createModelCreate(
          name: 'Test Model',
        );

        final created = await service.createModel(modelCreate);

        expect(created.id, isNotEmpty);
        expect(created.name, equals('Test Model'));
        TestHelpers.validateModel(created);
      });

      test('should throw on invalid model creation', () async {
        final modelCreate = TestData.createModelCreate(name: '');

        expect(
          () => service.createModel(modelCreate),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Model Retrieval', () {
      test('should get model by ID', () async {
        final modelCreate = TestData.createModelCreate();
        final created = await service.createModel(modelCreate);

        final retrieved = await service.getModel(created.id);

        expect(retrieved.id, equals(created.id));
        expect(retrieved.name, equals(created.name));
      });

      test('should throw on non-existent model', () async {
        expect(
          () => service.getModel('non-existent'),
          throwsA(isA<RepositoryException>()),
        );
      });
    });
  });
}
```

### Integration Tests

```dart
// test/integration/api_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:your_service/your_service.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_plus/shelf_plus.dart';

void main() {
  group('API Integration Tests', () {
    late HttpServer server;
    late String baseUrl;

    setUpAll(() async {
      final app = Router().plus;
      final config = YourServiceConfiguration.withInMemoryRepository();
      
      app.use(logRequests());
      config.setupRoutes(app);

      server = await shelf_io.serve(app.call, 'localhost', 0);
      baseUrl = 'http://localhost:${server.port}';
    });

    tearDownAll(() async {
      await server.close();
    });

    test('should create and retrieve model via API', () async {
      // Create model
      final createResponse = await http.post(
        Uri.parse('$baseUrl/models'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': 'API Test Model',
          'content': {'source': 'api_test'},
        }),
      );

      expect(createResponse.statusCode, equals(201));
      final created = jsonDecode(createResponse.body) as Map<String, dynamic>;
      
      // Retrieve model
      final getResponse = await http.get(
        Uri.parse('$baseUrl/models/${created['id']}'),
      );

      expect(getResponse.statusCode, equals(200));
      final retrieved = jsonDecode(getResponse.body) as Map<String, dynamic>;
      expect(retrieved['name'], equals('API Test Model'));
    });
  });
}
```

## Best Practices

### 1. Error Handling

- Use `RepositoryException` for data access errors
- Validate inputs at service boundaries
- Return appropriate HTTP status codes
- Provide meaningful error messages

### 2. Validation

- Validate in domain models with `validate()` methods
- Use `validX` getters for validated access
- Validate API inputs before processing

### 3. Testing

- Test each layer independently
- Use test helpers for consistent test data
- Include both positive and negative test cases
- Test error conditions thoroughly

### 4. Configuration

- Use dependency injection for flexibility
- Provide factory methods for common configurations
- Allow custom repository implementations
- Support both development and production setups

### 5. Documentation

- Write comprehensive OpenAPI specifications
- Include examples in API documentation
- Document all public methods and classes
- Provide usage examples

## Examples

### Simple Service Implementation

```dart
// example/main.dart
import 'package:shelf_plus/shelf_plus.dart';
import 'package:your_service/your_service.dart';

void main() => shelfRun(init);

Handler init() {
  final app = Router().plus;
  final config = YourServiceConfiguration.withInMemoryRepository();

  app.use(logRequests());
  config.setupRoutes(app);

  return app.call;
}
```

### Custom Repository Implementation

```dart
// example/custom_repository_example.dart
import 'package:your_service/your_service.dart';
import 'package:kiss_repository/kiss_repository.dart';

void main() {
  // Use a custom repository implementation
  final customRepository = MyCustomRepository<YourModel>();
  
  final config = YourServiceConfiguration(
    repository: customRepository,
  );
  
  // Use the configured service
  final service = config.yourService;
}
```

### Package Development Checklist

- [ ] OpenAPI specification defined
- [ ] Domain models with extensions created
- [ ] Repository queries implemented
- [ ] Service layer with business logic
- [ ] API layer with HTTP endpoints
- [ ] Configuration class with DI
- [ ] Comprehensive test suite
- [ ] Example implementation
- [ ] Documentation complete
- [ ] Package exports defined

This guide provides a complete template for building microservices that follow consistent architectural patterns and can be easily maintained and extended. 
