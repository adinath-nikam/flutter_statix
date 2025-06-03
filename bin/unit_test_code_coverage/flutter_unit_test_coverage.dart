import 'dart:io';
import 'coverage_manager.dart';

Future<void> main() async {
  final coverageManager = CoverageManager();

  try {
    await coverageManager.runCoverageWorkflow();
    print('🎉 Coverage workflow completed successfully!');
  } catch (e) {
    print('💥 Coverage workflow failed: $e');
    exit(1);
  }
}