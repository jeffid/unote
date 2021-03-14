import 'dart:io';

import 'package:app/utils/yaml.dart';
import 'package:preferences/preference_service.dart';
import 'package:front_matter/front_matter.dart' as fm;

import 'package:app/model/note.dart';

class PersistentStore {
  static Future<String> readContent(File file) async {
    if (!file.existsSync()) return null;

    String fileContent = await file.readAsString();

    if (fileContent.trimLeft().startsWith('---')) {
      var doc = fm.parse(fileContent);
      if (doc.content != null) return doc.content.trimLeft();
    }

    return fileContent.trimLeft();
  }

  static Future saveNote(Note note, [String content]) async {
    // print('PersistentStore.saveNote');

    if (content == null) {
      content = await readContent(note.file);
    }

    String header = '---\n';
    Map data = {};

    data['title'] = note.title;

    if (PrefService.getBool('notes_list_virtual_tags') ?? false) {
      note.tags.removeWhere((s) => s.startsWith('#/'));
    }

    if (note.tags.isNotEmpty) data['tags'] = note.tags;
    if (note.attachments.isNotEmpty) data['attachments'] = note.attachments;

    data['created'] = note.created.toIso8601String();
    data['modified'] = note.modified.toIso8601String();

    if (note.pinned) data['pinned'] = true;
    if (note.favorited) data['favorited'] = true;
    if (note.deleted) data['deleted'] = true;

    header += toYamlString(data);

    if (!header.endsWith('\n')) header += '\n';

    header += '---\n\n';

    // print(header);

    note.file.writeAsStringSync(header + content);
    /*  print(header + content); */
  }

  static Future<Note> readNote(File file) async {
    // print('PersistentStore.readNote');

    if (!file.existsSync()) return null;

    String fileContent = file.readAsStringSync();

    Map header;

    if (fileContent.trimLeft().startsWith('---')) {
      var doc = fm.parse(fileContent);
/* 
        String headerString = fileContent.split('---')[1]; */

      header = doc.data ?? {};
    } else {
      header = {};
    }

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

    if (note.title == null) {
      var title = file.path.split('/').last;
      if (title.endsWith('.md')) {
        title = title.substring(0, title.length - 3);
      }
      note.title = title;
    }

    if (header['modified'] != null) {
      note.modified = DateTime.parse(header['modified']);
    } else {
      note.modified = file.lastModifiedSync();
    }

    if (header['created'] != null) {
      note.created = DateTime.parse(header['created']);
    } else {
      note.created = note.modified;
    }

    /* 
        note.tags =
            (header['tags'] as YamlList).map((s) => s.toString()).toList(); */
    note.tags = List.from((header['tags'] ?? []).cast<String>());
    note.attachments = List.from((header['attachments'] ?? []).cast<String>());

    note.pinned = header['pinned'] ?? false;
    note.favorited = header['favorited'] ?? false;
    note.deleted = header['deleted'] ?? false;

    return note;
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
    note.favorited = header['favorited'] ?? false;
    note.deleted = header['deleted'] ?? false;

    return note;
  } */

  static Future deleteNote(Note note) async {
    await note.file.delete();
  }
}
