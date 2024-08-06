import 'dart:io';

import 'package:front_matter/front_matter.dart' as fm;
import 'package:preferences/preference_service.dart';

import '/model/note.dart';
import '/utils/logger.dart';
import '/utils/yaml.dart';

///
class PersistentStore {
  static bool get isDendronMode =>
      (PrefService.getBool('dendron_mode') ?? false);

  /// [readNote]
  /// markdown file content example：
  /// ```md
  /// ---
  /// title: 01 - The Data Directory
  /// tags: [Basics, Notebooks/Tutorial]
  /// created: '2018-12-16T21:43:52.886Z'
  /// modified: '2020-07-05T12:00:00.000Z'
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

    if (header['title'] != null) {
      note.title = header['title'].toString();
    } else {
      var title = file.path.split('/').last;
      if (title.endsWith('.md')) {
        title = title.substring(0, title.length - 3);
      }
      note.title = title;
    }

    // note modified time
    if (header['modified'] != null && !isDendronMode) {
      if (header['modified'] is int) {
        note.isMillisecond = true;
        note.modified = DateTime.fromMillisecondsSinceEpoch(header['modified']);
      } else {
        note.modified = DateTime.tryParse(header['modified'])!;
      }
    } else if (header['updated'] != null) {
      note.idUpdatedInsteadOfModified = true;
      if (header['updated'] is int) {
        note.isMillisecond = true;
        note.modified = DateTime.fromMillisecondsSinceEpoch(header['updated']);
      } else {
        note.modified = DateTime.tryParse(header['updated'])!;
      }
    } else {
      note.modified = file.lastModifiedSync();
    }

    // note created time
    if (header['created'] != null) {
      if (header['created'] is int) {
        note.isMillisecond = true;
        note.created = DateTime.fromMillisecondsSinceEpoch(header['created']);
      } else {
        note.created = DateTime.tryParse(header['created'])!;
      }
    } else {
      note.created = note.modified;
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
  static Future<String?> readContent(Note note) async {
    if (!note.file.existsSync()) return null;

    String fileContent = (await note.file.readAsStringSync()).trimLeft();

    String content = fileContent;

    if (fileContent.startsWith('---')) {
      fm.FrontMatterDocument doc = fm.parse(fileContent);
      if (doc.content != null) content = doc.content!.trimLeft();
    }

    //
    if (note.encrypted) {
      (String, bool) dec = await note.encryption!.decrypt(content);
      note.isDecryptSuccess = dec.$2;
      if (note.isDecryptSuccess) content = dec.$1;
    }

    if (isDendronMode) {
      if (!content.startsWith('# ')) {
        content = '# ${note.title}\n\n' + content;
      }
    }

    return content;
  }

  ///
  static Future saveNote(Note note, [String? content]) async {
    // print('PersistentStore.saveNote');
    print(('saveNote', content));
    if (content == null) content = await readContent(note);

    if (isDendronMode) {
      final index = content?.indexOf('\n');
      if (index != -1) content = content?.substring(index!).trimLeft();
    }

    // encrypt content
    if (note.encrypted) {
      content = await note.encryption!.encrypt(content!);
      print(('saveNote > encrypt', content));
    }

    String header = '---\n';
    Map data = {};

    data['title'] = note.title;

    if (PrefService.getBool('notes_list_virtual_tags') ?? false) {
      note.tags.removeWhere((s) => s.startsWith('#/'));
    }

    if (!isDendronMode) {
      if (note.tags.isNotEmpty) data['tags'] = note.tags;
    }

    if (note.attachments.isNotEmpty) data['attachments'] = note.attachments;

    if (note.isMillisecond) {
      data['created'] = note.created.millisecondsSinceEpoch;
      data[note.idUpdatedInsteadOfModified ? 'updated' : 'modified'] =
          note.modified.millisecondsSinceEpoch;
    } else {
      data['created'] = note.created.toIso8601String();
      data[note.idUpdatedInsteadOfModified ? 'updated' : 'modified'] =
          note.modified.toIso8601String();
    }

    if (note.pinned) data['pinned'] = true;
    if (note.favorite) data['favorite'] = true;
    if (note.deleted) data['deleted'] = true;
    if (note.encrypted) data['encrypted'] = true;

    if (note.header.isNotEmpty) {
      data.addAll(note.header.cast<String, dynamic>());
    }

    header += toYamlString(data);
    if (!header.endsWith('\n')) header += '\n';
    header += '---\n\n';

    logger.d(('saveNote', note.file.path));
    logger.d(header);

    note.file.writeAsStringSync(header + content!);
    /*  print(header + content); */
  }

  ///
  static Future deleteNote(Note note) async {
    await note.file.delete();
  }

/*   static Future<Note> readNoteMetadata(File file) async {
    // print('PersistentStore.readNote');

    if (!file.existsSync()) return null;

    var raf = await file.open();

    List<int> bytes = [];

    bool equalBytes(List<int> l1, List<int> l2) {
      int i = -1;
      return l1.every((val) {
        i++;
        return l2[i] == val;
      });
    }

    while (true) {
      var byte = raf.readByteSync();
      if (byte == -1) break;

      bytes.add(byte);

      int length = bytes.length;

      if (length > 6 &&
          equalBytes(bytes.sublist(bytes.length - 4, bytes.length),
              <int>[10, 45, 45, 45] /* == "\n---" */)) break;
    }

    String fileContent = utf8.decode(bytes);

    var doc = fm.parse(fileContent);
/* 
        String headerString = fileContent.split('---')[1]; */

    var header = doc.data /* loadYaml(headerString) */;

    if (header == null) return null;

    /* for (String line in headerString.split('\n')) {
          if (line.trim().length == 0) continue;
          print(line);
          String key=line.split(':').first;
          header[key] = line.sub;
        } */
    //print(header);
    Note note = Note();

    note.file = file;

    note.title = header['title'];
    note.created = DateTime.parse(header['created']);
    note.modified = DateTime.parse(header['modified']);
    /* 
        note.tags =
            (header['tags'] as YamlList).map((s) => s.toString()).toList(); */
    note.tags = List.from((header['tags'] ?? []).cast<String>());
    note.attachments = List.from((header['attachments'] ?? []).cast<String>());

    note.pinned = header['pinned'] ?? false;
    note.favorite = header['favorite'] ?? false;
    note.deleted = header['deleted'] ?? false;

    return note;
  } */
}
