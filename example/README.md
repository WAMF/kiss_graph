# Kiss Graph Example

This example demonstrates how to use the `kiss_graph` library with different repository configurations.

## 🚀 Quick Start

Run the server:

```bash
dart pub get
dart run main.dart
```

Then visit: `http://localhost:8080`

## 📖 What's Included

### Basic Setup

The most straightforward way to get started:

```dart
import 'package:kiss_graph/kiss_graph.dart';
import 'package:shelf_plus/shelf_plus.dart';

void main() => shelfRun(init);

Handler init() {
  final app = Router().plus;

  // One-line setup with in-memory repository
  final config = GraphApiConfiguration.withInMemoryRepository();

  app.use(logRequests());
  config.setupRoutes(app);

  return app.call;
}
```

### Custom Repository Injection

For production use with your own data layer:

```dart
import 'package:kiss_graph/kiss_graph.dart';
import 'package:kiss_repository/kiss_repository.dart';

void main() {
  // Use your preferred repository implementation
  final customRepository = FirebaseRepository<Node>(/* config */);
  
  final config = GraphApiConfiguration(repository: customRepository);
  
  // Your server setup...
}
```

### Manual Dependency Injection

For full control over service instantiation:

```dart
import 'package:kiss_graph/kiss_graph.dart';

void main() {
  final repository = InMemoryRepository<Node>(
    queryBuilder: NodeQueryBuilder(),
  );
  
  final nodeService = NodeService(repository);
  final apiService = NodeApiService(nodeService);
  
  // Manual route setup...
}
```

## 🧪 Test the API

### Create a root node:
```bash
curl -X POST http://localhost:8080/nodes \
  -H "Content-Type: application/json" \
  -d '{
    "previous": "",
    "content": {"name": "Root Node", "description": "The beginning"}
  }'
```

### Create a child node:
```bash
curl -X POST http://localhost:8080/nodes \
  -H "Content-Type: application/json" \
  -d '{
    "previous": "ROOT_NODE_ID_HERE",
    "content": {"name": "Child Node", "type": "branch"}
  }'
```

### Get node details:
```bash
curl http://localhost:8080/nodes/NODE_ID_HERE
```

### Trace ancestry:
```bash
curl http://localhost:8080/nodes/CHILD_NODE_ID/trace
```

### Query by path:
```bash
curl http://localhost:8080/nodes/path/1
```

## 📖 Available Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/nodes` | Create a new node |
| GET | `/nodes/{id}` | Get node by ID |
| PATCH | `/nodes/{id}` | Update node |
| DELETE | `/nodes/{id}` | Delete node |
| GET | `/nodes/{id}/children` | Get direct children |
| GET | `/nodes/{id}/trace` | Trace to root |
| GET | `/nodes/path/{prefix}` | Query by path prefix |

## 🔗 Repository Options

The `kiss_graph` library works with any `Repository<Node>` implementation:

### 📦 In-Memory (Development/Testing)
```dart
final config = GraphApiConfiguration.withInMemoryRepository();
```

### 🔥 Firebase Firestore
```dart
import 'package:kiss_firebase_repository/kiss_firebase_repository.dart';

final repository = FirebaseRepository<Node>(
  firestore: FirebaseFirestore.instance,
  collectionPath: 'nodes',
  fromJson: Node.fromJson,
  toJson: (node) => node.toJson(),
);

final config = GraphApiConfiguration(repository: repository);
```

### 📱 PocketBase
```dart
import 'package:kiss_pocketbase_repository/kiss_pocketbase_repository.dart';

final repository = PocketBaseRepository<Node>(
  client: pb,
  collection: 'nodes',
  fromJson: Node.fromJson,
  toJson: (node) => node.toJson(),
);

final config = GraphApiConfiguration(repository: repository);
```

### ☁️ AWS DynamoDB
```dart
import 'package:kiss_dynamodb_repository/kiss_dynamodb_repository.dart';

final repository = DynamoDbRepository<Node>(
  client: dynamoClient,
  tableName: 'nodes',
  fromJson: Node.fromJson,
  toJson: (node) => node.toJson(),
);

final config = GraphApiConfiguration(repository: repository);
```

## 🧪 Testing Strategies

### Unit Testing
```dart
import 'package:kiss_graph/kiss_graph.dart';
import 'package:test/test.dart';

void main() {
  group('Node Operations', () {
    late NodeService service;
    
    setUp(() {
      final config = GraphApiConfiguration.withInMemoryRepository();
      service = config.nodeService;
    });
    
    test('should create hierarchical nodes', () async {
      final root = await service.createNode(NodeCreate(
        content: NodeContent.fromMap({'name': 'Root'}),
      ));
      
      final child = await service.createNode(NodeCreate(
        previous: root.validId,
        content: NodeContent.fromMap({'name': 'Child'}),
      ));
      
      expect(child.validPathHash, equals('1.1'));
    });
  });
}
```

### Integration Testing
```dart
import 'package:shelf/shelf.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:test/test.dart';

void main() {
  group('API Integration', () {
    late Handler app;
    
    setUp(() {
      final router = Router().plus;
      final config = GraphApiConfiguration.withInMemoryRepository();
      config.setupRoutes(router);
      app = router.call;
    });
    
    test('should create and retrieve nodes', () async {
      // Create node
      final createRequest = Request(
        'POST',
        Uri.parse('http://localhost/nodes'),
        body: '{"content": {"test": "data"}}',
        headers: {'Content-Type': 'application/json'},
      );
      
      final createResponse = await app(createRequest);
      expect(createResponse.statusCode, equals(201));
      
      // Test continues...
    });
  });
}
```

## 🎯 Next Steps

1. **Explore the code** - Check out `main.dart` for implementation details
2. **Run tests** - Use `dart test` to see comprehensive test examples  
3. **Try different repositories** - Swap out the in-memory repository for production databases
4. **Build your application** - Use the node hierarchy for your specific use case
5. **Check documentation** - See `../doc/` for API reference and guides

## 🔧 Configuration Options

### GraphApiConfiguration

The main entry point for dependency injection:

```dart
// Simple setup (in-memory)
final config = GraphApiConfiguration.withInMemoryRepository();

// Custom repository
final config = GraphApiConfiguration(repository: yourRepository);

// Access services
final nodeService = config.nodeService;
final apiService = config.nodeApiService;

// Setup routes
config.setupRoutes(app);

// Cleanup
config.dispose();
```

## 🤝 Contributing

Feel free to extend this example or suggest improvements via issues and PRs! 
