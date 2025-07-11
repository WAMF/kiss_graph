# KISS Graph

A reusable Dart library for managing graph-based nodes with spatial queries and path tracing, featuring dependency injection support. Built on the [kiss_repository](https://pub.dev/packages/kiss_repository) ecosystem for flexible data persistence.

[![pub package](https://img.shields.io/pub/v/kiss_graph.svg)](https://pub.dev/packages/kiss_graph)

---

## 🌐 Overview

This library provides:

- **Graph Node Management** - Create and manage hierarchical node structures
- **Spatial Queries** - Query nodes by `pathHash` prefix (similar to Geohash)
- **Path Tracing** - Trace ancestry back to root and get breadcrumb paths
- **Dependency Injection** - Inject any `Repository<Node>` implementation
- **REST API Ready** - Built-in HTTP endpoints with shelf_plus integration

---

## 🚀 Quick Start

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  kiss_graph: ^1.0.0
  kiss_repository: ^0.11.0  # For repository implementations
```

### Basic Usage

```dart
import 'package:kiss_graph/kiss_graph.dart';
import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  final app = Router().plus;

  // Simple setup with in-memory repository
  final config = GraphApiConfiguration.withInMemoryRepository();

  app.use(logRequests());
  config.setupRoutes(app);

  return app.call;
}
```

### Custom Repository

```dart
import 'package:kiss_graph/kiss_graph.dart';
import 'package:kiss_repository/kiss_repository.dart';

// Inject your own repository implementation
final customRepository = YourCustomRepository<Node>();
final config = GraphApiConfiguration(repository: customRepository);

// Use the service
final nodeService = config.nodeService;
final apiService = config.nodeApiService;
```

---

## 🧩 Node Structure

Each node includes:

| Field      | Description                                   |
|------------|-----------------------------------------------|
| `id`       | Unique node identifier                        |
| `root`     | ID of the root node of this graph            |
| `previous` | ID of the parent node (or null for root)     |
| `pathHash` | A spatial prefix string for hierarchical lookup |
| `content`  | Arbitrary JSON object representing the payload |

---

## 📖 API Endpoints

| Method | Path                        | Description                              |
|--------|-----------------------------|------------------------------------------|
| POST   | `/nodes`                    | Create a new node                        |
| GET    | `/nodes/{id}`               | Get node by ID                           |
| PATCH  | `/nodes/{id}`               | Update `pathHash` or `content`           |
| DELETE | `/nodes/{id}`               | Delete node (error if it has children)   |
| GET    | `/nodes/{id}/children`      | List direct children of a node           |
| GET    | `/nodes/{id}/trace`         | Trace node path back to root             |
| GET    | `/nodes/{id}/breadcrumbs`   | Get breadcrumb path                      |
| GET    | `/nodes/path/{prefix}`      | Query all nodes starting with `pathHash` |

See [graph-node-api.yaml](./graph-node-api.yaml) for full OpenAPI documentation.

### 📚 Interactive API Documentation

Generate interactive HTML documentation:

```bash
# Easy way - using the docs manager
dart docs/docs.dart generate  # Generate docs
dart docs/docs.dart open      # Open in browser

# Direct method
dart docs/generate_docs.dart  # Generate docs (requires Node.js)
# Then open docs/api/index.html in your browser
```

See [docs/API_DOCS.md](./docs/API_DOCS.md) for complete documentation automation guide.

---

## 🔗 Repository Implementations

The `kiss_graph` library works with any `Repository<Node>` implementation from the [kiss_repository](https://pub.dev/packages/kiss_repository) ecosystem:

- **InMemoryRepository** (included) - For testing and demos
- **[Firebase Firestore](https://github.com/WAMF/kiss_firebase_repository)** - Real-time apps with offline support  
- **[PocketBase](https://github.com/WAMF/kiss_pocketbase_repository)** - Self-hosted apps
- **[AWS DynamoDB](https://github.com/WAMF/kiss_dynamodb_repository)** - Server-side/enterprise apps

## 📁 Example

Check out the [example/](./example/) directory for a complete server implementation:

```bash
cd example
dart pub get
dart run main.dart
```

The example shows:
- Basic in-memory repository setup
- Custom repository injection patterns  
- Manual dependency injection
- Testing strategies

## 🧪 Testing

```dart
import 'package:kiss_graph/kiss_graph.dart';
import 'package:test/test.dart';

void main() {
  test('create node', () async {
    final config = GraphApiConfiguration.withInMemoryRepository();
    final service = config.nodeService;
    
    final nodeCreate = NodeCreate(
      content: NodeContent.fromMap({'name': 'Test'}),
    );
    
    final node = await service.createNode(nodeCreate);
    expect(node.contentMap['name'], equals('Test'));
  });
}
```

## 🔧 Configuration

### GraphApiConfiguration

The main configuration class that sets up dependency injection:

#### `GraphApiConfiguration.withInMemoryRepository({String? path})`
- Creates configuration with built-in in-memory repository
- Perfect for development, testing, and demos
- Optional `path` parameter for storage identification

#### `GraphApiConfiguration({required Repository<Node> repository})`
- Inject your own repository implementation  
- Use any repository from the kiss_repository ecosystem
- Full control over data persistence

### Methods

- `config.nodeService` - Get the configured NodeService
- `config.nodeApiService` - Get the configured NodeApiService  
- `config.setupRoutes(app)` - Setup routes on a Router
- `config.dispose()` - Clean up resources

---


## 🛠 Use Cases

- Building decision trees or story graphs
- Dependency resolution graphs
- Knowledge graphs with structured and spatial components


## 📄 License

MIT License – feel free to adapt and extend.

