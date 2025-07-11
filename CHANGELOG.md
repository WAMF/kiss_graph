# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-12-19

### Added
- Reusable library package for hierarchical graph node management
- `GraphApiConfiguration` class for dependency injection
- Factory method `GraphApiConfiguration.withInMemoryRepository()`
- Complete example server implementation
- Automated API documentation generation

### Changed
- Transformed from standalone microservice to reusable library
- Moved server implementation to `example/` directory
- Updated imports to use library exports 
