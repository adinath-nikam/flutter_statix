import 'process_executor.dart';
import 'exceptions.dart';

/// Handles Flutter test execution
class FlutterTestRunner {
  final ProcessExecutor _processExecutor;

  FlutterTestRunner({ProcessExecutor? processExecutor})
      : _processExecutor = processExecutor ?? ProcessExecutor();

  /// Check if Flutter is available in the system
  Future<void> _validateFlutterAvailability() async {
    final result = await _processExecutor.run('flutter', ['--version']);
    if (result.exitCode != 0) {
      throw StateError('Flutter is not available or not in PATH');
    }
  }

  /// Run Flutter tests with coverage
  Future<void> runTests() async {
    await _validateFlutterAvailability();

    final exitCode = await _processExecutor.runWithStreaming(
      'flutter',
      ['test', '--coverage'],
      'flutter test',
    );

    if (exitCode != 0) {
      throw ProcessException('Flutter tests failed', exitCode);
    }
  }
}