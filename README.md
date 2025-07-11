# KISS Graph

A reusable Dart library for managing hierarchical graph-based nodes with path indexing and tracing, featuring dependency injection support. Built on the [kiss_repository](https://pub.dev/packages/kiss_repository) ecosystem for flexible data persistence.

[![pub package](https://img.shields.io/pub/v/kiss_graph.svg)](https://pub.dev/packages/kiss_graph)

---

## 🌐 Overview

This library provides:

- **Graph Node Management** - Create and manage hierarchical node structures
- **Hierarchical Indexing** - Query nodes by `pathHash` prefix using dot notation (e.g., "1.1", "1.2.3")
- **Path Tracing** - Trace ancestry back to root and get breadcrumb paths
- **Tree Navigation** - Find children, siblings, and ancestors efficiently
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
| `pathHash` | A hierarchical dot-notation path for tree indexing (e.g., "1.2.3") |
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
| GET    | `/nodes/path/{prefix}`      | Query all nodes with `pathHash` starting with prefix |

See [graph-node-api.yaml](./graph-node-api.yaml) for full OpenAPI documentation.

### 📚 Interactive API Documentation

Generate interactive HTML documentation:

```bash
# Easy way - using the docs manager
dart doc/docs.dart generate  # Generate docs
dart doc/docs.dart open      # Open in browser

# Direct method
dart doc/generate_docs.dart  # Generate docs (requires Node.js)
# Then open doc/api/index.html in your browser
```

See [doc/API_DOCS.md](./doc/API_DOCS.md) for complete documentation automation guide.

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

- **Decision Trees** - Navigate choices with hierarchical paths
- **Story Graphs** - Create branching narratives with breadcrumb navigation  
- **Knowledge Bases** - Organize information in hierarchical categories
- **File Systems** - Model folder structures with path-based queries
- **Organizational Charts** - Represent hierarchical relationships
- **Dependency Graphs** - Track hierarchical dependencies


## 📄 License

MIT License – feel free to adapt and extend.

