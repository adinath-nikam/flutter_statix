import 'dart:io';

/// Handles process execution with streaming and standard output
class ProcessExecutor {
  /// Run a process and return the result
  Future<ProcessResult> run(String executable, List<String> arguments) async {
    return await Process.run(executable, arguments);
  }

  /// Run a process with real-time output streaming
  Future<int> runWithStreaming(
      String executable,
      List<String> arguments,
      String processName,
      ) async {
    final process = await Process.start(executable, arguments);

    // Stream output in real-time
    final stdoutFuture = stdout.addStream(process.stdout);
    final stderrFuture = stderr.addStream(process.stderr);

    // Wait for both streams and the process to complete
    await Future.wait([stdoutFuture, stderrFuture]);
    final exitCode = await process.exitCode;

    _logProcessResult(processName, exitCode);
    return exitCode;
  }

  void _logProcessResult(String processName, int exitCode) {
    if (exitCode == 0) {
      print('✅ $processName completed successfully');
    } else {
      print('❌ $processName failed with exit code $exitCode');
    }
  }
}