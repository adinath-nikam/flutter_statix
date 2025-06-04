import 'dart:io';
import 'analysis_config.dart';
import 'process_runner.dart';
import 'analysis_runner.dart';

Future<void> main() async {
  try {
    final config = AnalysisConfig();
    final runner = AnalysisRunner(config);
    await runner.runFullAnalysis();
  } catch (e) {
    print('❌ Error Generating Dart Analysis Report: $e');
    exit(1);
  }
}

class DartAnalyzer {
  final AnalysisConfig config;
  final ProcessRunner _processRunner;

  DartAnalyzer(this.config) : _processRunner = ProcessRunner();

  Future<void> analyze() async {
    print('🔍 Running Dart Analysis...');
    final outputFile = File(config.dartAnalysisOutputTextFile);
    final result = await _processRunner.run('dart', ['analyze']);
    await _saveAnalysisResult(outputFile, result);
    _logAnalysisResult(result, outputFile);
  }

  Future<void> _saveAnalysisResult(File outputFile, ProcessResult result) async {
    final combinedOutput = StringBuffer();

    if (result.stdout.toString().isNotEmpty) {
      combinedOutput.writeln('STDOUT:');
      combinedOutput.writeln(result.stdout);
    }

    if (result.stderr.toString().isNotEmpty) {
      combinedOutput.writeln('STDERR:');
      combinedOutput.writeln(result.stderr);
    }

    combinedOutput.writeln('EXIT CODE: ${result.exitCode}');
    await outputFile.writeAsString(combinedOutput.toString());
  }

  void _logAnalysisResult(ProcessResult result, File outputFile) {
    if (result.exitCode != 0) {
      print('⚠️ Dart Analysis Completed with Exit Code ${result.exitCode}');
      print('✅ Dart Analysis Saved to ${outputFile.path}');
    } else {
      print('✅ Dart Analysis Completed Successfully');
    }
  }
}