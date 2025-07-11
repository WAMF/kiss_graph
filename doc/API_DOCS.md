# API Documentation Generation

The KISS Graph library includes automated API documentation generation from the OpenAPI specification using Dart tooling.

## Quick Start

### 1. Generate Documentation
```bash
# Using the convenient wrapper
dart doc/docs.dart generate

# Or directly
dart doc/generate_docs.dart
```

### 2. Open Documentation
```bash
# Using the wrapper (opens in default browser)
dart doc/docs.dart open

# Or open manually
# Open doc/api/index.html in your browser
```

### 3. Clean Generated Files
```bash
dart doc/docs.dart clean
```

## Requirements

### For Documentation Generation
- **Node.js** and **npm** installed
- **OpenAPI Generator CLI** installed globally:
  ```bash
  npm install -g @openapitools/openapi-generator-cli
  ```

### For Opening Documentation
- No additional requirements (opens static HTML files)

## Available Scripts

### `doc/docs.dart` - Documentation Manager
The main utility script with convenient commands:

```bash
dart doc/docs.dart <command>
```

**Commands:**
- `generate`, `gen` - Generate API documentation
- `open`, `o` - Open documentation in browser
- `clean`, `c` - Clean generated files
- `help`, `h` - Show help

### `doc/generate_docs.dart` - Documentation Generator
Generates HTML documentation from the OpenAPI specification:

```bash
dart doc/generate_docs.dart
```

**Features:**
- Uses OpenAPI Generator with HTML2 template
- Creates interactive documentation with try-it-out functionality
- Outputs to `doc/api/` directory
- Includes error checking and helpful messages

### File Access
The generated documentation is static HTML that can be:
- Opened directly in any browser
- Deployed to static hosting (GitHub Pages, Netlify, etc.)
- Served by any web server

## Generated Documentation Features

The generated HTML documentation includes:

✅ **Interactive API Explorer** - Test endpoints directly in the browser  
✅ **Request/Response Examples** - See JSON examples for all operations  
✅ **Schema Documentation** - Complete model definitions  
✅ **Authentication Info** - Security requirements (when applicable)  
✅ **Try It Out** - Execute real API calls from the documentation  
✅ **Multiple Formats** - JSON, YAML, and other export options  

## Integration with Development Workflow

### During Development
```bash
# Start the API server
cd example
dart run main.dart &

# Generate and open docs
dart doc/docs.dart generate
dart doc/docs.dart open

# Now you have:
# - API server: http://localhost:8080
# - API docs: file:///.../doc/api/index.html
```

### In CI/CD Pipeline
```bash
# Generate docs as part of build process
dart doc/docs.dart generate

# Deploy doc/ directory to your static hosting
```

### For Package Users
Package users can generate documentation for their own projects:

```bash
# In a project using kiss_graph
# Copy the docs scripts or reference them directly
```

## Customization

### OpenAPI Generator Options
Modify `doc/generate_docs.dart` to customize generation:

```dart
final result = await Process.run('npx', [
  '@openapitools/openapi-generator-cli',
  'generate',
  '-i', specFile,
  '-g', 'html2',  // Generator type
  '-o', outputDir,
  '--additional-properties',
  'appName=My Custom API,appDescription=My API Description'
]);
```

### Browser Opening
Modify `doc/docs.dart` to change how documentation opens:

```dart
// Custom browser command
if (Platform.isMacOS) {
  await Process.run('open', ['-a', 'Firefox', fileUri]);
}
```

## Alternative Generators

### Redoc
```bash
npx redoc-cli build graph-node-api.yaml --output doc/api/redoc.html
```

### Swagger UI
```bash
npx swagger-ui-dist-cli -f graph-node-api.yaml -d doc/api/swagger/
```

### OpenAPI Generator with Other Templates
```bash
# Available generators
npx @openapitools/openapi-generator-cli list

# Use different template
npx @openapitools/openapi-generator-cli generate -i graph-node-api.yaml -g html -o doc/api-simple/
```

## Troubleshooting

### Common Issues

**Error: npx not found**
```bash
# Install Node.js from https://nodejs.org/
# Then verify:
npx --version
```

**Error: @openapitools/openapi-generator-cli not found**
```bash
npm install -g @openapitools/openapi-generator-cli
```

**Browser not opening**
```bash
# Open manually
open doc/api/index.html  # macOS
start doc/api/index.html # Windows
xdg-open doc/api/index.html # Linux
```

**Documentation not updating**
```bash
# Clean and regenerate
dart doc/docs.dart clean
dart doc/docs.dart generate
```

### Getting Help

```bash
# Show all available commands
dart doc/docs.dart help

# Check script directly
dart doc/generate_docs.dart --help
``` 
