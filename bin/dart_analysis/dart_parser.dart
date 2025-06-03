import 'analysis_config.dart';
import 'process_runner.dart';
import 'process_exception.dart';

class DartParser {
  final AnalysisConfig config;
  final ProcessRunner _processRunner;

  DartParser(this.config) : _processRunner = ProcessRunner();

  Future<void> parse() async {
    final exitCode = await _processRunner.runWithStreaming(
      'dart',
      [
        'run',
        'flutter_statix:dart_parser',
        'dart_analysis.txt',
        config.dartAnalysisReport,
      ],
      'dart_parser.dart',
    );

    if (exitCode != 0) {
      throw ProcessException('dart_parser.dart failed', exitCode);
    }
  }
}