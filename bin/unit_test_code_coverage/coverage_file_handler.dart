import 'dart:io';

/// Handles coverage file operations
class CoverageFileHandler {
  final String _sourcePath;
  final String _targetPath;

  CoverageFileHandler({
    String sourcePath = 'coverage/lcov.info',
    String targetPath = 'flutter_statix/coverage/lcov.info',
  }) : _sourcePath = sourcePath,
        _targetPath = targetPath;

  /// Copy coverage file from source to target location
  Future<void> copyCoverageFile() async {
    final sourceFile = File(_sourcePath);
    final targetFile = File(_targetPath);

    await _validateSourceFile(sourceFile);
    await _ensureTargetDirectory(targetFile);
    await _performCopy(sourceFile, targetFile);
  }

  Future<void> _validateSourceFile(File sourceFile) async {
    if (!await sourceFile.exists()) {
      print('⚠️ $_sourcePath not found. No coverage data available.');
    }

    final content = await sourceFile.readAsString();
    if (content.trim().isEmpty) {
      print('⚠️ $_sourcePath is empty. No coverage data available.');
      // throw StateError('Coverage file is empty');
    }
  }

  Future<void> _ensureTargetDirectory(File targetFile) async {
    await targetFile.parent.create(recursive: true);
  }

  Future<void> _performCopy(File sourceFile, File targetFile) async {
    if (!await sourceFile.exists()) {
      print('⚠️ $_sourcePath not found. No coverage data available.');
    }
    await sourceFile.copy(targetFile.path);
    print('📋 Coverage data copied to ${targetFile.path}');
  }
}