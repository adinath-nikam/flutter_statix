import 'flutter_test_runner.dart';
import 'coverage_file_handler.dart';
import 'html_report_generator.dart';

/// Main orchestrator for Flutter test coverage operations
class CoverageManager {
  final FlutterTestRunner _testRunner;
  final CoverageFileHandler _fileHandler;
  final HtmlReportGenerator _reportGenerator;

  CoverageManager({
    FlutterTestRunner? testRunner,
    CoverageFileHandler? fileHandler,
    HtmlReportGenerator? reportGenerator,
  })  : _testRunner = testRunner ?? FlutterTestRunner(),
        _fileHandler = fileHandler ?? CoverageFileHandler(),
        _reportGenerator = reportGenerator ?? HtmlReportGenerator();

  /// Run the complete coverage workflow
  Future<void> runCoverageWorkflow() async {
    try {
      final result = await _testRunner.runTests();
      if(result) {
        await _fileHandler.copyCoverageFile();
        await _reportGenerator.generateHtmlReport();
      } else {
        print('❌No Tests Found, Report Will not be Generated.');
      }

    } catch (e) {
      print('❌ Coverage workflow failed: $e');
      rethrow;
    }
  }
}
