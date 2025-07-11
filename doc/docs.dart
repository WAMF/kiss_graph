#!/usr/bin/env dart

import 'dart:io';

/// Documentation management utility for KISS Graph.
///
/// This script provides convenient commands for generating
/// and managing API documentation.
///
/// Usage:
///   dart bin/docs.dart <command>
///
/// Commands:
///   generate  - Generate API documentation
///   open      - Open documentation in browser
///   clean     - Clean generated documentation
///   help      - Show this help message
Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    _showHelp();
    return;
  }

  final command = args[0].toLowerCase();

  switch (command) {
    case 'generate':
    case 'gen':
      await _generateDocs();
    case 'open':
    case 'o':
      await _openDocs();
    case 'clean':
    case 'c':
      await _cleanDocs();
    case 'help':
    case 'h':
    case '--help':
    case '-h':
      _showHelp();
    default:
      print('❌ Unknown command: $command');
      print('');
      _showHelp();
      exit(1);
  }
}

/// Shows help information
void _showHelp() {
  print('📚 KISS Graph Documentation Manager');
  print('');
  print('Usage: dart doc/docs.dart <command>');
  print('');
  print('Commands:');
  print('  generate, gen    Generate API documentation from OpenAPI spec');
  print('  open, o          Open documentation in default browser');
  print('  clean, c         Clean generated documentation files');
  print('  help, h          Show this help message');
  print('');
  print('Examples:');
  print('  dart doc/docs.dart generate');
  print('  dart doc/docs.dart open');
  print('  dart doc/docs.dart clean');
  print('');
  print('Requirements for generate:');
  print('  - Node.js and npm');
  print('  - @openapitools/openapi-generator-cli');
  print('  - Install: npm install -g @openapitools/openapi-generator-cli');
}

/// Generates API documentation
Future<void> _generateDocs() async {
  print('🚀 Generating API documentation...');

  final result = await Process.run('dart', ['doc/generate_docs.dart']);

  if (result.exitCode == 0) {
    print('');
    print('✅ Documentation generated successfully!');
    print('📖 Open: doc/api/index.html');
    print('💡 Run: dart doc/docs.dart open');
  } else {
    print('❌ Failed to generate documentation');
    if (result.stderr.toString().trim().isNotEmpty) {
      print(result.stderr);
    }
    exit(1);
  }
}

/// Opens documentation in the default browser
Future<void> _openDocs() async {
  const docsFile = 'doc/api/index.html';

  final file = File(docsFile);
  if (!await file.exists()) {
    print('❌ Documentation not found: $docsFile');
    print('💡 Run: dart bin/docs.dart generate');
    exit(1);
  }

  print('📖 Opening documentation in browser...');

  final absolutePath = file.absolute.path;
  final fileUri = 'file://$absolutePath';

  // Try to open in default browser
  try {
    if (Platform.isMacOS) {
      await Process.run('open', [fileUri]);
    } else if (Platform.isWindows) {
      await Process.run('start', [fileUri], runInShell: true);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [fileUri]);
    } else {
      print('📁 Documentation location: $absolutePath');
      print('🌐 Open this file in your browser');
      return;
    }

    print('✅ Documentation opened in browser');
    print('📁 Location: $docsFile');
  } catch (e) {
    print('❌ Could not open browser automatically');
    print('📁 Please open this file manually: $absolutePath');
  }
}

/// Cleans generated documentation
Future<void> _cleanDocs() async {
  const docsDir = 'doc/api';

  print('🧹 Cleaning generated documentation...');

  final directory = Directory(docsDir);
  if (await directory.exists()) {
    try {
      await directory.delete(recursive: true);
      print('✅ Cleaned: $docsDir');
    } catch (e) {
      print('❌ Error cleaning documentation: $e');
      exit(1);
    }
  } else {
    print('💡 No documentation to clean (directory does not exist)');
  }

  print('🎉 Documentation cleanup complete!');
}
