import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

/// Simple function to zip a folder
Future<void> zipFolder(String folderPath, String zipPath) async {
  final sourceDir = Directory(folderPath);

  // Check if source folder exists
  if (!await sourceDir.exists()) {
    print('❌ Error: Folder does not exist: $folderPath');
    return;
  }

  print('📦 Zipping folder: $folderPath');
  print('💾 Output: $zipPath');

  final archive = Archive();

  // Add all files and folders to archive
  await for (final entity in sourceDir.list(recursive: true)) {
    if (entity is File) {
      try {
        final bytes = await entity.readAsBytes();
        final relativePath = path.relative(entity.path, from: folderPath);

        // Convert to forward slashes for zip compatibility
        final zipPath = relativePath.replaceAll(Platform.pathSeparator, '/');

        archive.addFile(ArchiveFile(zipPath, bytes.length, bytes));
        print('✓ Added: $zipPath');
      } catch (e) {
        print('⚠️ Skipped: ${entity.path} (Error: $e)');
      }
    }
  }

  // Create zip file
  final zipData = ZipEncoder().encode(archive);
  if (zipData != null) {
    final outputFile = File(zipPath);
    await outputFile.parent.create(recursive: true);
    await outputFile.writeAsBytes(zipData);

    final sizeKB = (zipData.length / 1024).toStringAsFixed(2);
    print(
        '✅ Success! Created $zipPath (${sizeKB} KB, ${archive.files.length} files)');
  } else {
    print('❌ Failed to create tar file');
  }
}

Future<void> main() async {
  final zipPath = 'flutter_statix/flutter_statix_report.tar';
  final folderPath = 'flutter_statix';
  try {
    await zipFolder(folderPath, zipPath);
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
