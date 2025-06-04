import 'dart:io';

/// Utility functions for file operations
class FileUtils {
  /// Gets all Dart files from a directory recursively
  static List<FileSystemEntity> getDartFiles(Directory dir) {
    return dir
        .listSync(recursive: true)
        .where((f) => f is File && f.path.endsWith('.dart'))
        .toList();
  }

  /// Checks if a file is empty or contains only minimal content
  /// (comments, imports, exports, etc.)
  static bool isEmptyOrMinimalFile(String content) {
    final lines = content.split('\n')
        .where((line) => line.trim().isNotEmpty &&
        !line.trim().startsWith('//') &&
        !line.trim().startsWith('/*') &&
        !line.trim().startsWith('*') &&
        !line.trim().startsWith('import ') &&
        !line.trim().startsWith('export ') &&
        !line.trim().startsWith('part '))
        .toList();
    return lines.length < 3; // Skip files with less than 3 meaningful lines
  }

  /// Reads file content safely with error handling
  static Future<String?> readFileContent(FileSystemEntity file) async {
    try {
      return await File(file.path).readAsString();
    } catch (e) {
      print('⚠️ Error Reading File ${file.path}: $e');
      return null;
    }
  }
}