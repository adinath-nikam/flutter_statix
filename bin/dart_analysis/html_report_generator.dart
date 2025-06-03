import 'analysis_config.dart';
import 'process_runner.dart';
import 'process_exception.dart';

class HtmlReportGenerator {
  final AnalysisConfig config;
  final ProcessRunner _processRunner;

  HtmlReportGenerator(this.config) : _processRunner = ProcessRunner();

  Future<void> generate() async {
    final exitCode = await _processRunner.runWithStreaming(
      'dart',
      ['run', 'flutter_statix:generate_html_report'],
      'generate_html_report.dart',
    );

    if (exitCode != 0) {
      throw ProcessException('generate_html_report.dart failed', exitCode);
    }
  }
}