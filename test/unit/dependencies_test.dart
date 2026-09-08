import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

/// Guards the declared dependency list against one specific mistake.
///
/// `pubspec.yaml` used to declare `kiss: ^0.0.1`. That is not a WAMF package.
/// It is an unrelated third-party package on pub.dev, published once in 2023 by
/// `dart-kiss`, and no source file in this repository ever imported it. It was
/// almost certainly typed in place of one of the internal `kiss_*` packages,
/// because every real import here is `package:kiss_graph/…` or
/// `package:kiss_repository/…`.
///
/// The mistake is easy to repeat, and it is silent: `pub get` fetches the
/// package, nothing fails, and the repository carries a dependency on a
/// single-release third-party name that no code uses. If that name were ever
/// transferred on pub.dev, the `^0.0.1` range would pull unreviewed code in on
/// the next resolve.
///
/// So the removal is pinned by a test rather than left to reviewer memory.
void main() {
  group('declared dependencies', () {
    late YamlMap pubspec;

    setUpAll(() {
      pubspec =
          loadYaml(File('pubspec.yaml').readAsStringSync()) as YamlMap;
    });

    test('does not depend on the unrelated third-party "kiss" package', () {
      for (final section in const ['dependencies', 'dev_dependencies']) {
        final declared = pubspec[section] as YamlMap?;
        expect(
          declared?.keys,
          isNot(contains('kiss')),
          reason:
              'The pub.dev package "kiss" is not a WAMF package and nothing '
              'here imports it. Did you mean kiss_repository or kiss_graph?',
        );
      }
    });

    test('still depends on the kiss_* packages that are actually used', () {
      // The guard above must reject the exact name "kiss" and nothing else. A
      // prefix match would delete this repository's real dependencies.
      final declared = pubspec['dependencies'] as YamlMap;
      expect(declared.keys, contains('kiss_repository'));
    });

    test('no source file imports the third-party package', () {
      // Assembled from two literals so the needle never appears whole in this
      // file. Without that, the guard matches its own doc comment and fails
      // even when the repository is clean.
      const forbiddenImport = 'package:kiss' '/';

      final offenders = <String>[];
      for (final directory in const ['lib', 'test', 'example']) {
        final root = Directory(directory);
        if (!root.existsSync()) continue;
        for (final entity in root.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;
          if (entity.readAsStringSync().contains(forbiddenImport)) {
            offenders.add(entity.path);
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            '$forbiddenImport is the unrelated third-party package. The '
            'internal ones are package:kiss_graph/ and package:kiss_repository/.',
      );
    });
  });
}
