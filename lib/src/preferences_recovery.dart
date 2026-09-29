import 'dart:async';
import 'dart:io';

/// Deletes the supplied or observed preferences file after a decoding failure.
/// The current initialization still fails; the next app launch starts empty.
Future<T> loadWithCorruptFileReset<T>(
  Future<T> Function() load, {
  String? filePath,
  bool detectDefaultWindowsPath = false,
}) async {
  final parentZone = Zone.current;
  final observedFiles = <String, File>{};
  try {
    if (detectDefaultWindowsPath && filePath == null) {
      // The Windows backend creates a dart:io File through LocalFileSystem.
      // Observe that exact path instead of guessing company/product folders.
      // The override is local to this load, and all I/O keeps its original
      // implementation (including any overrides installed by the caller).
      return await IOOverrides.runZoned(
        load,
        createFile: (path) {
          final file = parentZone.run(() => File(path));
          final name = path.replaceAll('\\', '/').split('/').last;
          if (name.toLowerCase() == 'shared_preferences.json') {
            observedFiles[path] = file;
          }
          return file;
        },
      );
    }
    return await load();
  } on FormatException {
    // If a future backend stops exposing its file or uses multiple files,
    // leave the error visible instead of guessing which file to delete.
    final file = filePath != null
        ? File(filePath)
        : observedFiles.length == 1
        ? observedFiles.values.single
        : null;
    if (file != null && await file.exists()) {
      await file.delete();
    }
    rethrow;
  }
}
