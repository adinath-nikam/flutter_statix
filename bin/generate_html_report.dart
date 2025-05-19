import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final inputFile = File('flutter_statix/dart_analysis_report.json');
  final outputFile = File('flutter_statix/dart_analysis_report.html');

  // Step 1: Check if input JSON exists
  if (!await inputFile.exists()) {
    print('❌ Error: Report file not found at ${inputFile.path}');
    exit(1);
  }

  // Step 2: Parse and validate JSON
  final content = await inputFile.readAsString();
  if (content.trim().isEmpty) {
    print('⚠️ Warning: Report file is empty. Skipping HTML generation.');
    exit(0);
  }

  late final List<dynamic> issues;
  try {
    final data = jsonDecode(content) as Map<String, dynamic>;
    issues = data['issues'] as List<dynamic>;
  } catch (e) {
    print('❌ Failed to parse JSON report: $e');
    exit(1);
  }

  if (issues.isEmpty) {
    print('ℹ️ No issues found in the report. Skipping HTML generation.');
    exit(0);
  }

  // Step 3: Generate HTML
  final buffer = StringBuffer()
    ..writeln('<!DOCTYPE html>')
    ..writeln('<html lang="en">')
    ..writeln('<head>')
    ..writeln('<meta charset="UTF-8">')
    ..writeln('<meta name="viewport" content="width=device-width, initial-scale=1.0">')
    ..writeln('<title>Dart Static Analysis Report</title>')
    ..writeln('<style>')
    ..writeln('body { font-family: Arial, sans-serif; padding: 20px; background: #f9f9f9; }')
    ..writeln('h1 { text-align: center; }')
    ..writeln('table { width: 100%; border-collapse: collapse; margin-top: 20px; }')
    ..writeln('th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }')
    ..writeln('th { background-color: #4CAF50; color: white; }')
    ..writeln('tr:nth-child(even) { background-color: #f2f2f2; }')
    ..writeln('.MINOR { color: #FFA500; }') // Orange
    ..writeln('.MAJOR { color: #FF5722; }') // Red-orange
    ..writeln('.CRITICAL { color: #f44336; font-weight: bold; }') // Red
    ..writeln('.INFO { color: #2196f3; }') // Blue
    ..writeln('</style>')
    ..writeln('</head>')
    ..writeln('<body>')
    ..writeln('<h1>Dart Static Code Analysis Report</h1>')
    ..writeln('<table>')
    ..writeln('<tr><th>Severity</th><th>File</th><th>Line</th><th>Column</th><th>Message</th><th>Rule ID</th></tr>');

  for (final issue in issues) {
    final severity = issue['severity'] ?? 'INFO';
    final location = issue['primaryLocation'] ?? {};
    final file = location['filePath'] ?? 'unknown';
    final message = location['message'] ?? '';
    final textRange = location['textRange'] ?? {};
    final line = textRange['startLine'] ?? 0;
    final column = textRange['startColumn'] ?? 0;
    final ruleId = issue['ruleId'] ?? 'unknown';

    buffer.writeln(
      '<tr class="$severity">'
          '<td class="$severity">$severity</td>'
          '<td>${htmlEscape.convert(file)}</td>'
          '<td>$line</td>'
          '<td>$column</td>'
          '<td>${htmlEscape.convert(message)}</td>'
          '<td>${htmlEscape.convert(ruleId)}</td>'
          '</tr>',
    );
  }

  buffer
    ..writeln('</table>')
    ..writeln('</body>')
    ..writeln('</html>');

  // Step 4: Write output file
  await outputFile.create(recursive: true);
  await outputFile.writeAsString(buffer.toString());

  print('✅ HTML report generated at: ${outputFile.path}');
}
