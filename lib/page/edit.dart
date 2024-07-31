import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_info/device_info_plus.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import 'package:front_matter/front_matter.dart' as fm;
import 'package:markd/markdown.dart' as markd;
import 'package:bsdiff/bsdiff.dart';
import 'package:preferences/preference_service.dart';
import 'package:rich_code_editor/exports.dart';

import '/editor/pairer.dart';
import '/editor/syntax_highlighter.dart';
import '/main.dart';
import '/model/note.dart';
import '/page/preview.dart';
import '/store/notes.dart';
import '/store/persistent.dart';

///
class EditPage extends StatefulWidget {
  final Note note;
  final NotesStore store;
  final bool autofocus;

  EditPage(this.note, this.store, {this.autofocus = false});

  @override
  _EditPageState createState() => _EditPageState();
}

///
class _EditPageState extends State<EditPage> {
  late Note note;

  String currentData = '';

  List<Uint8List> history = [];

  List<int> cursorHistory = [];

  int autoSaveCounter = 0;

  bool _hasSaved = true;

  bool _previewEnabled = false;

  NoteSyntaxHighlighter _syntaxHighlighterBase = NoteSyntaxHighlighter();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  GlobalKey _richTextFieldKey = GlobalKey();

  late RichCodeEditingController _rec;

  late TextSelection _textSelectionCache;

  late ScrollController _scrollController;

  NotesStore get store => widget.store;

  ///
  @override
  void initState() {
    note = widget.note;
    _rec = RichCodeEditingController(_syntaxHighlighterBase);
    _scrollController = ScrollController();
    _loadContent();

    super.initState();
  }

