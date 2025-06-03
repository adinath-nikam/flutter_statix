class ProcessException implements Exception {
  final String message;
  final int exitCode;

  ProcessException(this.message, this.exitCode);

  @override
  String toString() => '$message (exit code: $exitCode)';
}