import 'process_executor.dart';
import 'exceptions.dart';

import 'dart:io';

/// Handles Flutter test execution
class FlutterTestRunner {
  final ProcessExecutor _processExecutor;

  FlutterTestRunner({ProcessExecutor? processExecutor})
      : _processExecutor = processExecutor ?? ProcessExecutor();

  /// Check if Flutter is available in the system
  Future _validateFlutterAvailability() async {
    final result = await _processExecutor.run('flutter', ['--version']);
    if (result.exitCode != 0) {
      throw StateError('Flutter is not available or not in PATH');
    }
  }

  /// Run Flutter tests with coverage
  Future<bool> runTests() async {
    await _validateFlutterAvailability();

    final testDir = Directory('test');

    if (!await testDir.exists()) {
      print('⚠️  No test/ directory found. Skipping tests.');
      return false;
    }

    final testFiles = await testDir
        .list(recursive: true)
        .where((e) => e is File && e.path.endsWith('_test.dart'))
        .toList();

    if (testFiles.isEmpty) {
      print('⚠️  test/ directory is empty or contains no *_test.dart files.');
      return false;
    }

    final exitCode = await _processExecutor.runWithStreaming(
      'flutter',
      ['test', '--coverage'],
      'flutter test',
    );

    if (exitCode != 0) {
      print('❌ Tests failed with exit code $exitCode.');
      return false;
    }

    print('✅ Tests passed.');
    return true;
  }
}