  ///
  @override
  void dispose() {
    _richTextFieldKey.currentState?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    if (_syntaxHighlighterBase.accentColor == null)
      _syntaxHighlighterBase.init(Theme.of(context).colorScheme.secondary);

    // Disable note preview/render feature on Android KitKat see #32
    if (appInfo.platform.isAndroid &&
        (appInfo.platform.device as AndroidDeviceInfo).version.sdkInt < 20) {
      isPreviewFeatureEnabled = false;
    }

    logger.d(currentData);
    logger.d('_previewEnabled: ${_previewEnabled}');

    return PopScope(
      key: GlobalKey(),
      canPop: false,
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: store.isDendronModeEnabled
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(note.title),
                      Text(
                        note.file.path
                            .substring(store.notesDir.path.length + 1),
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      )
                    ],
                  )
                : Text(note.title),
            actions: <Widget>[
              if (!_hasSaved)
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: () async {
                    await _save();

                    setState(() {
                      _hasSaved = true;
                    });
                  },
                ),
              if (isPreviewFeatureEnabled)
                ((PrefService.getBool('editor_mode_switcher') ?? true)
                    ? Switch(
                        value: _previewEnabled,
                        activeColor: Theme.of(context).primaryIconTheme.color,
                        onChanged: (value) {
                          PrefService.setBool(
                              'editor_mode_switcher_is_preview', value);
                          setState(() {
                            _previewEnabled = value;
                          });
                        },
                      )
                    : IconButton(
                        icon: Icon(Icons.chrome_reader_mode),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: Text('Preview'),
                                ),
                                body: PreviewPage(
                                    store, _rec.text, _rec, Theme.of(context)),
                              ),
                            ),
                          );
                        },
                      )),
              _popupMenuButton()
            ],
          ),
          body: /* GestureDetector(
          child: */
              // _rec == null
              //     ? LinearProgressIndicator()
              //     :
              _previewEnabled
                  ? PreviewPage(store, _rec.text, _rec, Theme.of(context))
                  : Column(
                      children: <Widget>[
                        Expanded(
                          /*
                          fit: FlexFit.tight, */
                          child: Scrollbar(
                            controller: _scrollController,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichCodeField(
                                    key: _richTextFieldKey,
                                    controller: _rec,
                                    maxLines:
                                        null, // null: there is no limit to the number of lines to show at one time
                                    scrollPhysics:
                                        NeverScrollableScrollPhysics(),
                                    autofocus: widget.autofocus,
                                    style: TextStyle(
                                        fontFamily: 'FiraMono',
                                        fontFamilyFallback: ['monospace'],
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                    inputFormatters: [
                                      CharacterPair(PrefService.getBool(
                                              'editor_pair_brackets') ??
                                          false)
                                    ],
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    // decoration: null,
                                    syntaxHighlighter: _syntaxHighlighterBase,
                                    cursorColor:
                                        Theme.of(context).colorScheme.secondary,
                                    /* onChanged: (str) {
                                      }, */
                                    /* onBackSpacePress:
                                          (TextEditingValue oldValue) {}, */
                                    onEnterPress: (TextEditingValue oldValue) {
                                      if (PrefService.getBool(
                                              'auto_bullet_points') ??
                                          false) {
                                        _rec.value = _syntaxHighlighterBase
                                            .onEnterPress(oldValue);
                                        // if (result != null) {
                                        //   _rec.value = result;
                                        // }
                                      }
                                    }),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 42,
                          color: Theme.of(context).dividerColor,
                          child: Material(
                            color: Colors.grey.shade300,
                            child: Row(
                              // bottom tool bar
                              children: _bottomToolBar(),
                            ),
                          ),
                        )
                      ],
                    )),
    );
  }

  ///
  PopupMenuButton<String> _popupMenuButton() {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        _textSelectionCache = _rec.selection;
        return <PopupMenuEntry<String>>[
          PopupMenuItem<String>(
            value: 'favorite',
            child: Row(
              children: <Widget>[
                Icon(
                  note.favorite ? MdiIcons.starOff : MdiIcons.star,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(note.favorite ? 'Unfavorite' : 'Favorite'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'pin',
            child: Row(
              children: <Widget>[
                Icon(
                  note.pinned ? MdiIcons.pinOff : MdiIcons.pin,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(note.pinned ? 'Unpin' : 'Pin'),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'trash',
            child: Row(
              children: <Widget>[
                Icon(
                  note.deleted ? MdiIcons.deleteRestore : MdiIcons.delete,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(note.deleted ? 'Restore from trash' : 'Move to trash'),
              ],
            ),
          ),
          for (String attachment in note.attachments)
            PopupMenuItem<String>(
              value: 'removeAttachment.$attachment',
              child: Row(
                children: <Widget>[
                  Icon(
                    MdiIcons.paperclip,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    child: Text(attachment),
                  ),
                ],
              ),
            ),
          PopupMenuItem<String>(
            value: 'addAttachment',
            child: Row(
              children: <Widget>[
                Icon(
                  MdiIcons.filePlus,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(
                  width: 8,
                ),
                Text('Add Attachment'),
              ],
            ),
          ),
          //if (!store.isDendronModeEnabled) ...[
          for (String tag in note.tags)
            PopupMenuItem<String>(
              value: 'removeTag.$tag',
              child: Row(
                children: <Widget>[
                  Icon(
                    MdiIcons.tag,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(tag),
                ],
              ),
            ),
          PopupMenuItem<String>(
            value: 'addTag',
            child: Row(
              children: <Widget>[
                Icon(
                  MdiIcons.tagPlus,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(
                  width: 8,
                ),
                Text('Add Tag'),
              ],
            ),
          ),
          //]
        ];
      },
      onCanceled: () {
        _rec.selection = _textSelectionCache;
      },
      onSelected: (String result) async {
        _rec.selection = _textSelectionCache;
        int divIndex = result.indexOf('.');
        if (divIndex == -1) divIndex = result.length;

        switch (result.substring(0, divIndex)) {
          case 'favorite':
            note.favorite = !note.favorite;
            break;

          case 'pin':
            note.pinned = !note.pinned;
            break;

          case 'addAttachment':
            final result = await FilePicker.platform.pickFiles();
            File file = File(result!.files.first.path ?? '');

            if (file.existsSync()) {
              String fullFileName = file.path.split('/').last;
              int dotIndex = fullFileName.indexOf('.');

              String fileName = fullFileName.substring(0, dotIndex);
              String fileEnding = fullFileName.substring(dotIndex);

              File newFile =
                  File(store.attachmentsDir.path + '/' + fullFileName);

              int i = 0;

              while (newFile.existsSync()) {
                i++;
                newFile = File(store.attachmentsDir.path +
                    '/' +
                    fileName +
                    ' ($i)' +
                    fileEnding);
              }
              await file.copy(newFile.path);

              final attachmentName = newFile.path.split('/').last;

              note.attachments.add(attachmentName);

              await file.delete();

              int start = _rec.selection.start;

              final insert = '![](@attachment/$attachmentName)';
              try {
                _rec.text = _rec.text.substring(
                      0,
                      start,
                    ) +
                    insert +
                    _rec.text.substring(
                      start,
                    );

                _rec.selection = TextSelection(
                    baseOffset: start, extentOffset: start + insert.length);
              } catch (e) {
                // TODO Handle this case
              }
            }
            break;

          case 'removeAttachment':
            String attachment = result.substring(divIndex + 1);

            bool remove = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text('Delete Attachment'),
                          content: Text(
                              'Do you want to delete the attachment "$attachment"? This will remove it from this note and delete it permanently on disk.'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Delete'),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        )) ??
                false;
            if (remove) {
              File file = File(store.attachmentsDir.path + '/' + attachment);
              await file.delete();
              note.attachments.remove(attachment);
            }
            break;

          case 'trash':
            note.deleted = !note.deleted;
            break;

          case 'addTag':
            TextEditingController ctrl = TextEditingController();
            String newTag = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text('Add Tag'),
                          content: TextField(
                            controller: ctrl,
                            autofocus: true,
                            onSubmitted: (str) {
                              Navigator.of(context).pop(str);
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Add'),
                              onPressed: () {
                                Navigator.of(context).pop(ctrl.text);
                              },
                            ),
                          ],
                        )) ??
                '';
            if (newTag.isNotEmpty) {
              print('ADD');
              note.tags.add(newTag);
              store.updateTagList();
            }
            break;

          case 'removeTag':
            String tag = result.substring(divIndex + 1);

            bool remove = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text('Remove Tag'),
                          content: Text(
                              'Do you want to remove the tag "$tag" from this note?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('Remove'),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        )) ??
                false;
            if (remove) {
              print('REMOVE');
              note.tags.remove(tag);
              store.updateTagList();
            }
            break;
        }

        PersistentStore.saveNote(note);
      },
    );
  }

  ///
  List<Widget> _bottomToolBar() {
    logger.d('_bottomToolBar');
    return <Widget>[
      Flexible(
        fit: FlexFit.tight,
        child: SizedBox(
          height: double.infinity,
          child: InkWell(
            child: Icon(
              Icons.undo,
              color: history.isEmpty ? Colors.grey : null,
            ),
            onTap: history.isEmpty
                ? null
                : () {
                    currentData = utf8.decode(bspatch(
                        utf8.encode(currentData), history.removeLast()));

                    _rec.text = currentData;

                    int pos = cursorHistory.removeLast();
                    // if (pos > 0) pos--;

                    _rec.selection =
                        TextSelection(baseOffset: pos, extentOffset: pos);

                    // if (history.isEmpty) {
                    //   setState(() {});
                    // }

                    if (PrefService.getBool('editor_auto_save') ?? false) {
                      _autosave();
                    } else if (history.isNotEmpty && _hasSaved) {
                      setState(() {
                        _hasSaved = false;
                      });
                    } else if (history.isEmpty && !_hasSaved) {
                      setState(() {
                        _hasSaved = true;
                      });
                    }
                  },
          ),
        ),
      ),

      Container(
        width: 1,
        color: Colors.grey,
      ),
      Flexible(
        fit: FlexFit.tight,
        child: SizedBox(
          height: double.infinity,
          child: InkWell(
            child: Icon(
              MdiIcons.pound,
              size: 22,
            ),
            onTap: () {
              int oldStart = _rec.selection.start;

              int start = oldStart;

              while (start > 0) {
                start--;
                if (_rec.text[start] == '\n') break;
              }
              if (start != 0) start++;

              String startOfLine = _rec.text.substring(
                start,
              );
              String part = '';

              for (var s in startOfLine.split('')) {
                if (s != '#') break;
                part += s;
              }

              final before = _rec.text.substring(0, start);

              if (part == '######') {
                _rec.text = before + startOfLine.substring(6).trimLeft();
                _rec.selection = TextSelection(
                    baseOffset: oldStart - 7, extentOffset: oldStart - 7);
              } else {
                String change = '';
                if (part == '') {
                  change = '# ';
                } else {
                  change = '#';
                }
                _rec.text = before + change + startOfLine;
                _rec.selection = TextSelection(
                    baseOffset: oldStart + change.length,
                    extentOffset: oldStart + change.length);
              }
            },
          ),
        ),
      ),
      Flexible(
        fit: FlexFit.tight,
        child: SizedBox(
          height: double.infinity,
          child: InkWell(
            child: Icon(
              MdiIcons.formatListBulleted,
            ),
            onTap: () {
              // TODO Support * and >
              int oldStart = _rec.selection.start;

              int start = oldStart;

              while (start > 0) {
                start--;
                if (_rec.text[start] == '\n') break;
              }
              if (start != 0) start++;

              String startOfLine = _rec.text.substring(
                start,
              );
              final before = _rec.text.substring(0, start);

              if (startOfLine.trimLeft().startsWith('- ')) {
                int lengthDiff = startOfLine.length;

                lengthDiff = lengthDiff - (startOfLine.trimLeft().length);

                if (lengthDiff >= 8) {
                  _rec.text = before + startOfLine.trimLeft().substring(2);
                  _rec.selection = TextSelection(
                      baseOffset: oldStart - 2 - lengthDiff,
                      extentOffset: oldStart - 2 - lengthDiff);
                } else {
                  _rec.text = before + '  ' + startOfLine;
                  _rec.selection = TextSelection(
                      baseOffset: oldStart + 2, extentOffset: oldStart + 2);
                }
              } else {
                _rec.text = before + '- ' + startOfLine;
                _rec.selection = TextSelection(
                    baseOffset: oldStart + 2, extentOffset: oldStart + 2);
              }
            },
          ),
        ),
      ),
      Container(
        width: 1,
        color: Colors.grey,
      ),
      Flexible(
        fit: FlexFit.tight,
        child: SizedBox(
          height: double.infinity,
          child: InkWell(
            child: Icon(
              Icons.format_bold,
            ),
            onTap: () {
              int start = _rec.selection.start;
              int end = _rec.selection.end;

              final before = _rec.text.substring(0, _rec.selection.start);
              final content =
                  _rec.text.substring(_rec.selection.start, _rec.selection.end);
              final after = _rec.text.substring(_rec.selection.end);

              if (before.endsWith('**') && after.startsWith('**')) {
                _rec.text = before.substring(0, before.length - 2) +
                    content +
                    after.substring(2);
                _rec.selection =
                    TextSelection(baseOffset: start - 2, extentOffset: end - 2);
              } else {
                _rec.text = before + '**' + content + '**' + after;
                _rec.selection =
                    TextSelection(baseOffset: start + 2, extentOffset: end + 2);
              }
            },
          ),
        ),
      ),

      Flexible(
        fit: FlexFit.tight,
        child: SizedBox(
          height: double.infinity,
          child: InkWell(
            child: Icon(
              Icons.format_italic,
            ),
            onTap: () {
              int start = _rec.selection.start;
              int end = _rec.selection.end;

              if (_rec.text[start] == '_' &&
                  _rec.text[end - 1] == '_' &&
                  start != end) {
                start += 1;
                end -= 1;
                _rec.selection =
                    TextSelection(baseOffset: start, extentOffset: end);
              }

              final before = _rec.text.substring(0, _rec.selection.start);
              final content =
                  _rec.text.substring(_rec.selection.start, _rec.selection.end);
              final after = _rec.text.substring(_rec.selection.end);

              if (before.endsWith('_') && after.startsWith('_')) {
                _rec.text = before.substring(0, before.length - 1) +
                    content +
                    after.substring(1);

                _rec.selection =
                    TextSelection(baseOffset: start - 1, extentOffset: end - 1);
              } else {
                _rec.text = before + '_' + content + '_' + after;
                _rec.selection =
                    TextSelection(baseOffset: start + 1, extentOffset: end + 1);
              }
            },
          ),
        ),
      ),
      /* Flexible(
                                      fit: FlexFit.tight,
                                      child: SizedBox(
                                        height: double.infinity,
                                        child: InkWell(
                                          child: Icon(
                                            MdiIcons.checkBoxOutline,
                                          ),
                                          onTap: () {
                                            int oldStart = _rec.selection.start;

                                            int start = oldStart;

                                            while (start > 0) {
                                              start--;
                                              if (_rec.text[start] == '\n')
                                                break;
                                            }
                                            if (start != 0) start++;

                                            String startOfLine =
                                            _rec.text.substring(
                                              start,
                                            );
                                            final before =
                                            _rec.text.substring(0, start);

                                            if (startOfLine
                                                .trimLeft()
                                                .startsWith('- [ ]') || startOfLine
                                                .trimLeft()
                                                .startsWith('- [x]')) {
                                              int lengthDiff =
                                                  startOfLine.length;

                                              lengthDiff = lengthDiff -
                                                  (startOfLine
                                                      .trimLeft()
                                                      .length);

                                              if (lengthDiff >= 8) {
                                                _rec.text = before +
                                                    startOfLine
                                                        .trimLeft()
                                                        .substring(6);
                                                _rec.selection = TextSelection(
                                                    baseOffset: oldStart -
                                                        2 -
                                                        lengthDiff,
                                                    extentOffset: oldStart -
                                                        2 -
                                                        lengthDiff);
                                              } else {
                                                _rec.text =
                                                    before + '  ' + startOfLine;
                                                _rec.selection = TextSelection(
                                                    baseOffset: oldStart + 2,
                                                    extentOffset: oldStart + 2);
                                              }
                                            } else {
                                              _rec.text =
                                                  before + '- [ ] ' + startOfLine;
                                              _rec.selection = TextSelection(
                                                  baseOffset: oldStart + 6,
                                                  extentOffset: oldStart + 6);
                                            }
                                          },
                                        ),
                                      ),
                                    ), */
      // TODO Link and Image Helper
    ];
  }

  ///
  _autosave() async {
    autoSaveCounter++;

    final asf = autoSaveCounter;
    await Future.delayed(Duration(milliseconds: 500));

    if (asf == autoSaveCounter) {
      _save();
    }
  }

  ///
  Future<void> _save() async {
    String title;

    try {
      if (!currentData.trimLeft().startsWith('# ')) throw 'No MD title';

      String markedTitle = markd.markdownToHtml(
          RegExp(
                r'(?<=# ).*',
              ).stringMatch(currentData) ??
              '',
          extensionSet: markd.ExtensionSet.gitHubWeb);
      // print(markedTitle);

      title = markedTitle.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    } catch (e) {
      title = note.title;
    }
    // print(title);

    File? oldFile;
    if (note.title != title && !store.isDendronModeEnabled) {
      if (File(
              "${PrefService.getString('notable_notes_directory') ?? ''}/${title}.md")
          .existsSync()) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Conflict'),
                  content: Text('There is already a note with this title.'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Ok'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
        return;
      } else {
        oldFile = note.file;
        note.file = File(
            "${PrefService.getString('notable_notes_directory') ?? ''}/${title}.md");
      }
    }

    note.title = title;

    note.modified = DateTime.now();

    await PersistentStore.saveNote(note, currentData);

    if (oldFile != null) oldFile.deleteSync();
  }

  ///
  _loadContent() async {
    /*  String content = note.file.readAsStringSync();

    var doc = fm.parse(content); */
    final content = await PersistentStore.readContent(note);

    _rec = RichCodeEditingController(_syntaxHighlighterBase,
        text: content?.trimLeft() ?? '');

    _rec.addListener(() {
      if (_rec.text == currentData) return;

      var diff = bsdiff(utf8.encode(_rec.text), utf8.encode(currentData));
      var cursorPosition = max(
          0,
          _rec.text.length > currentData.length
              ? _rec.selection.start - 1
              : _rec.selection.start + 1);

      history.add(diff);
      cursorHistory.add(cursorPosition);

      if (history.length == 1) {
        // First entry
        setState(() {});
      } else if (history.length > 1000) {
        // First entry
        history.removeAt(0);
        cursorHistory.removeAt(0);
      }

      currentData = _rec.text;
      logger.d(history.toString());
      logger.d(history.length);
      if (PrefService.getBool('editor_auto_save') ?? false) {
        _autosave();
      } else if (_hasSaved) {
        setState(() {
          _hasSaved = false;
        });
      }
    });

    if (widget.autofocus) {
      _rec.selection =
          TextSelection(baseOffset: 2, extentOffset: _rec.text.trim().length);
    }

    currentData = _rec.text;

    //_updateMaxLines();
    if (PrefService.getBool('editor_mode_switcher') ?? true) {
      if (PrefService.getBool('editor_mode_switcher_is_preview') ?? false) {
        setState(() {
          _previewEnabled = true;
        });
      }
    }
    if (mounted) setState(() {});
  }

  ///
  Future<bool> _onWillPop() async {
    if (_hasSaved) return true;
    return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text('Unsaved changes'),
                  content: Text(
                      'Do you really want to discard your current changes?'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                    TextButton(
                      child: Text('Discard'),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    )
                  ],
                )) ??
        false;
  }

  ///
  void _onPopInvoked(bool didPop) async {
    logger.d('_onPopInvoked:: _hasSaved: ${_hasSaved} didPop: ${didPop} ');
    if (didPop) return;

    var shouldPop = false;
    if (_hasSaved) {
      shouldPop = true;
    } else {
      shouldPop = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: Text('Unsaved changes'),
                    content: Text(
                        'Do you really want to discard your current changes?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text('Exit'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      )
                    ],
                  )) ??
          false;
    }

    if (context.mounted && shouldPop) {
      Navigator.pop(context);
    }
  }

/*   int maxLines = 0;
  _updateMaxLines() {
    int newMaxLines = _rec.text.split('\n').length + 3;
    if (newMaxLines < 10) newMaxLines = 10;
    if (newMaxLines != maxLines) {
      setState(() {
        maxLines = newMaxLines;
      });
    }
  } */
}
