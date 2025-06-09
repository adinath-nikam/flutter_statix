import 'dart:io';
import 'unit_test_config.dart';
import 'process_runner.dart';
import 'unit_test_runner.dart';

Future<void> main() async {
  try {
    final config = UnitTestConfig();
    final runner = UnitTestRunner(config);
    await runner.runFullUnitTestWithCoverage();
  } catch (e) {
    print('❌ | Error Generating Dart Analysis Report: $e');
    exit(1);
  }
}

class UnitTestCoverageAnalyzer {
  final UnitTestConfig config;
  final ProcessRunner _processRunner;

  UnitTestCoverageAnalyzer(this.config) : _processRunner = ProcessRunner();

  Future<void> runUnitTest() async {
    print('🔍 | Running Unit Tests...');
    final result = await _processRunner.run('flutter', ['test', '--coverage']);
    await _saveUnitTestResult(config.unitTestOutputDirectory, result);
  }

  Future<void> _saveUnitTestResult(String outputDirectory, ProcessResult result) async {
    if (result.exitCode == 0) {
      final moveResult = await _processRunner.run('cp', ['-r', 'coverage', outputDirectory]);

      if (moveResult.exitCode != 0) {
        print('❌  | Failed to Move Coverage Folder: ${moveResult.stderr}');
      } else {
        print('✅  | Coverage Report Generated Successfully');
      }
    } else {
      print('❌ | Flutter test failed: ${result.stderr}');
    }

  }
}