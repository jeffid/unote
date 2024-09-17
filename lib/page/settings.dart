import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inote/provider/setting.dart';
import 'package:intl/intl.dart';
import 'package:preferences/preferences.dart';
import 'package:provider/provider.dart';

import '/constant/app.dart' as ca;
import '/main.dart';
import '/generated/l10n.dart';
// import '/utils/logger.dart';
import '/provider/theme.dart';
import '/store/encryption.dart';
import '/store/notes.dart';
import '/store/persistent.dart';
import './screen_lock.dart';
import './widget/pwd_form.dart';

///
class SettingsPage extends StatefulWidget {
  final NotesStore store;

  SettingsPage(this.store);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

///
class _SettingsPageState extends State<SettingsPage> {
  ///
  NotesStore get store => widget.store;

  ///
  @override
  void initState() {
    PrefService.setDefaultValues({
      ca.lang: Intl.defaultLocale,
      ca.theme: ThemeType.light.name,
      ca.canSearchContent: true,
      ca.canShowModeSwitcher: true,
      ca.canPairMark: false,
      ca.canAutoSave: false,
      ca.canShowVirtualTags: false,
      ca.isSortTags: true,
      ca.canAutoListMark: true,
      ca.isDendronMode: false,
      ca.debugLogsSync: false,
    });
    super.initState();
  }

