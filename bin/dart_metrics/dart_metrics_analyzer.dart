import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'function_complexity.dart';
import 'complexity_metrics_visitor.dart';
import 'html_report_generator.dart';
import 'file_utils.dart';

/// Main analyzer class that orchestrates the code metrics analysis
class DartMetricsAnalyzer {
  static const String _defaultLibPath = './lib';

  /// Generates a comprehensive metrics report for Dart code
  Future<void> generateReport({String? libPath}) async {
    final stopwatch = Stopwatch()
      ..start();
    final targetPath = libPath ?? _defaultLibPath;

    final dir = Directory(targetPath);
    if (!dir.existsSync()) {
      throw Exception('Directory $targetPath does not exist');
    }

    final dartFiles = FileUtils.getDartFiles(dir);
    if (dartFiles.isEmpty) {
      print('⚠️  No Dart files found in $targetPath');
      return;
    }

    print('📊 Analyzing ${dartFiles.length} Dart files...');

    final fileMetrics = <FileSystemEntity, List<FunctionComplexity>>{};
    int totalFunctions = 0;

    for (final file in dartFiles) {
      final metrics = await _analyzeFile(file);
      if (metrics.isNotEmpty) {
        fileMetrics[file] = metrics;
        totalFunctions += metrics.length;
      }
    }

    await HtmlReportGenerator.generateReport(dartFiles, fileMetrics);

    stopwatch.stop();
    print('⏱️  Analysis completed in ${stopwatch.elapsedMilliseconds}ms');
    print('📈 Total functions analyzed: $totalFunctions');
  }

  /// Analyzes a single Dart file and returns complexity metrics
  Future<List<FunctionComplexity>> _analyzeFile(FileSystemEntity file) async {
    final content = await FileUtils.readFileContent(file);
    if (content == null) {
      return [];
    }

    // Skip empty files or files with only comments/imports
    if (FileUtils.isEmptyOrMinimalFile(content)) {
      return [];
    }

    try {
      final result = parseString(content: content);
      if (result.errors.isNotEmpty) {
        print(
            '⚠️  Parse errors in ${file.path}: ${result.errors.length} errors');
        // Continue processing despite parse errors
      }

      final visitor = ComplexityMetricsVisitor(content, file.path);
      result.unit.accept(visitor);
      return visitor.metrics;
    } catch (e) {
      print('❌ Failed to parse ${file.path}: $e');
      return [];
    }
  }
}