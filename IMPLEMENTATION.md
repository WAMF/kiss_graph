# DART Service Implementation

This implementation provides a complete Graph Node Service using the specified KISS ecosystem packages.

## Architecture

### Dependencies Used

1. **shelf_plus** (`^1.6.0`) - Web framework for REST API endpoints
2. **kiss_repository** (`^0.11.0`) - Repository pattern for data persistence
3. **kiss** (`^0.0.1`) - KISS framework (minimal dependency injection)
4. **openapi_code_builder** (`^1.6.0+2`) - API client generation from OpenAPI spec

### Project Structure

```
lib/
├── main.dart                    # Application entry point
├── models/
│   ├── node.dart               # Node data model with JSON serialization
│   └── node.g.dart             # Generated JSON serialization code
├── repositories/
│   ├── node_queries.dart       # Query classes for repository filtering
│   └── node_repository.dart    # Repository implementation
├── services/
│   └── node_service.dart       # Business logic layer
├── controllers/
│   └── node_controller.dart    # HTTP request/response handling
└── graph-node-api.openapi.yaml # OpenAPI specification
```

## Key Features Implemented

### 1. Repository Pattern with kiss_repository
- **NodeRepository**: Wraps the kiss_repository with domain-specific methods
- **Custom Queries**: NodeChildrenQuery, NodeSpatialQuery, NodeRootQuery
- **In-Memory Storage**: Using InMemoryRepository for demo purposes
- **Streaming Support**: Real-time updates via streams

### 2. REST API with shelf_plus
- **HTTP Endpoints**: All endpoints from the OpenAPI spec
- **Middleware**: Logging middleware for request tracking
- **Error Handling**: Proper HTTP status codes and JSON error responses
- **Path Parameters**: Using shelf_plus path parameter extraction

### 3. Dependency Management
- **Simple DI**: Manual dependency injection in main.dart
- **Layered Architecture**: Controller → Service → Repository
- **Resource Cleanup**: Proper disposal of repositories

### 4. OpenAPI Code Generation
- **Schema Definition**: Complete OpenAPI 3.0 spec
- **Generated Models**: Automatic DTO generation with json_serializable
- **Build Integration**: Using build_runner for code generation

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/nodes` | Create a new node |
| GET | `/nodes/{id}` | Get node by ID |
| PATCH | `/nodes/{id}` | Update node content/spatialHash |
| DELETE | `/nodes/{id}` | Delete node (fails if has children) |
| GET | `/nodes/{id}/children` | Get direct children |
| GET | `/nodes/{id}/trace` | Trace path to root |
| GET | `/nodes/spatial/{prefix}` | Query by spatialHash prefix |

## Running the Service

1. **Install Dependencies**:
   ```bash
   dart pub get
   ```

2. **Generate Code**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Start Server**:
   ```bash
   dart run lib/main.dart
   ```

4. **Test API**:
   ```bash
   dart run test_api.dart
   ```

The service runs on `http://localhost:8080`

## Node Data Structure

```dart
class Node {
  final String id;           // Unique identifier (UUID)
  final String root;         // Root node ID of the graph
  final String? previous;    // Parent node ID (null for root)
  final String spatialHash;  // Spatial prefix for geospatial queries
  final Map<String, dynamic> content; // Arbitrary JSON content
}
```

## Business Logic

### Node Creation
- Generates UUID for new nodes
- Sets root ID (same as node ID for root nodes, inherited for children)
- Validates parent node exists for non-root nodes

### Spatial Queries
- Supports prefix matching on spatialHash field
- Useful for geohash-style spatial indexing

### Path Tracing
- Follows parent chain back to root
- Returns ordered list from current node to root
- Handles broken chains gracefully

### Child Management
- Prevents deletion of nodes with children
- Supports querying direct children only

## Error Handling

- **404**: Node not found
- **409**: Cannot delete node with children
- **400**: Invalid request data
- **500**: Internal server errors

All errors return JSON with error message.

## Testing

The `test_api.dart` script demonstrates:
1. Creating root and child nodes
2. Retrieving nodes by ID
3. Querying children
4. Tracing ancestry
5. Spatial prefix queries

## Generated Code

The implementation uses code generation for:
- **JSON Serialization**: Models have automatic toJson/fromJson
- **OpenAPI Client**: Generated from the YAML specification
- **Type Safety**: All models are strongly typed

## Next Steps

To make this production-ready:
1. Add proper database backend (PostgreSQL, MongoDB, etc.)
2. Implement authentication/authorization
3. Add comprehensive test suite
4. Add Docker containerization
5. Add metrics and monitoring
6. Implement proper CORS handling
7. Add API versioning