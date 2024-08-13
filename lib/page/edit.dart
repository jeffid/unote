import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bsdiff/bsdiff.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_info/device_info_plus.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:markd/markdown.dart' as markd;
import 'package:markdown_toolbar/markdown_toolbar.dart';
import 'package:path/path.dart' as p;
import 'package:preferences/preference_service.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
// import 'package:front_matter/front_matter.dart' as fm;
// import 'package:markdown_toolbar/markdown_toolbar.dart';

import '/constant/app.dart' as ca;
import '/main.dart';
import '/generated/l10n.dart';
import '/model/note.dart';
import '/store/encryption.dart';
import '/store/notes.dart';
import '/store/persistent.dart';
import '/utils/logger.dart';
import './preview.dart';
// import '/editor/pairer.dart';

///
class EditPage extends StatefulWidget {
  //
  EditPage(this.note, this.store, {this.autofocus = false});

  final Note note;
  final NotesStore store;
  final bool autofocus;

  ///
  @override
  _EditPageState createState() => _EditPageState();
}

///
class _EditPageState extends State<EditPage> {
  //
  late Note note;

  String currentData = '';

  List<Uint8List> history = [];

  List<int> cursorHistory = [];

  int autoSaveCounter = 0;

  bool _hasSaved = true;

  bool _previewEnabled = false;

  // bool _isContentReady = false;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  GlobalKey _richTextFieldKey = GlobalKey();

  late TextEditingController _editCtrl;

  final FocusNode _focusNode = FocusNode();

  late TextSelection _textSelection;

  NotesStore get store => widget.store;

  ///
  @override
  void initState() {
    note = widget.note;
    _initEditCtrl();

    _loadContent();

    //_updateMaxLines();
    if (PrefService.getBool(ca.canShowModeSwitcher) ?? true) {
      if (PrefService.getBool(ca.isPreviewMode) ?? false) {
        setState(() {
          _previewEnabled = true;
        });
      }
    }

    super.initState();
  }

