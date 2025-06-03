library flutter_statix;

import 'dart:io';
import 'dart_metrics/dart_metrics.dart' as dart_metrics;
import 'dart_analysis/dart_analyzer.dart' as dart_analyzer;
import 'send_email/send_email.dart' as send_email;
import 'unit_test_code_coverage/flutter_unit_test_coverage.dart' as flutter_unit_test_coverage;
import 'utility/archiver.dart' as archiver;

Future<void> main(List<String> args) async {
  try {
    await _runFlutterStatix();
  } catch (e, stackTrace) {
    print('💥 Fatal error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

Future<void> _runFlutterStatix() async {
  // Step 1: Create flutter_statix directory if it doesn't exist
  final statixDir = Directory('flutter_statix');
  await _ensureDirectoryExists(statixDir, '📁 Creating flutter_statix directory...');

  // Step 2: Run `dart analyze` and save output
  await dart_analyzer.main();

  // Step 6: Copy coverage file to flutter_statix/coverage/
  // await _copyCoverageFile();

  // Step 7: Generate HTML coverage report using genhtml
  // await _generateHtmlCoverageReport();

  await dart_metrics.main();

  await flutter_unit_test_coverage.main();

  await archiver.main();

  await send_email.main();

  print('🎉 Flutter Statix analysis completed successfully!');
}

Future<void> _ensureDirectoryExists(Directory dir, String message) async {
  if (!await dir.exists()) {
    print(message);
    await dir.create(recursive: true);
  }
}


Future<void> _runFlutterTests() async {
  // Check if Flutter is available
  final flutterCheckResult = await Process.run('flutter', ['--version']);
  if (flutterCheckResult.exitCode != 0) {
    throw StateError('Flutter is not available or not in PATH');
  }

  final exitCode = await _runProcessWithStreaming(
    'flutter',
    ['test', '--coverage'],
    'flutter test',
  );

  if (exitCode != 0) {
    throw ProcessException('Flutter tests failed', exitCode);
  }
}

Future<void> _copyCoverageFile() async {
  final originalLcov = File('coverage/lcov.info');
  final targetLcov = File('flutter_statix/coverage/lcov.info');

  if (!await originalLcov.exists()) {
    throw StateError('coverage/lcov.info not found. Tests may not have generated coverage data.');
  }

  final lcovContent = await originalLcov.readAsString();
  if (lcovContent.trim().isEmpty) {
    print('⚠️ lcov.info is empty. No coverage data available.');
    return;
  }

  await targetLcov.parent.create(recursive: true);
  await originalLcov.copy(targetLcov.path);
  print('📋 Coverage data copied to ${targetLcov.path}');
}

Future<void> _generateHtmlCoverageReport() async {
  final targetLcov = File('flutter_statix/coverage/lcov.info');

  if (!await targetLcov.exists() || (await targetLcov.readAsString()).trim().isEmpty) {
    print('⚠️ Skipping HTML coverage generation - no coverage data available');
    return;
  }

  // Check if genhtml is available
  final genhtmlCheckResult = await Process.run('which', ['genhtml']);
  if (genhtmlCheckResult.exitCode != 0) {
    print('⚠️ genhtml not found. Install lcov package to generate HTML coverage reports.');
    print('   Ubuntu/Debian: sudo apt-get install lcov');
    print('   macOS: brew install lcov');
    return;
  }

  print('📊 Generating HTML coverage report...');
  final outputDir = 'flutter_statix/coverage/html';

  final genhtmlResult = await Process.run(
    'genhtml',
    [
      targetLcov.path,
      '-o', outputDir,
      '--show-details',
      '--highlight',
      '--legend',
    ],
  );

  if (genhtmlResult.exitCode == 0) {
    print('✅ Coverage report available at: $outputDir/index.html');

    // Try to get coverage summary
    final indexFile = File('$outputDir/index.html');
    if (await indexFile.exists()) {
      print('🔍 Open the report in your browser to view detailed coverage metrics');
    }
  } else {
    print('❌ genhtml failed with exit code ${genhtmlResult.exitCode}');
    if (genhtmlResult.stderr.toString().isNotEmpty) {
      print('Error details: ${genhtmlResult.stderr}');
    }
    throw ProcessException('genhtml failed', genhtmlResult.exitCode);
  }
}

Future<int> _runProcessWithStreaming(
    String executable,
    List<String> arguments,
    String processName,
    ) async {
  final process = await Process.start(executable, arguments);

  // Stream output in real-time
  final stdoutFuture = stdout.addStream(process.stdout);
  final stderrFuture = stderr.addStream(process.stderr);

  // Wait for both streams and the process to complete
  await Future.wait([stdoutFuture, stderrFuture]);
  final exitCode = await process.exitCode;

  if (exitCode == 0) {
    print('✅ $processName completed successfully');
  } else {
    print('❌ $processName failed with exit code $exitCode');
  }

  return exitCode;
}

class ProcessException implements Exception {
  final String message;
  final int exitCode;

  ProcessException(this.message, this.exitCode);

  @override
  String toString() => '$message (exit code: $exitCode)';
}