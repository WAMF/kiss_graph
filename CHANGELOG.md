# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security
- **Generic HTTP error messages** (#1) - API handlers no longer put raw exception
  text in an HTTP response. A failure inside the server answers
  `{"error": "Internal server error"}`. A bad request body answers
  `{"error": "Invalid request body"}`. Internal detail from a backing store,
  such as a host, a port or a credential, can no longer reach a client.

### Added
- **`ApiErrorLogger`** - `NodeApiService` and `GraphApiConfiguration` accept an
  optional `onError` sink. It receives the full error and stack trace so a
  consumer can record the detail server-side. It defaults to `dart:developer`
  logging.

### Fixed
- **Unhandled `Error` in handlers** - Handlers caught only `Exception`, so an
  `Error` such as `ArgumentError` or `StateError` escaped the handler. A request
  body with empty content now answers HTTP 400 instead of failing unhandled.
- **`NodeService.createNode`** now throws a `RepositoryException` with code
  `notFound` when the parent node is missing, in place of an untyped
  `Exception`. The API maps it to HTTP 400 without echoing the id the caller
  sent.

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
