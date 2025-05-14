library flutter_statix;

import 'dart:io';

Future<void> main(List<String> args) async {
  // Step 1: Create flutter_statix directory if it doesn't exist
  final statixDir = Directory('flutter_statix');
  if (!await statixDir.exists()) {
    print('Creating flutter_statix directory...');
    await statixDir.create();
  }

  // Step 2: Run dart analyze and save output
  print('Running dart analyze...');
  final analysisFile = File('flutter_statix/dart_analysis.txt');
  final analyzeResult = await Process.run('dart', ['analyze']);
  await analysisFile.writeAsString(analyzeResult.stdout);

  final scriptPath = p.join(
    p.dirname(Platform.script.toFilePath()),
    'bin/dart_parser.dart',
  );

  // Step 3: Run dart_parser.dart
  print('Running dart_parser.dart...');
  final parserResult = await Process.start(
    'dart',
    [
      'run',
      'flutter_statix:dart_parser',
      'dart_analysis.txt',
      'dart_analysis_report.json'
    ],
  );
  await stdout.addStream(parserResult.stdout);
  await stderr.addStream(parserResult.stderr);
  final parserExitCode = await parserResult.exitCode;
  if (parserExitCode != 0) {
    print('dart_parser.dart failed with exit code $parserExitCode');
    exit(parserExitCode);
  }

  // Step 4: Run generate_html_report.dart
  print('Generating HTML report...');
  final reportResult = await Process.start(
    'dart',
    ['run', 'flutter_statix:generate_html_report'],
  );
  await stdout.addStream(reportResult.stdout);
  await stderr.addStream(reportResult.stderr);
  final reportExitCode = await reportResult.exitCode;
  if (reportExitCode != 0) {
    print('generate_html_report.dart failed with exit code $reportExitCode');
    exit(reportExitCode);
  }
}
