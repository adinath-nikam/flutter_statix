import 'dart:io';
import 'dart_metrics_analyzer.dart';

Future<void> main() async {
  try {
    await DartMetricsAnalyzer().generateReport();
  } catch (e) {
    print('❌ Error generating report: $e');
    exit(1);
  }
}