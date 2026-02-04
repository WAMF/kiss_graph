# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Kiss Graph is a Dart library for managing hierarchical graph-based nodes with path indexing and tracing capabilities. It provides a flexible architecture with dependency injection support for different repository implementations.

## Common Development Commands

### Dependencies
```bash
dart pub get                    # Install dependencies
dart pub upgrade               # Update dependencies
```

### Code Generation
```bash
dart run build_runner build    # Generate code (required after model changes)
dart run build_runner watch    # Watch mode for auto-generation
dart run build_runner build --delete-conflicting-outputs  # Clean rebuild
```

### Testing
```bash
dart test                      # Run all tests
dart test test/unit/          # Run unit tests only
dart test test/integration/   # Run integration tests only
dart test --name="pattern"    # Run tests matching pattern
dart test path/to/test.dart   # Run specific test file
```

### Code Quality
```bash
dart analyze                   # Run static analysis
dart fix --apply              # Apply automatic fixes
```

### Documentation
```bash
dart doc/docs.dart generate    # Generate API documentation
dart doc/docs.dart open       # Open docs in browser
```

### Running Example Server
```bash
cd example
dart pub get
dart run main.dart            # Runs on http://localhost:8080
```

## Architecture Overview

The codebase follows a clean architecture pattern with clear separation of concerns:

### Core Components

1. **Models** (`lib/src/models/`)
   - `Node`: Core data structure with id, root, previous, pathHash, and content
   - `NodeExtensions`: Query builder extensions for repository operations
   - Uses Freezed for immutability and JsonSerializable for JSON handling

2. **Services** (`lib/src/services/`)
   - `NodeService`: Business logic for node operations (CRUD, tree navigation, validation)
   - `NodeApiService`: HTTP API layer that wraps NodeService with REST endpoints
   - Services use dependency injection for repository flexibility

3. **Configuration** (`lib/src/configuration/`)
   - `GraphApiConfiguration`: DI container that wires up repository, services, and routes
   - Provides factory method for in-memory repository setup

4. **API Definition** (`lib/graph-node-api.openapi.yaml`)
   - OpenAPI 3.0 specification defining all REST endpoints
   - Used by openapi_code_builder to generate client/server stubs

### Key Patterns

1. **Path-based Indexing**: Nodes use dot-notation paths (e.g., "1.2.3") for hierarchical indexing, enabling efficient prefix queries for finding all descendants.

2. **Repository Pattern**: Abstract `Repository<Node>` interface allows plugging in different persistence backends (in-memory, database, etc.).

3. **Dependency Injection**: Configuration class manages dependencies, making the library testable and flexible.

4. **Code Generation**: Models and API clients are generated from specifications, ensuring type safety and reducing boilerplate.

### Testing Strategy

- **Unit Tests** (`test/unit/`): Test individual components in isolation
- **Integration Tests** (`test/integration/`): Test API endpoints with real HTTP requests
- Tests use the in-memory repository for fast, isolated testing
- All tests can be run via `test/all_test.dart`

## Development Guidelines

1. **No inline comments** - Code should be self-documenting
2. **Always run `dart fix` and `dart analyze`** before committing - Fix all analyzer warnings
3. **Code generation required** - Run build_runner after modifying models or OpenAPI spec
4. **Follow existing patterns** - Maintain consistency with repository pattern and service layer separation