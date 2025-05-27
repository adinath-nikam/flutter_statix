library flutter_statix;

import 'dart:io';
import 'developer_info.dart';

Future<void> main(List<String> args) async {
  printDeveloperBanner();
  // Step 1: Create flutter_statix directory if it doesn't exist
  final statixDir = Directory('flutter_statix');
  if (!await statixDir.exists()) {
    print('📁 Creating flutter_statix directory...');
    await statixDir.create();
  }

  // Step 2: Run `dart analyze` and save output
  print('🔍 Running dart analyze...');
  final analysisFile = File('flutter_statix/dart_analysis.txt');
  final analyzeResult = await Process.run('dart', ['analyze']);
  await analysisFile.writeAsString(analyzeResult.stdout);

  // Step 3: Run dart_parser.dart
  print('🧩 Running dart_parser.dart...');
  final parserProcess = await Process.start(
    'dart',
    [
      'run',
      'flutter_statix:dart_parser',
      'dart_analysis.txt',
      'dart_analysis_report.json',
    ],
  );

  await stdout.addStream(parserProcess.stdout);
  await stderr.addStream(parserProcess.stderr);

  final parserExitCode = await parserProcess.exitCode;
  if (parserExitCode != 0) {
    print('❌ dart_parser.dart failed with exit code $parserExitCode');
    exit(parserExitCode);
  }

  // Step 4: Generate HTML analysis report
  print('📝 Generating HTML analysis report...');
  final reportProcess = await Process.start(
    'dart',
    ['run', 'flutter_statix:generate_html_report'],
  );

  await stdout.addStream(reportProcess.stdout);
  await stderr.addStream(reportProcess.stderr);

  final reportExitCode = await reportProcess.exitCode;
  if (reportExitCode != 0) {
    print('❌ generate_html_report.dart failed with exit code $reportExitCode');
    exit(reportExitCode);
  }

  // Step 5: Run flutter tests with coverage
  print('🧪 Running flutter tests with coverage...');
  final testProcess = await Process.start(
    'flutter',
    ['test', '--coverage'],
  );

  await stdout.addStream(testProcess.stdout);
  await stderr.addStream(testProcess.stderr);

  final testExitCode = await testProcess.exitCode;
  if (testExitCode != 0) {
    print('❌ Tests failed with exit code $testExitCode');
    exit(testExitCode);
  }

  // Step 6: Copy coverage file to flutter_statix/coverage/
  final originalLcov = File('coverage/lcov.info');
  final targetLcov = File('flutter_statix/coverage/lcov.info');

  if (!await originalLcov.exists()) {
    print('❌ coverage/lcov.info not found. Something went wrong.');
    exit(1);
  }

  final lcovContent = await originalLcov.readAsString();
  if (lcovContent.trim().isEmpty) {
    print('⚠️ lcov.info is empty. Skipping HTML coverage generation.');
    exit(0);
  }

  await targetLcov.parent.create(recursive: true);
  await originalLcov.copy(targetLcov.path);

  // Step 7: Generate HTML coverage report using genhtml
  print('📊 Generating HTML coverage report...');
  final genhtmlResult = await Process.run(
    'genhtml',
    [targetLcov.path, '-o', 'flutter_statix/coverage/html'],
  );

  if (genhtmlResult.exitCode == 0) {
    print('✅ Coverage report available at: flutter_statix/coverage/html/index.html');
  } else {
    print('❌ genhtml failed:\n${genhtmlResult.stderr}');
    exit(genhtmlResult.exitCode);
  }
}
