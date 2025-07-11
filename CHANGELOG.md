# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-12-19

### Added
- **Library Package Structure**: Transformed from standalone microservice to reusable Dart library
- **Accurate Documentation**: Clarified pathHash system as hierarchical indexing, not geographical spatial queries
- **Dependency Injection**: `GraphApiConfiguration` class for flexible repository injection
- **Factory Methods**: `GraphApiConfiguration.withInMemoryRepository()` for quick setup
- **API Documentation Automation**: Complete documentation generation system using OpenAPI
- **Example Server**: Working reference implementation in `example/` directory
- **Cross-Platform Documentation Tools**: Automated doc generation, opening, and cleanup
- **Comprehensive Documentation**: Updated README, implementation guide, and API docs

### Changed
- **Project Structure**: Moved from microservice to library with `lib/kiss_graph.dart` exports
- **API Organization**: Relocated API code to `lib/api/` directory structure
- **Example Implementation**: Moved original server to `example/` with local package dependency
- **Documentation Location**: Consolidated tooling in `doc/` directory
- **Import System**: Updated all imports to use library exports instead of relative imports

### Removed
- **Inline Comments**: Cleaned up codebase while preserving public API documentation
- **Bin Directory**: Moved documentation tools to `doc/` for better organization
- **Microservice-specific Configuration**: Replaced with flexible dependency injection

### Fixed
- **npm Permissions**: Resolved OpenAPI generator cache issues
- **Cross-Platform Support**: Fixed browser opening for macOS/Windows/Linux
- **OpenAPI Parameters**: Corrected generator command parameters for proper documentation
- **Dart Analysis**: Resolved all linter errors and analysis issues

### Technical Details
- **Repository Pattern**: Support for any `Repository<Node>` implementation from kiss_repository
- **Resource Management**: Proper disposal pattern in `GraphApiConfiguration`
- **Route Setup**: One-line route configuration with `config.setupRoutes(app)`
- **Test Coverage**: All 148 tests passing with new structure
- **Documentation Generation**: Automated HTML documentation at `doc/api/index.html`

### Breaking Changes
- **Import Paths**: Must now import from `package:kiss_graph/kiss_graph.dart`
- **Configuration**: Replace direct service instantiation with `GraphApiConfiguration`
- **Server Setup**: Use new dependency injection pattern for route configuration 