  ///
  @override
  void dispose() {
    _editCtrl.dispose();
    _focusNode.dispose();

    _richTextFieldKey.currentState?.dispose();
    // _scrollController.dispose();

    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    // Disable note preview/render feature on Android KitKat see #32
    if (appInfo.platform.isAndroid &&
        (appInfo.platform.device as AndroidDeviceInfo).version.sdkInt < 20) {
      isPreviewFeatureEnabled = false;
    }

    // logger.d(currentData);
    // logger.d('_previewEnabled: ${_previewEnabled}');

    return PopScope(
      key: GlobalKey(),
      canPop: false,
      onPopInvoked: _onPopInvoked,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: _appBar(),
        body:
            // !_isContentReady
            //     ? LinearProgressIndicator()
            // :
            _previewEnabled
                ? PreviewPage(_editCtrl.text)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      MarkdownToolbar(
                        useIncludedTextField: false,
                        controller: _editCtrl,
                        focusNode: _focusNode,
                        width: 50,
                        height: 35,
                      ),
                      Divider(
                        color: themeData.dividerColor,
                      ),
                      Expanded(
                        child: TextField(
                          controller: _editCtrl,
                          focusNode: _focusNode,
                          minLines: 500,
                          maxLines: null,
                          autofocus: widget.autofocus,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(6, 4, 0, 4),
                          ),
                          textInputAction: TextInputAction.none,
                          onSubmitted: (value) {
                            _editCtrl.value = _onEnterPress(
                                _editCtrl.text, _editCtrl.selection.start);
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  ///
  AppBar _appBar() {
    return AppBar(
      title: store.isDendronMode
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(note.title),
                Text(
                  note.file.path.substring(store.notesDir.path.length + 1),
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
          ((PrefService.getBool(ca.canShowModeSwitcher) ?? true)
              ? Switch(
                  value: _previewEnabled,
                  // activeColor: Theme.of(context).primaryIconTheme.color,
                  activeColor: themeData.colorScheme.onSurface,
                  inactiveThumbColor: themeData.colorScheme.onSurface,
                  trackOutlineWidth: WidgetStateProperty.resolveWith<double>(
                    (Set<WidgetState> states) {
                      return 1;
                    },
                  ),
                  trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      // return themeData.colorScheme.onSurface;
                      return Colors.grey;
                    },
                  ),
                  onChanged: (value) {
                    PrefService.setBool(ca.isPreviewMode, value);
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
                            title: Text(S.current.Preview),
                          ),
                          body: PreviewPage(_editCtrl.text),
                        ),
                      ),
                    );
                  },
                )),
        _popupMenuButton()
      ],
    );
  }

  ///
  PopupMenuButton<String> _popupMenuButton() {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) {
        _textSelection = _editCtrl.selection;
        return <PopupMenuEntry<String>>[
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
                Text(note.pinned ? S.current.Unpin : S.current.Pin),
              ],
            ),
          ),
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
                Text(note.favorite ? S.current.Unfavorite : S.current.Favorite),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'encrypt',
            child: Row(
              children: <Widget>[
                Icon(
                  note.encrypted ? MdiIcons.lockOff : MdiIcons.lock,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(note.encrypted
                    ? S.current.Disable_Encryption
                    : S.current.Encrypt),
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
                Text(note.deleted
                    ? S.current.Restore_from_trash
                    : S.current.Move_to_trash),
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
                Text(S.current.Add_Tag),
              ],
            ),
          ),
          //]
        ];
      },
      onCanceled: () {
        _editCtrl.selection = _textSelection;
      },
      onSelected: (String result) async {
        _editCtrl.selection = _textSelection;
        int divIndex = result.indexOf('.');
        if (divIndex == -1) divIndex = result.length;

        switch (result.substring(0, divIndex)) {
          case 'encrypt':
            note.encrypted = !note.encrypted;
            //
            if (note.encrypted) {
              TextEditingController ctrl = TextEditingController();
              String pwd = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(S.current.Enter_password),
                      content: TextField(
                        controller: ctrl,
                        autofocus: true,
                        onSubmitted: (str) {
                          Navigator.of(context).pop(str);
                        },
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(S.current.Cancel),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text(S.current.Confirm),
                          onPressed: () {
                            Navigator.of(context).pop(ctrl.text);
                          },
                        ),
                      ],
                    ),
                  ) ??
                  '';
              if (pwd.isEmpty) {
                // recover `encrypted` value
                note.encrypted = false;
                break;
              } else {
                note.encryption = Encryption(key: pwd);
              }
            } else {
              // Disable encryption
              // note.encryption = null;
            }
            break;

          case 'favorite':
            note.favorite = !note.favorite;
            break;

          case 'pin':
            note.pinned = !note.pinned;
            break;

          case 'addAttachment':
            final result = await FilePicker.platform.pickFiles();
            if (result == null) break;
            File file = File(result.files.first.path ?? '');
            if (!file.existsSync()) break;

            String fullFileName = p.basename(file.path);
            String fileName = fullFileName.split('.').first;
            String ext = p.extension(file.path);

            int i = 0;
            File newFile;
            do {
              fullFileName = i > 0 ? fileName + ' ($i)' + ext : fullFileName;
              newFile =
                  File(store.attachmentsDir.path + p.separator + fullFileName);

              i++;
            } while (newFile.existsSync());

            await file.copy(newFile.path);

            final attachmentName = p.basename(newFile.path);

            note.attachments.add(attachmentName);

            await file.delete();

            int start = _editCtrl.selection.start;

            final insert = '![](@attachment/$attachmentName)';
            try {
              _editCtrl.text = _editCtrl.text.substring(0, start) +
                  insert +
                  _editCtrl.text.substring(start);

              _editCtrl.selection = TextSelection(
                  baseOffset: start, extentOffset: start + insert.length);
            } catch (e) {
              // TODO Handle this case
            }

            break;

          case 'removeAttachment':
            String attachment = result.substring(divIndex + 1);

            bool remove = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text(S.current.Delete_Attachment),
                          content: Text(S.current
                              .Do_you_want_to_delete_the_attachment(
                                  attachment)),
                          actions: <Widget>[
                            TextButton(
                              child: Text(S.current.Cancel),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(S.current.Delete),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        )) ??
                false;
            if (remove) {
              File file =
                  File(store.attachmentsDir.path + p.separator + attachment);
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
                          title: Text(S.current.Add_Tag),
                          content: TextField(
                            controller: ctrl,
                            autofocus: true,
                            onSubmitted: (str) {
                              Navigator.of(context).pop(str);
                            },
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text(S.current.Cancel),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(S.current.Add),
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
                          title: Text(S.current.Remove_Tag),
                          content: Text(S.current
                              .Do_you_want_to_remove_the_tag_from_this_note(
                                  tag)),
                          actions: <Widget>[
                            TextButton(
                              child: Text(S.current.Cancel),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(S.current.Remove),
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

        PersistentStore.saveNote(note, _editCtrl.text);
      },
    );
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
      if (!currentData.trimLeft().startsWith('# ')) throw S.current.No_MD_title;

      String markedTitle = markd.markdownToHtml(
          RegExp(r'(?<=# ).*').stringMatch(currentData) ?? '',
          extensionSet: markd.ExtensionSet.gitHubWeb);
      // print(markedTitle);

      title = markedTitle.replaceAll(RegExp(r'<[^>]*>'), '').trim();
      logger.d(title);
    } catch (e) {
      title = note.title;
    }
    // print(title);

    File? oldFile;
    if (note.title != title && !store.isDendronMode) {
      if (File("${PrefService.getString(ca.notesDirectory) ?? ''}/${title}.md")
          .existsSync()) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text(S.current.Conflict),
                  content:
                      Text(S.current.There_is_already_a_note_with_this_title),
                  actions: <Widget>[
                    TextButton(
                      child: Text(S.current.Ok),
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
            "${PrefService.getString(ca.notesDirectory) ?? ''}/${title}.md");
      }
    }

    note.title = title;

    note.updated = DateTime.now();

    await PersistentStore.saveNote(note, currentData);

    if (oldFile != null) oldFile.deleteSync();
  }

  ///
  void _initEditCtrl() {
    RegExp boldItalic = RegExp(r'\*\*\*[^\*\r\n]+?\*\*\*|___[^_\r\n]+?___');
    RegExp bold = RegExp(r'\*\*[^\*\r\n]+?\*\*|__[^_\r\n]+?__');
    RegExp italic = RegExp(r'\*[^\*\r\n]+?\*|\b_[^_\r\n]+?_\b');
    RegExp strikeThrough = RegExp(r'~~.+?~~');
    RegExp link = RegExp(r'\[([^\[\]]*?)\]\(([^\(\)]+?)\)');
    RegExp image = RegExp(r'!\[([^\[\]]*?)\]\(([^\(\)]+?)\)');
    RegExp horizontal = RegExp(r'^(?<=\s*)-{3,}(?=\s*$)');
    RegExp numberList = RegExp(r'^(?<=\s*)\d+\.(?=\s+?)');
    RegExp bulletedList = RegExp(r'^(?<=\s*)[-\*](?=\s+?)');
    RegExp inlineBlock = RegExp(r'(?<!`)`[^`\r\n]+?`(?!`)', multiLine: true);
    RegExp multiLineBlock = RegExp(r'^```[^`]+```$', multiLine: true);

    _editCtrl = RichTextController(
      regExpMultiLine: true,
      regExpCaseSensitive: false,
      targetMatches: [
        MatchTargetItem(
          text: 'todo',
          style: TextStyle(
            color: themeData.colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
          allowInlineMatching: true,
        ),
        for (int i = 1; i < 7; i++)
          MatchTargetItem(
            regex: RegExp('^#{$i}' r'\s+(.+?)(?=\s*$)'), // Headings
            style: TextStyle(
              color: themeData.colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: (21 - i).toDouble(),
            ),
            allowInlineMatching: true,
          ),
        MatchTargetItem(
          regex: boldItalic,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
          allowInlineMatching: true,
        ),
        MatchTargetItem(
          regex: bold,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
          allowInlineMatching: true,
        ),
        MatchTargetItem(
          regex: italic,
          style: TextStyle(
            fontStyle: FontStyle.italic,
          ),
          allowInlineMatching: true,
        ),
        MatchTargetItem(
          regex: strikeThrough,
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
          ),
          allowInlineMatching: true,
        ),
        MatchTargetItem(
          regex: link,
          style: TextStyle(
            color: Colors.blue,
          ),
          allowInlineMatching: true,
        ),
        MatchTargetItem(
          regex: image,
          style: TextStyle(
            color: Colors.blue,
          ),
          allowInlineMatching: true,
        ),
        MatchTargetItem(
          regex: numberList,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
          allowInlineMatching: true,
        ),
        MatchTargetItem(
          regex: bulletedList,
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
          allowInlineMatching: true,
        ),
        MatchTargetItem(
          regex: inlineBlock,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            backgroundColor: themeData.dividerColor,
          ),
          allowInlineMatching: true,
        ),
        MatchTargetItem(
          regex: multiLineBlock,
          style: TextStyle(
            // fontWeight: FontWeight.w500,
            backgroundColor: themeData.dividerColor,
          ),
          allowInlineMatching: true,
        ),
        MatchTargetItem(
          regex: horizontal,
          style: TextStyle(
            color: themeData.colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
          allowInlineMatching: true,
        ),
      ],
      onMatch: (List<String> matches) {
        // Do something with matches.
        // as long as you're typing, the controller will keep updating the list.
        logger.d(matches);
      },
      deleteOnBack: true,
      // You can control the [RegExp] options used:
      regExpUnicode: true,
    );

    //
    _editCtrl.addListener(() {
      if (_editCtrl.text == currentData) return;

      Uint8List diff =
          bsdiff(utf8.encode(_editCtrl.text), utf8.encode(currentData));
      logger.d((
        'ctrl Listener',
        diff,
      ));
      int cursorPosition = max(
          0,
          _editCtrl.text.length > currentData.length
              ? _editCtrl.selection.start - 1
              : _editCtrl.selection.start + 1);

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

      currentData = _editCtrl.text;
      // logger.d(history.toString());
      // logger.d(history.length);
      if (PrefService.getBool(ca.canAutoSave) ?? false) {
        _autosave();
      } else if (_hasSaved) {
        setState(() {
          _hasSaved = false;
        });
      }
    });
  }

  ///
  _loadContent() async {
    /*  String content = note.file.readAsStringSync();
    var doc = fm.parse(content); */
    String content = '';
    while (true) {
      content = await PersistentStore.readContent(note);

      // The password entered cannot decrypt the document back to the previous page
      if (note.encrypted && !note.isDecryptSuccess) {
        TextEditingController ctrl = TextEditingController();
        final (cd, canRetry) = note.canRetry();

        String newPwd = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(S.current.Decryption_Failed),
                // content: Text('The password entered cannot decrypt this note.'),
                content: TextField(
                  controller: ctrl,
                  autofocus: true,
                  readOnly: !canRetry,
                  decoration: InputDecoration(
                    hintText: canRetry
                        ? S.current.Retry_password
                        : S.current.Please_try_again_in_cd_second(cd),
                  ),
                  onSubmitted: (str) {
                    Navigator.of(context).pop(str);
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(S.current.Back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(S.current.Retry),
                    onPressed: canRetry
                        ? () => Navigator.of(context).pop(ctrl.text)
                        : null,
                  ),
                ],
              ),
            ) ??
            '';
        if (newPwd.isNotEmpty) {
          // retry decryption
          note.encryption = Encryption(key: newPwd);
        } else {
          // not retry, back to previous page
          Navigator.pop(context);
          break;
        }
      } else {
        // compleleted read content
        break;
      }
    }

    currentData = content;

    _editCtrl.text = content;

    if (widget.autofocus) {
      // select title after create new note (e.g., `# Untitled`)
      // must after [readContent]
      _editCtrl.selection = TextSelection(
          baseOffset: 2, extentOffset: _editCtrl.text.trimRight().length);
    }

    if (mounted) {
      setState(() {
        // _isContentReady = true;
      });
    }
  }

  /// [_onEnterPress]
  /// [cursorIdx] is selection.start
  TextEditingValue _onEnterPress(String text, int cursorIdx) {
    int offset = cursorIdx;

    // before part without CR(13) or LF(10) at end
    final String befPart = text.substring(0, cursorIdx);

    String befLine = befPart.split('\n').last;

    // list mark
    RegExpMatch? match =
        RegExp(r'^(\s*)([-\*]|\d+)(\.?)(\s+)(.*)$').firstMatch(befLine);
    int spaceLen = 0;
    String befLineWords = '';
    String mark = '';
    if (match != null) {
      spaceLen = match[1]!.length;
      befLineWords = match[5]!;

      mark = match[2]!;
      int? markNum = num.tryParse(mark)?.toInt();
      if (markNum != null && match[3]!.isNotEmpty) {
        // increase list number
        mark = (markNum + 1).toString() + '.';
      }
    }
    int befLineLen = befLine.length;
    int befTextLen = befLineLen - spaceLen;

    if (mark.isNotEmpty) {
      if (befLineWords.isEmpty) {
        if (spaceLen >= 2) {
          // indent two spaces
          int befTextStart = cursorIdx - befTextLen;
          text = text.substring(0, befTextStart - 2) +
              text.substring(befTextStart);
          offset = cursorIdx - 2;
        } else {
          // delete empty list line
          int befLineStart = cursorIdx - befLineLen;
          text = text.substring(0, befLineStart) + text.substring(cursorIdx);
          offset = befLineStart;
        }
      } else {
        // add new list line with mark at the start
        if (spaceLen > 0) mark = List.filled(spaceLen, ' ').join() + mark;
        mark = '\n$mark ';
        text = befPart + mark + text.substring(cursorIdx);
        offset = cursorIdx + mark.length;
      }
    } else {
      // add new empty line
      text = befPart + '\n' + text.substring(cursorIdx);
      offset = cursorIdx + 1;
    }

    return TextEditingValue(
      text: text,
      composing: TextRange.empty,
      selection: TextSelection.fromPosition(
        TextPosition(affinity: TextAffinity.upstream, offset: offset),
      ),
    );
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
                    title: Text(S.current.Unsaved_changes),
                    content: Text(S.current
                        .Do_you_really_want_to_discard_your_current_changes),
                    actions: <Widget>[
                      TextButton(
                        child: Text(S.current.Cancel),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      TextButton(
                        child: Text(S.current.Exit),
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
