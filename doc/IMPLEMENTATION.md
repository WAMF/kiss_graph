# KISS Graph Library Implementation

This document describes the implementation of the KISS Graph library, a reusable Dart package for managing graph-based nodes with spatial queries and dependency injection support.

## Architecture

### Core Dependencies

1. **kiss_repository** (`^0.11.0`) - Generic repository pattern for data persistence
2. **shelf_plus** (`^1.6.0`) - Web framework for REST API endpoints  
3. **json_annotation** (`^4.8.1`) - JSON serialization support
4. **uuid** (`^4.1.0`) - Unique identifier generation
5. **openapi_base** (`^2.0.0`) - OpenAPI model generation

### Library Structure

```
lib/
├── kiss_graph.dart                    # Main library export file
├── api/
│   ├── graph_api_configuration.dart   # Dependency injection configuration
│   ├── node_api_service.dart          # HTTP API service layer
│   ├── graph-node-api.openapi.dart    # Generated OpenAPI models
│   └── graph-node-api.openapi.g.dart  # Generated JSON serialization
├── models/
│   └── node_extensions.dart           # Node model extensions
├── repositories/
│   └── node_queries.dart              # Repository query implementations
└── services/
    └── node_service.dart               # Business logic layer

doc/
├── docs.dart                          # Documentation management utility
├── generate_docs.dart                 # OpenAPI documentation generator
├── API_DOCS.md                        # Documentation automation guide
├── IMPLEMENTATION.md                  # Library implementation details
└── TEST_README.md                     # Testing documentation
```

## Key Features

### 1. Dependency Injection with GraphApiConfiguration
- **Repository Agnostic**: Works with any `Repository<Node>` implementation
- **Factory Methods**: `withInMemoryRepository()` for quick setup
- **Custom Injection**: `GraphApiConfiguration(repository: customRepo)`
- **Resource Management**: Built-in disposal of streams and connections

### 2. Repository Pattern Integration
- **Generic Interface**: Uses `Repository<Node>` from kiss_repository
- **Custom Queries**: `NodeChildrenQuery`, `NodePathQuery`, `NodeRootQuery`
- **Query Builder**: `NodeQueryBuilder` for filtering operations
- **Multiple Backends**: InMemory, Firebase, PocketBase, DynamoDB support

### 3. REST API Service Layer
- **HTTP Endpoints**: Complete CRUD operations via `NodeApiService`
- **Middleware Support**: Integration with shelf_plus middleware
- **Error Handling**: Proper HTTP status codes and JSON responses
- **Route Setup**: One-line route configuration with `setupRoutes()`

### 4. Business Logic Service
- **Node Management**: Creation, updates, deletion with validation
- **Hierarchical Structure**: Parent-child relationships with path generation
- **Path Tracing**: Trace ancestry back to root nodes
- **Spatial Queries**: Query by pathHash prefix for geographic-style lookups

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/nodes` | Create a new node |
| GET | `/nodes/{id}` | Get node by ID |
| PATCH | `/nodes/{id}` | Update node pathHash/content |
| DELETE | `/nodes/{id}` | Delete node (fails if has children) |
| GET | `/nodes/{id}/children` | Get direct children |
| GET | `/nodes/{id}/trace` | Trace path to root |
| GET | `/nodes/{id}/breadcrumbs` | Get breadcrumb path |
| GET | `/nodes/path/{prefix}` | Query by pathHash prefix |

## Node Data Model

```dart
class Node {
  final String id;           // Unique identifier (UUID)
  final String root;         // Root node ID of the graph
  final String? previous;    // Parent node ID (null for root)
  final String pathHash;     // Hierarchical path for spatial queries
  final Map<String, dynamic> content; // Arbitrary JSON content
}
```

## Usage Patterns

### 1. Simple Setup (In-Memory Repository)
```dart
import 'package:kiss_graph/kiss_graph.dart';
import 'package:shelf_plus/shelf_plus.dart';

Handler init() {
  final app = Router().plus;
  final config = GraphApiConfiguration.withInMemoryRepository();
  
  config.setupRoutes(app);
  return app.call;
}
```

### 2. Custom Repository Injection
```dart
import 'package:kiss_graph/kiss_graph.dart';

final customRepository = FirebaseRepository<Node>(
  // Firebase configuration
);

final config = GraphApiConfiguration(repository: customRepository);
final nodeService = config.nodeService;
```

### 3. Manual Dependency Injection
```dart
final repository = InMemoryRepository<Node>(
  queryBuilder: NodeQueryBuilder(),
  path: 'nodes',
);

final nodeService = NodeService(repository);
final apiService = NodeApiService(nodeService);
```

## Business Logic Implementation

### Node Creation
- Generates UUID for new nodes using `uuid` package
- Establishes root relationships (self-referencing for roots)
- Validates parent node existence for child nodes
- Generates hierarchical pathHash for spatial indexing

### Path Hash Generation
- Root nodes get simple sequential paths: `"1"`, `"2"`, etc.
- Child nodes extend parent paths: `"1.1"`, `"1.2"`, `"1.1.1"`
- Enables efficient prefix-based spatial queries
- Supports breadcrumb navigation through ancestor paths

### Deletion Rules
- Prevents deletion of nodes with children (business rule)
- Returns proper HTTP 409 Conflict for attempted violations
- Allows deletion of leaf nodes only
- Maintains graph integrity

### Error Handling
- **404**: Node not found in repository
- **409**: Business rule violations (delete with children)
- **400**: Invalid request data or validation failures
- **500**: Repository errors or unexpected failures

## Repository Implementations

### Built-in Support
- **InMemoryRepository**: Included for testing and development
- **Firebase Firestore**: Real-time apps with offline support
- **PocketBase**: Self-hosted applications  
- **AWS DynamoDB**: Enterprise/cloud applications

### Custom Implementation
Any class implementing `Repository<Node>` from kiss_repository can be used:

```dart
class CustomRepository implements Repository<Node> {
  // Implement required methods
}

final config = GraphApiConfiguration(repository: CustomRepository());
```

## Testing Architecture

### Test Structure
- **Unit Tests**: Models, Repository, Service layers
- **Integration Tests**: Full HTTP API endpoints  
- **Test Helpers**: Utilities for consistent test data
- **148 Tests**: Comprehensive coverage across all layers

### Key Test Features
- Repository-agnostic testing using InMemoryRepository
- Business logic validation (deletion rules, trace functionality)
- HTTP endpoint testing with real request/response cycles
- Error condition testing for all failure modes

## Code Generation

### OpenAPI Models
- Generated from `graph-node-api.yaml` specification
- Automatic JSON serialization with `json_annotation`
- Type-safe request/response models
- Build integration with `build_runner`

### Build Process
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Production Considerations

### Performance
- In-memory repository for development/testing only
- Production should use persistent storage (Firebase, PostgreSQL, etc.)
- Streaming support for real-time updates available

### Scalability
- Repository pattern enables horizontal scaling
- Stateless service layer supports load balancing
- Hierarchical pathHash enables efficient spatial indexing

### Security
- Library provides business logic only
- Authentication/authorization must be implemented separately
- Input validation handled at service layer
- Repository implementations handle data security
