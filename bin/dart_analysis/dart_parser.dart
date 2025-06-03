import 'analysis_config.dart';
import 'process_runner.dart';
import 'process_exception.dart';
import 'dart:convert';
import 'dart:io';

class DartParser {

  Future<void> parse() async {
    final input = File('flutter_statix/dart_analysis.txt');
    final output = File('flutter_statix/dart_analysis_report.json');

    // Regex pattern to match analyzer output lines
    final pattern = RegExp(
      r'^(info|warning|error) - ([^:]+):(\d+):(\d+) - (.+?) - ([\w_]+)$',
    );

    // Mapping analyzer severities to normalized values
    final severityMap = {
      'info': 'INFO',
      'warning': 'MINOR',
      'error': 'MAJOR',
    };

    final issues = <Map<String, dynamic>>[];

    // Check if input file exists
    if (!await input.exists()) {
      print('❌ flutter_statix/dart_analysis.txt not found.');
      exit(1);
    }

    // Read and parse each line
    await for (final line in input
        .openRead()
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      final match = pattern.firstMatch(line.trim());
      if (match != null) {
        final severity = severityMap[match[1]!.toLowerCase()] ?? 'INFO';
        final file = match[2]!;
        final lineNum = int.parse(match[3]!);
        final colNum = int.parse(match[4]!);
        final message = match[5]!;
        final rule = match[6]!;

        issues.add({
          'engineId': 'dart',
          'ruleId': rule,
          'severity': severity,
          'type': 'CODE_SMELL',
          'primaryLocation': {
            'message': message,
            'filePath': file,
            'textRange': {
              'startLine': lineNum,
              'startColumn': colNum,
            },
          },
        });
      }
    }

    // Ensure output directory exists
    await output.parent.create(recursive: true);

    // Write the report
    await output.writeAsString(
      const JsonEncoder.withIndent('  ').convert({'issues': issues}),
    );

    print('✅ ${issues.length} issues written to flutter_statix/dart_analysis_report.json');
  }
}
