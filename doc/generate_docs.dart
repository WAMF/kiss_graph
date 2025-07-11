#!/usr/bin/env dart

import 'dart:io';

/// Generates API documentation from the OpenAPI specification.
///
/// This script uses openapi-generator to create HTML documentation
/// from the graph-node-api.yaml specification file.
///
/// Usage:
///   dart bin/generate_docs.dart
///
/// Requirements:
///   - openapi-generator-cli must be installed
///   - Install with: npm install -g @openapitools/openapi-generator-cli
Future<void> main(List<String> args) async {
  const specFile = 'graph-node-api.yaml';
  const outputDir = 'doc/api';

  print('🚀 Generating API documentation...');
  print('📄 OpenAPI spec: $specFile');
  print('📁 Output directory: $outputDir');

  // Check if OpenAPI spec exists
  if (!await File(specFile).exists()) {
    print('❌ Error: OpenAPI specification file not found: $specFile');
    exit(1);
  }

  // Create output directory if it doesn't exist
  final outputDirectory = Directory(outputDir);
  if (!await outputDirectory.exists()) {
    print('📁 Creating output directory: $outputDir');
    await outputDirectory.create(recursive: true);
  }

  // Check if openapi-generator is available
  final checkResult = await Process.run('npx', ['--version']);
  if (checkResult.exitCode != 0) {
    print('❌ Error: npx is not available. Please install Node.js and npm.');
    print('   Visit: https://nodejs.org/');
    exit(1);
  }

  // Generate HTML documentation
  print('⚙️  Running openapi-generator...');
  final result = await Process.run('npx', [
    '@openapitools/openapi-generator-cli',
    'generate',
    '-i',
    specFile,
    '-g',
    'html2',
    '-o',
    outputDir,
    '--additional-properties',
    'appName=KISS_Graph_API,appDescription=Graph_Node_Service_API_Documentation'
  ]);

  if (result.exitCode == 0) {
    print('✅ API documentation generated successfully!');

    final indexFile = File('$outputDir/index.html').absolute;
    print('📖 Documentation: ${indexFile.path}');
    print('🌐 File URL: file://${indexFile.path}');
    print('');
    print('Generated files:');
    await _listGeneratedFiles(outputDir);
  } else {
    print('❌ Error generating documentation:');
    print('Exit code: ${result.exitCode}');

    if (result.stdout.toString().trim().isNotEmpty) {
      print('STDOUT:');
      print(result.stdout);
    }

    if (result.stderr.toString().trim().isNotEmpty) {
      print('STDERR:');
      print(result.stderr);
    }

    // Check if it's an installation issue
    if (result.stderr.toString().contains('not found') ||
        result.stderr.toString().contains('command not found')) {
      print('');
      print('💡 Installation help:');
      print('   npm install -g @openapitools/openapi-generator-cli');
      print('   Or use npx without global install (slower but works)');
    }

    exit(1);
  }
}

/// Lists the generated files in the output directory
Future<void> _listGeneratedFiles(String outputDir) async {
  try {
    final dir = Directory(outputDir);
    final files = await dir.list().toList();

    for (final file in files) {
      final name = file.path.split('/').last;
      if (file is File) {
        print('   📄 $name');
      } else if (file is Directory) {
        print('   📁 $name/');
      }
    }
  } catch (e) {
    print('   (Could not list files: $e)');
  }
}
