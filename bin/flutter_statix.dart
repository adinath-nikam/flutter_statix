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