import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:front_matter/front_matter.dart' as fm;
import 'package:markd/markdown.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:preferences/preference_service.dart';

import '/constant/app.dart' as ca;
import '/model/note.dart';
import '/utils/logger.dart';
import '/utils/yaml.dart';

///
Future<Directory> dataDirectory() async {
  String path = PrefService.stringDefault(ca.dataPath);
  if (path.isEmpty) {
    // Default file path for app initialization
    path = p.join((await getApplicationDocumentsDirectory()).path,
        ca.appName.toLowerCase());
    path = formatPath(path);
    PrefService.setString(ca.dataPath, path);
  }

  return Directory(path);
}

///
String formatPath(String path) {
  return (Platform.isWindows && path.indexOf(r'\') > -1)
      ? path.replaceAll(r'\', '/')
      : path;
}

///
Future<String?> pickPath() async {
  if (!await Permission.storage.request().isGranted) {
    return null;
  }

  String path = (await FilePicker.platform.getDirectoryPath()) ?? '';
  if (path.isNotEmpty && (await isPathWritable(path))) {
    return formatPath(path);
  }

  if ((await Permission.storage.request()).isDenied) {
    return null;
  }

  Directory defaultDir = await getApplicationDocumentsDirectory();
  if (await isPathWritable(defaultDir.path)) {
    return formatPath(defaultDir.path);
  }

  return null;
}

///
Future<bool> isPathWritable(String? path) async {
  final testFile = File('$path/${Random().nextInt(1000000)}');

  try {
    await testFile.create(recursive: true);
    await testFile.writeAsString("This is only a test file, please ignore.");
    await testFile.delete();
  } catch (e) {
    return false;
  }
  return true;
}

///
String mdTitle(String content,
    {bool isFilename = false, bool isTrim = false, bool isHtmlStyle = true}) {
  RegExpMatch? heading =
      RegExp(r'^#\s+(.+?)(?=\s*$)', multiLine: true).firstMatch(content);
  String title = heading?[1] ?? '';

  if (title.isNotEmpty) {
    if (isHtmlStyle) {
      // format text (e.g. `:tada:` change to `🎉`)
      title = markdownToHtml(title, extensionSet: ExtensionSet.gitHubWeb)
          .replaceAll(RegExp(r'<[^>]*?>'), ''); // remove html tag
    }

    if (isFilename) title = filenameFilter(title);

    if (isTrim) title = title.trimLeft();
  }

  return title;
}

///
String filenameFilter(String filename) {
  return filename.replaceAll(RegExp(r'[\/:*?"<>|]'), '');
}

///
String? readAsString(String path){
  try {
    return File(path).readAsStringSync();
  } catch (e) {
    logger.e('readAsString error: $e');
    return null;
  }
}

///
class PersistentStore {
  static bool get isDendronMode =>
      (PrefService.getBool(ca.isDendronMode) ?? false);

  /// [readNote]
  /// markdown file content example：
  /// ```md
  /// ---
  /// title: 01 - The Data Directory
  /// tags: [Basics, Notebooks/Tutorial]
  /// created: 1723268317678
  /// updated: 1723268317678
  /// ---
  ///
  /// # H1 - The Data Directory
  /// content text...
  /// ## H2
  /// ```
  static Future<Note?> readNote(File file) async {
    // print('PersistentStore.readNote');

    if (!file.existsSync()) return null;
    Note note = Note(f: file);

    Map header = {};

    String fileContent = file.readAsStringSync().trimLeft();

    if (fileContent.startsWith('---')) {
      fm.FrontMatterDocument doc = fm.parse(fileContent);
      // String headerString = fileContent.split('---')[1];
      header = doc.data ?? {};
    }

    // logger.d(('readNote: ', header));

    // note title
    note.title = mdTitle(fileContent);
    if (note.title.isEmpty && header['title'] != null) {
      note.title = header['title'].toString();
    }
    if (note.title.isEmpty) {
      String title = p.basename(file.path);
      if (title.endsWith('.md')) {
        title = title.substring(0, title.length - 3); // remove extension
      }
      note.title = title;
    }

    // note updated time
    if (header['updated'] != null) {
      if (header['updated'] is int) {
        note.updated = DateTime.fromMillisecondsSinceEpoch(header['updated']);
      } else {
        note.updated =
            DateTime.tryParse(header['updated']) ?? file.lastModifiedSync();
      }
    } else {
      note.updated = file.lastModifiedSync();
    }

    // note created time
    if (header['created'] != null) {
      if (header['created'] is int) {
        note.created = DateTime.fromMillisecondsSinceEpoch(header['created']);
      } else {
        note.created = DateTime.tryParse(header['created']) ?? note.updated;
      }
    } else {
      note.created = note.updated;
    }

    // note.tags = (header['tags'] as YamlList).map((s) => s.toString()).toList();
    note.tags = List.from((header['tags'] ?? []).cast<String>());
    note.attachments = List.from((header['attachments'] ?? []).cast<String>());

    note.pinned = header['pinned'] ?? false;
    note.favorite = header['favorite'] ?? false;
    note.deleted = header['deleted'] ?? false;
    note.encrypted = header['encrypted'] ?? false;

    if (header.isNotEmpty) {
      note.header = Map<String, dynamic>.from(header);
      note.header
          .removeWhere((key, value) => !Note.validHeaderKeys.contains(key));
    }

    return note;
  }

  /// [readContent]
  static Future<String> readContent(Note note,
      {bool ignoreEncrypted = false}) async {
    if (!note.file.existsSync()) return '';

    String fileContent = (await note.file.readAsStringSync()).trimLeft();

    String content = fileContent;

    if (fileContent.startsWith('---')) {
      fm.FrontMatterDocument doc = fm.parse(fileContent);
      if (doc.content != null) content = doc.content!.trimLeft();
    }

    //
    if (note.encrypted && !ignoreEncrypted) {
      (String, bool) dec = await note.encryption!.decrypt(content);
      note.isDecryptSuccess = dec.$2;
      if (note.isDecryptSuccess) content = dec.$1;
    }

    if (isDendronMode && (!note.encrypted || note.isDecryptSuccess)) {
      if (!content.startsWith('# ')) {
        content = '# ${note.title}\n\n' + content;
      }
    }

    return content;
  }

  ///
  static Future saveNote(Note note, [String? content]) async {
    // print('PersistentStore.saveNote');
    logger.d(('saveNote', content));
    if (content == null) content = await readContent(note);

    if (isDendronMode) {
      final int index = content.indexOf('\n');
      if (index != -1) content = content.substring(index).trimLeft();
    }

    // encrypt content
    if (note.encrypted) {
      content = await note.encryption!.encrypt(content);
      logger.d(('saveNote > encrypt', content));
    }

    note.file.writeAsStringSync(_headerToString(note) + content);
  }

  /// [saveNoteHeader] only save header changes
  static Future saveNoteHeader(Note note) async {
    String content = await readContent(note, ignoreEncrypted: true);

    note.file.writeAsStringSync(_headerToString(note) + content);
  }

  ///
  static String _headerToString(Note note) {
    String header = '---\n';
    Map data = {};

    data['title'] = note.title;

    if (PrefService.getBool(ca.canShowVirtualTags) ?? false) {
      note.tags.removeWhere((s) => s.startsWith('#/'));
    }

    if (!isDendronMode && note.tags.isNotEmpty) {
      data['tags'] = note.tags;
    }

    if (note.attachments.isNotEmpty) data['attachments'] = note.attachments;

    data['created'] = note.created.millisecondsSinceEpoch;
    data['updated'] = note.updated.millisecondsSinceEpoch;

    if (note.pinned) data['pinned'] = true;
    if (note.favorite) data['favorite'] = true;
    if (note.deleted) data['deleted'] = true;
    if (note.encrypted) data['encrypted'] = true;

    header += toYamlString(data);
    if (!header.endsWith('\n')) header += '\n';
    header += '---\n\n';

    logger.d(('saveNote', note.file.path));
    logger.d(('saveNote', data, header));

    return header;
  }

  ///
  static Future deleteNote(Note note) async {
    await note.file.delete();
  }
}
