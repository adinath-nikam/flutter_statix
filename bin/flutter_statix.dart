library flutter_statix;

import 'dart:io';
import 'dart_metrics/dart_metrics.dart' as dart_metrics;
import 'dart_analysis/dart_analyzer.dart' as dart_analyzer;
import 'send_email/send_email.dart' as send_email;
import 'unit_test_code_coverage/unit_test_coverage_analyzer.dart' as unit_test_coverage_analyzer;
import 'utility/archiver.dart' as archiver;

Future<void> main(List<String> args) async {
  try {
    await _runFlutterStatix();
  } catch (e, stackTrace) {
    print('💥 | Fatal error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

Future<void> _runFlutterStatix() async {
  final statixDir = Directory('flutter_statix');

  await _ensureDirectoryExists(statixDir, '📁 | Creating flutter_statix directory...');

  await dart_analyzer.main();

  await dart_metrics.main();

  await unit_test_coverage_analyzer.main();

  await archiver.main();

  await send_email.main();

  print('\n🎉 | Flutter Statix Analysis Completed Successfully!');
}

Future<void> _ensureDirectoryExists(Directory dir, String message) async {
  if (!await dir.exists()) {
    print(message);
    await dir.create(recursive: true);
  }
}