import 'dart:io';

import 'process_executor.dart';
import 'exceptions.dart';
import 'package:path/path.dart' as path;

/// Generates HTML coverage reports using genhtml
class HtmlReportGenerator {
  final String _lcovPath;
  final String _outputDir;
  final ProcessExecutor _processExecutor;

  HtmlReportGenerator({
    String lcovPath = 'flutter_statix/coverage/lcov.info',
    String outputDir = 'flutter_statix/coverage/html',
    ProcessExecutor? processExecutor,
  }) : _lcovPath = lcovPath,
        _outputDir = outputDir,
        _processExecutor = processExecutor ?? ProcessExecutor();

  /// Generate HTML coverage report
  Future<void> generateHtmlReport() async {
    if (!await _validateCoverageData()) {
      print('⚠️ Skipping HTML coverage generation - no coverage data available');
      return;
    }

    if (!await _checkGenhtmlAvailability()) {
      _printInstallationInstructions();
      return;
    }

    await _generateReport();
  }

  Future<bool> _validateCoverageData() async {
    final lcovFile = File(_lcovPath);
    if (!await lcovFile.exists()) return false;

    final content = await lcovFile.readAsString();
    return content.trim().isNotEmpty;
  }

  Future<bool> _checkGenhtmlAvailability() async {
    final result = await _processExecutor.run('which', ['genhtml']);
    return result.exitCode == 0;
  }

  void _printInstallationInstructions() {
    print('⚠️ genhtml not found. Install lcov package to generate HTML coverage reports.');
    print('   Ubuntu/Debian: sudo apt-get install lcov');
    print('   macOS: brew install lcov');
  }

  Future<void> _generateReport() async {
    print('📊 Generating HTML coverage report...');

    final result = await _processExecutor.run('genhtml', [
      _lcovPath,
      '-o', _outputDir,
      '--show-details',
      '--legend',
    ]);

    if (result.exitCode == 0) {
      await _handleSuccessfulGeneration();
    } else {
      await _handleGenerationFailure(result);
    }
  }

  Future<void> _handleSuccessfulGeneration() async {
    print('✅ Coverage report available at: $_outputDir/index.html');

    final indexFile = File(path.join(_outputDir, 'index.html'));
    if (await indexFile.exists()) {
      print('🔍 Open the report in your browser to view detailed coverage metrics');
    }
  }

  Future<void> _handleGenerationFailure(ProcessResult result) async {
    print('❌ genhtml failed with exit code ${result.exitCode}');
    if (result.stderr.toString().isNotEmpty) {
      print('Error details: ${result.stderr}');
    }
    throw ProcessException('genhtml failed', result.exitCode);
  }
}