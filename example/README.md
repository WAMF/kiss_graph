# KISS Graph Example Server

This example demonstrates how to use the `kiss_graph` library to build a graph node API server with dependency injection support.

## Running the Example

1. **Install dependencies:**
   ```bash
   dart pub get
   ```

2. **Start the server:**
   ```bash
   dart run main.dart
   ```

3. **Test the API:**
   ```bash
   curl -X POST http://localhost:8080/nodes \
     -H "Content-Type: application/json" \
     -d '{"content": {"name": "Test Node"}, "pathHash": "1"}'
   ```

The server will be available at `http://localhost:8080`

## Usage Examples

### 1. Simple In-Memory Repository (Current Example)

```dart
import 'package:kiss_graph/kiss_graph.dart';
import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  final app = Router().plus;

  // Use built-in in-memory repository
  final config = GraphApiConfiguration.withInMemoryRepository();

  app.use(logRequests());
  config.setupRoutes(app);

  return app.call;
}
```

### 2. Custom Repository Implementation

```dart
import 'package:kiss_graph/kiss_graph.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:shelf_plus/shelf_plus.dart';

// Example with a custom repository (e.g., Firebase, PostgreSQL, etc.)
Handler init() {
  final app = Router().plus;

  // Inject your own repository implementation
  final customRepository = YourCustomRepository<Node>(
    // your configuration
  );
  
  final config = GraphApiConfiguration(repository: customRepository);

  app.use(logRequests());
  config.setupRoutes(app);

  return app.call;
}
```

### 3. Manual Dependency Injection

```dart
import 'package:kiss_graph/kiss_graph.dart';
import 'package:kiss_repository/kiss_repository.dart';
import 'package:shelf_plus/shelf_plus.dart';

Handler init() {
  final app = Router().plus;

  // Manual DI for maximum control
  final repository = InMemoryRepository<Node>(
    queryBuilder: NodeQueryBuilder(),
    path: 'nodes',
  );
  
  final nodeService = NodeService(repository);
  final nodeApiService = NodeApiService(nodeService);

  app.use(logRequests());
  nodeApiService.setupRoutes(app);

  return app.call;
}
```

### 4. Testing with Override

```dart
import 'package:kiss_graph/kiss_graph.dart';
import 'package:test/test.dart';

void main() {
  test('example with test repository', () async {
    // Create configuration with test repository
    final testRepository = MockRepository<Node>();
    final config = GraphApiConfiguration(repository: testRepository);
    
    // Use the service in your tests
    final service = config.nodeService;
    
    // Test your logic...
  });
}
```

## Available Repository Implementations

The `kiss_graph` library works with any `Repository<Node>` implementation from the [kiss_repository](https://pub.dev/packages/kiss_repository) ecosystem:

- **InMemoryRepository** (included) - For testing and demos
- **[Firebase Firestore](https://github.com/WAMF/kiss_firebase_repository)** - Real-time apps with offline support
- **[PocketBase](https://github.com/WAMF/kiss_pocketbase_repository)** - Self-hosted apps
- **[AWS DynamoDB](https://github.com/WAMF/kiss_dynamodb_repository)** - Server-side/enterprise apps

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/nodes` | Create a new node |
| GET | `/nodes/{id}` | Get node by ID |
| PATCH | `/nodes/{id}` | Update node content/pathHash |
| DELETE | `/nodes/{id}` | Delete node (fails if has children) |
| GET | `/nodes/{id}/children` | Get direct children |
| GET | `/nodes/{id}/trace` | Trace path to root |
| GET | `/nodes/{id}/breadcrumbs` | Get breadcrumb path |
| GET | `/nodes/path/{prefix}` | Query by pathHash prefix |

## Configuration Options

### GraphApiConfiguration.withInMemoryRepository()

Creates a configuration with an in-memory repository, perfect for development and testing.

**Parameters:**
- `path` (optional): Storage path identifier (default: 'nodes')

### GraphApiConfiguration()

Creates a configuration with a custom repository implementation.

**Parameters:**
- `repository`: Any `Repository<Node>` implementation

## Cleanup

Don't forget to dispose of resources when shutting down:

```dart
// In your shutdown handler
config.dispose();
```

This ensures proper cleanup of streams, connections, and other resources. 
