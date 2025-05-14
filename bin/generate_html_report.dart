import 'dart:convert';
import 'dart:io';

void main() async {
  final inputFile = File('flutter_statix/dart_analysis_report.json');
  final outputFile = File('flutter_statix/dart_analysis_report.html');

  if (!await inputFile.exists()) {
    print('❌ Error: Report file not found at ${inputFile.path}');
    exit(1);
  }

  final content = await inputFile.readAsString();
  final data = jsonDecode(content) as Map<String, dynamic>;

  final issues = data['issues'] as List<dynamic>;

  final buffer = StringBuffer();
  buffer.writeln('<!DOCTYPE html>');
  buffer.writeln('<html lang="en">');
  buffer.writeln('<head>');
  buffer.writeln('<meta charset="UTF-8">');
  buffer.writeln('<meta name="viewport" content="width=device-width, initial-scale=1.0">');
  buffer.writeln('<title>Dart Static Analysis Report</title>');
  buffer.writeln('<style>');
  buffer.writeln('body { font-family: Arial, sans-serif; padding: 20px; background: #f9f9f9; }');
  buffer.writeln('h1 { text-align: center; }');
  buffer.writeln('table { width: 100%; border-collapse: collapse; margin-top: 20px; }');
  buffer.writeln('th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }');
  buffer.writeln('th { background-color: #4CAF50; color: white; }');
  buffer.writeln('tr:nth-child(even) { background-color: #f2f2f2; }');
  buffer.writeln('.MINOR { color: #FFA500; }'); // orange
  buffer.writeln('.MAJOR { color: #FF5722; }'); // red-orange
  buffer.writeln('.CRITICAL { color: #f44336; font-weight: bold; }'); // red
  buffer.writeln('.INFO { color: #2196f3; }'); // blue
  buffer.writeln('</style>');
  buffer.writeln('</head>');
  buffer.writeln('<body>');
  buffer.writeln('<h1>Dart Static Code Analysis Report</h1>');
  buffer.writeln('<table>');
  buffer.writeln('<tr><th>Severity</th><th>File</th><th>Line</th><th>Column</th><th>Message</th><th>Rule ID</th></tr>');

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
          '<td>$file</td>'
          '<td>$line</td>'
          '<td>$column</td>'
          '<td>${htmlEscape.convert(message)}</td>'
          '<td>$ruleId</td>'
          '</tr>',
    );
  }

  buffer.writeln('</table>');
  buffer.writeln('</body></html>');

  await outputFile.create(recursive: true);
  await outputFile.writeAsString(buffer.toString());

  print('✅ HTML report generated at: ${outputFile.path}');
}
