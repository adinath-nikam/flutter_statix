import 'html_report_generator.dart';
import 'unit_test_config.dart';
import 'unit_test_coverage_analyzer.dart';

class UnitTestRunner {
  final UnitTestConfig config;
  late final UnitTestCoverageAnalyzer _unitTestCoverageAnalyzer;
  late final HtmlReportGenerator _htmlGenerator;

  UnitTestRunner(this.config) {
    _htmlGenerator = HtmlReportGenerator(unitTestConfig: config);
    _unitTestCoverageAnalyzer = UnitTestCoverageAnalyzer(config);
  }

  Future<void> runFullUnitTestWithCoverage() async {
    await _runUnitTestCoverage();
    await _generateHtmlReport();
  }

  Future<void> _runUnitTestCoverage() async {
    await _unitTestCoverageAnalyzer.runUnitTest();
  }

  Future<void> _generateHtmlReport() async {
    await _htmlGenerator.generateHtmlReport();
  }
}