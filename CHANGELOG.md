# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2024-12-19

### Removed
- **Breadcrumbs endpoint** - Removed redundant `/nodes/{id}/breadcrumbs` API endpoint
- **getBreadcrumbs method** - Removed from NodeService as it duplicated trace functionality

### Changed
- **API simplification** - Consolidated navigation to use only `/nodes/{id}/trace` endpoint
- **Documentation updates** - Updated README and examples to remove breadcrumb references
- **Test cleanup** - Removed redundant breadcrumb tests

### Improved
- **Code quality** - Resolved all linter issues for cleaner codebase
- **Performance** - Eliminated redundant pathHash-based navigation code

### Breaking Changes
- Applications using `/nodes/{id}/breadcrumbs` endpoint should migrate to `/nodes/{id}/trace`
- Code calling `NodeService.getBreadcrumbs()` should use `NodeService.trace()` instead

## [0.1.0] - 2024-12-19

### Added
- **Library Package Structure** - Transformed from standalone microservice to reusable Dart library
- **Dependency Injection** - `GraphApiConfiguration` class for flexible repository injection
- **Factory Methods** - `GraphApiConfiguration.withInMemoryRepository()` for quick setup
- **API Documentation Automation** - Complete documentation generation system using OpenAPI
- **Example Server** - Working reference implementation in `example/` directory
- **Cross-Platform Documentation Tools** - Automated doc generation, opening, and cleanup

### Changed
- **Project Structure** - Moved from microservice to library with `lib/kiss_graph.dart` exports
- **API Organization** - Relocated API code to `lib/api/` directory
- **Documentation Location** - Consolidated tooling in `doc/` directory 