  ///
  @override
  Widget build(BuildContext context) {
    Color accentColor = themeData.colorScheme.secondary;
    // logger.d((ThemeType.light.toString(),ThemeType.light.name));

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.Settings),
      ),
      body: ListView(children: <Widget>[
        /// Language
        PreferenceTitle(S.current.Language),
        RadioPreference(
          S.current.en,
          ca.en,
          ca.lang,
          onSelect: () {
            Intl.defaultLocale = ca.en;
            if (mounted) setState(() {});
          },
          activeColor: accentColor,
          inactiveColor: accentColor,
        ),
        RadioPreference(
          S.current.zhCn,
          ca.zhCn,
          ca.lang,
          onSelect: () {
            Intl.defaultLocale = ca.zhCn;
            if (mounted) setState(() {});
          },
          activeColor: accentColor,
          inactiveColor: accentColor,
        ),

        /// Theme
        PreferenceTitle(S.current.Theme),
        RadioPreference(
          S.current.Light,
          ThemeType.light.name,
          ca.theme,
          // isDefault: true,
          onSelect: () {
            Provider.of<ThemeNotifier>(context, listen: false)
                .updateTheme(ThemeType.light.name);
          },
          activeColor: accentColor,
          inactiveColor: accentColor,
        ),
        RadioPreference(
          S.current.Dark,
          ThemeType.dark.name,
          ca.theme,
          onSelect: () {
            Provider.of<ThemeNotifier>(context, listen: false)
                .updateTheme(ThemeType.dark.name);
          },
          activeColor: accentColor,
          inactiveColor: accentColor,
        ),
        RadioPreference(
          S.current.Black_AMOLED,
          ThemeType.black.name,
          ca.theme,
          onSelect: () {
            Provider.of<ThemeNotifier>(context, listen: false)
                .updateTheme(ThemeType.black.name);
          },
          activeColor: accentColor,
          inactiveColor: accentColor,
        ),
        ListTile(
          title: Text(S.current.Accent_Color),
          trailing: Padding(
            padding: const EdgeInsets.only(right: 9, left: 9),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(3.0),
                color: Color(PrefService.getInt(ca.themeColor) ??
                    ThemeNotifier.defaultThemeColor.value),
              ),
              child: SizedBox(
                width: 28,
                height: 28,
              ),
            ),
          ),
          onTap: () async {
            Color? color = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text(S.current.Select_accent_color),
                      content: Container(
                        child: GridView.count(
                          crossAxisCount: 5,
                          children: [
                            for (Color color in [
                              ThemeNotifier.defaultThemeColor,
                              ...Colors.primaries,
                              ...Colors.accents,
                            ])
                              InkWell(
                                child: Container(
                                  margin: const EdgeInsets.all(5),
                                  color: color,
                                ),
                                onTap: () {
                                  Navigator.of(context).pop(color);
                                },
                              )
                          ],
                        ),
                        width: MediaQuery.of(context).size.width * .7,
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text(S.current.Cancel),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ));
            if (color != null) {
              PrefService.setInt(ca.themeColor, color.value);

              Provider.of<ThemeNotifier>(context, listen: false).accentColor =
                  color;
            }
          },
        ),

        /// Safety
        PreferenceTitle(S.current.Safety),
        SwitchPreference(
          S.current.set_the_screen_lock_passcode,
          ca.isScreenLock,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
          onEnable: () async {
            String pwd = await screenLockPwdDialog(context);
            if (pwd.isEmpty) throw S.current.Undo_change;
            String pwdHash = pwdHashStr(pwd);
            PrefService.setString(ca.screenLockPwd, pwdHash);

            // start screen lock
            scLock();
          },
          onDisable: () {
            PrefService.remove(ca.screenLockPwd);
          },
        ),
        ListTile(
          title: Text(S.current.Set_the_screen_lock_duration),
          trailing: DropdownButton<dynamic>(
            value: PrefService.intDefault(ca.screenLockDuration, def: 0),
            underline: Container(),
            onChanged: (v) {
              // debugPrint('Safety duration: $v');
              PrefService.setInt(ca.screenLockDuration, v);
              if (mounted) setState(() {});
            },
            items: <DropdownMenuItem>[
              DropdownMenuItem(
                value: 0,
                child: Text(S.current.Never),
              ),
              DropdownMenuItem(
                value: 5,
                child: Text(S.current.minutes(5)),
              ),
              DropdownMenuItem(
                value: 30,
                child: Text(S.current.minutes(30)),
              ),
              DropdownMenuItem(
                value: 60,
                child: Text(S.current.minutes(60)),
              ),
            ],
          ),
        ),

        /// Data Directory
        PreferenceTitle(S.current.Data),
        ListTile(
          title: Text(S.current.Location),
          subtitle: Text(PrefService.stringDefault(ca.dataPath)),
          onTap: () async {
            final String? path = await pickPath();
            if (path == null) return;

            Directory dir = Directory(path);
            if (dir.existsSync()) {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return PopScope(
                      canPop: false,
                      child: AlertDialog(
                        title: ListTile(
                          leading: CircularProgressIndicator(),
                          title: Text('Processing files...'),
                        ),
                      ),
                    );
                  });

              // set selected directory path
              PrefService.setString(ca.dataPath, dir.path);

              await store.refresh();
              if (mounted) setState(() {});
              Navigator.of(context).pop();
            }
          },
        ),

        /// Main Page
        PreferenceTitle(S.current.Main_Page),
        SwitchPreference(
          S.current.Search_content_of_notes,
          ca.canSearchContent,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),
        SwitchPreference(
          S.current.Show_subtitle,
          ca.isShowSubtitle,
          desc: S.current.The_subtitle_contains_the_file_name_and_tags,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
          onChange: () {
            Provider.of<SettingNotifier>(context, listen: false)
                .isShowSubtitle = PrefService.boolDefault(ca.isShowSubtitle);
          },
        ),
        ListTile(
          title: Text(S.current.Recreate_tutorial_notes),
          onTap: () async {
            if (await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text(S.current
                              .Do_you_want_to_recreate_the_tutorial_notes),
                          actions: <Widget>[
                            TextButton(
                              child: Text(S.current.Cancel),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: Text(S.current.Recreate),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            )
                          ],
                        )) ??
                false) {
              await store.createTutorialNotes();
              // await store.createTutorialAssets();
              await store.refresh();
            }
          },
        ),

        /// Editor
        PreferenceTitle(S.current.Editor),
        SwitchPreference(
          S.current.Auto_Save,
          ca.canAutoSave,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),
        SwitchPreference(
          S.current.Use_Mode_Switcher,
          ca.canShowModeSwitcher,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),
        SwitchPreference(
          S.current.Pair_Quotes,
          ca.canPairMark,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),
        SwitchPreference(
          S.current.Automatic_list_mark,
          ca.canAutoListMark,
          desc: S.current
              .Adds_a_list_mark_to_a_new_line_if_the_line_before_it_had_one,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),

        /// Tags
        PreferenceTitle(S.current.Tags),
        SwitchPreference(
          S.current.Sort_tags_alphabetically_in_the_sidebar,
          ca.isSortTags,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),
        SwitchPreference(
          S.current.Show_virtual_tags,
          ca.canShowVirtualTags,
          desc:
              S.current.Adds_a_virtual_tag_to_notes_which_are_in_a_subdirectory,
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),

        /// Experimental
        PreferenceTitle(S.current.Experimental),
        SwitchPreference(
          S.current.Enable_Dendron_support,
          ca.isDendronMode,
          desc: S.current.Dendron_is_a_VSCodeBased_NoteTaking_tool,
          onChange: () async {
            await store.refresh();

            if (mounted) setState(() {});
          },
          activeColor: accentColor,
          inactiveThumbColor: accentColor,
        ),

        // /// Preview
        // PreferenceTitle(S.current.Preview),
        // SwitchPreference(
        //   'Enable single line break syntax',
        //   'single_line_break_syntax',
        //   desc:
        //       'When enabled, single line breaks are rendered as real line breaks',
        //   activeColor: accentColor,
        //   inactiveThumbColor: accentColor,
        // ),

        // PreferenceTitle(S.current.Sync),
        // RadioPreference(
        //   'No Sync',
        //   '',
        //   'sync',
        //   isDefault: true,
        //   onSelect: () {
        //     setState(() {
        //       store.syncMethod = '';
        //     });
        //   },
        // ),
        // RadioPreference(
        //   'WebDav Sync',
        //   'webdav',
        //   'sync',
        //   onSelect: () {
        //     setState(() {
        //       store.syncMethod = 'webdav';
        //     });
        //   },
        // ),
        // if (store.syncMethod == 'webdav')
        //   Column(
        //     children: <Widget>[
        //       Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 16),
        //         child: Text(
        //           'WARNING: WebDav Sync is not supported! Please use another app to sync if possible (Syncthing is recommended) and do NOT use it for important data or accounts! ',
        //           style: TextStyle(color: Colors.red),
        //         ),
        //       ),
        //       TextFieldPreference(
        //         'Host',
        //         'sync_webdav_host',
        //         hintText: 'mynextcloud.tld/remote.php/webdav/',
        //       ),
        //       TextFieldPreference(
        //         'Path',
        //         'sync_webdav_path',
        //         hintText: 'notable',
        //       ),
        //       TextFieldPreference('Username', 'sync_webdav_username'),
        //       TextFieldPreference(
        //         'Password',
        //         'sync_webdav_password',
        //         obscureText: true,
        //       ),
        //     ],
        //   ),

        // PreferenceTitle('Debug'),
        // SwitchPreference(
        //   'Create sync logfile ',
        //   'debug_logs_sync',
        // ),
      ]),
    );
  }
}
