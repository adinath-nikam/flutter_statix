import 'dart:io';
import 'dart_analyzer.dart';
import 'dart_parser.dart';
import 'html_report_generator.dart';
import 'analysis_config.dart';

class AnalysisRunner {
  final AnalysisConfig config;
  late final DartAnalyzer _dartAnalyzer;
  late final DartParser _dartParser;
  late final HtmlReportGenerator _htmlGenerator;

  AnalysisRunner(this.config) {
    _dartAnalyzer = DartAnalyzer(config);
    _dartParser = DartParser(config);
    _htmlGenerator = HtmlReportGenerator(config);
  }

  Future<void> runFullAnalysis() async {
    await _runDartAnalysis();
    await _runDartParsing();
    await _generateHtmlReport();
  }

  Future<void> _runDartAnalysis() async {
    print('🔍 Running dart analyze...');
    await _dartAnalyzer.analyze();
  }

  Future<void> _runDartParsing() async {
    print('🧩 Running dart_parser.dart...');
    await _dartParser.parse();
  }

  Future<void> _generateHtmlReport() async {
    print('🧪 Running flutter tests with coverage...');
    await _htmlGenerator.generate();
  }
}