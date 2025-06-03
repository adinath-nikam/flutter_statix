import 'dart:convert';
import 'dart:io';

class PythonScriptExecutor {
  /// Decodes a base64 encoded Python script and executes it
  static Future<void> decodeAndExecute() async {
    try {
      await executePythonScript("bin/send_email/send_email.py");
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  static Future<void> executePythonScript(String scriptPath) async {
    try {
      print('Executing Python script...');

      List<String> pythonCommands = ['python3', 'python', 'py'];
      Process? process;

      for (String cmd in pythonCommands) {
        try {
          process = await Process.start(cmd, [scriptPath]);
          break;
        } catch (e) {
          continue;
        }
      }

      if (process == null) {
        throw Exception(
            'Python interpreter not found. Please ensure Python is installed and in PATH.');
      }

      // Handle output streams
      process.stdout.transform(utf8.decoder).listen((data) {
        stdout.write(data);
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        stderr.write(data);
      });

      int exitCode = await process.exitCode;

      if (exitCode == 0) {
        print('\nPython script executed successfully.');
      } else {
        print('\nPython script exited with code: $exitCode');
      }
    } catch (e) {
      print('Error executing Python script: $e');
      rethrow;
    }
  }
}

void main() async {
  await PythonScriptExecutor.decodeAndExecute();
}