// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Search`
  String get Search {
    return Intl.message(
      'Search',
      name: 'Search',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get Delete {
    return Intl.message(
      'Delete',
      name: 'Delete',
      desc: '',
      args: [],
    );
  }

  /// `Remove`
  String get Remove {
    return Intl.message(
      'Remove',
      name: 'Remove',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get Cancel {
    return Intl.message(
      'Cancel',
      name: 'Cancel',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get Confirm {
    return Intl.message(
      'Confirm',
      name: 'Confirm',
      desc: '',
      args: [],
    );
  }

  /// `Restore`
  String get Restore {
    return Intl.message(
      'Restore',
      name: 'Restore',
      desc: '',
      args: [],
    );
  }

  /// `Trash`
  String get Trash {
    return Intl.message(
      'Trash',
      name: 'Trash',
      desc: '',
      args: [],
    );
  }

  /// `Star`
  String get Star {
    return Intl.message(
      'Star',
      name: 'Star',
      desc: '',
      args: [],
    );
  }

  /// `UnStar`
  String get UnStar {
    return Intl.message(
      'UnStar',
      name: 'UnStar',
      desc: '',
      args: [],
    );
  }

  /// `ALL`
  String get ALL {
    return Intl.message(
      'ALL',
      name: 'ALL',
      desc: '',
      args: [],
    );
  }

  /// `NONE`
  String get NONE {
    return Intl.message(
      'NONE',
      name: 'NONE',
      desc: '',
      args: [],
    );
  }

  /// `Pin`
  String get Pin {
    return Intl.message(
      'Pin',
      name: 'Pin',
      desc: '',
      args: [],
    );
  }

  /// `Unpin`
  String get Unpin {
    return Intl.message(
      'Unpin',
      name: 'Unpin',
      desc: '',
      args: [],
    );
  }

  /// `Pin selected`
  String get Pin_selected {
    return Intl.message(
      'Pin selected',
      name: 'Pin_selected',
      desc: '',
      args: [],
    );
  }

  /// `Unpin selected`
  String get Unpin_selected {
    return Intl.message(
      'Unpin selected',
      name: 'Unpin_selected',
      desc: '',
      args: [],
    );
  }

  /// `Favorite`
  String get Favorite {
    return Intl.message(
      'Favorite',
      name: 'Favorite',
      desc: '',
      args: [],
    );
  }

  /// `Unfavorite`
  String get Unfavorite {
    return Intl.message(
      'Unfavorite',
      name: 'Unfavorite',
      desc: '',
      args: [],
    );
  }

  /// `Favorite selected`
  String get Favorite_selected {
    return Intl.message(
      'Favorite selected',
      name: 'Favorite_selected',
      desc: '',
      args: [],
    );
  }

  /// `Unfavorite selected`
  String get Unfavorite_selected {
    return Intl.message(
      'Unfavorite selected',
      name: 'Unfavorite_selected',
      desc: '',
      args: [],
    );
  }

  /// `All Notes`
  String get All_Notes {
    return Intl.message(
      'All Notes',
      name: 'All_Notes',
      desc: '',
      args: [],
    );
  }

  /// `Untagged`
  String get Untagged {
    return Intl.message(
      'Untagged',
      name: 'Untagged',
      desc: '',
      args: [],
    );
  }

  /// `Tags`
  String get Tags {
    return Intl.message(
      'Tags',
      name: 'Tags',
      desc: '',
      args: [],
    );
  }

  /// `Add Tag to selected notes`
  String get Add_Tag_to_selected_notes {
    return Intl.message(
      'Add Tag to selected notes',
      name: 'Add_Tag_to_selected_notes',
      desc: '',
      args: [],
    );
  }

  /// `Add Tag`
  String get Add_Tag {
    return Intl.message(
      'Add Tag',
      name: 'Add_Tag',
      desc: '',
      args: [],
    );
  }

  /// `Remove Tag`
  String get Remove_Tag {
    return Intl.message(
      'Remove Tag',
      name: 'Remove_Tag',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get Add {
    return Intl.message(
      'Add',
      name: 'Add',
      desc: '',
      args: [],
    );
  }

  /// `Remove Tag from selected notes`
  String get Remove_Tag_from_selected_notes {
    return Intl.message(
      'Remove Tag from selected notes',
      name: 'Remove_Tag_from_selected_notes',
      desc: '',
      args: [],
    );
  }

  /// `Choose Tag to remove`
  String get Choose_Tag_to_remove {
    return Intl.message(
      'Choose Tag to remove',
      name: 'Choose_Tag_to_remove',
      desc: '',
      args: [],
    );
  }

  /// `Delete selected`
  String get Delete_selected {
    return Intl.message(
      'Delete selected',
      name: 'Delete_selected',
      desc: '',
      args: [],
    );
  }

  /// `Move to trash`
  String get Move_to_trash {
    return Intl.message(
      'Move to trash',
      name: 'Move_to_trash',
      desc: '',
      args: [],
    );
  }

  /// `Restore from trash`
  String get Restore_from_trash {
    return Intl.message(
      'Restore from trash',
      name: 'Restore_from_trash',
      desc: '',
      args: [],
    );
  }

  /// `Delete forever`
  String get Delete_forever {
    return Intl.message(
      'Delete forever',
      name: 'Delete_forever',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to delete the selected notes?`
  String get Do_you_really_want_to_delete_the_selected_notes {
    return Intl.message(
      'Do you really want to delete the selected notes?',
      name: 'Do_you_really_want_to_delete_the_selected_notes',
      desc: '',
      args: [],
    );
  }

  /// `This will delete them permanently.`
  String get This_will_delete_them_permanently {
    return Intl.message(
      'This will delete them permanently.',
      name: 'This_will_delete_them_permanently',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to exit the app?`
  String get Do_you_want_to_exit_the_app {
    return Intl.message(
      'Do you want to exit the app?',
      name: 'Do_you_want_to_exit_the_app',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get Exit {
    return Intl.message(
      'Exit',
      name: 'Exit',
      desc: '',
      args: [],
    );
  }

  /// `Sync`
  String get Sync {
    return Intl.message(
      'Sync',
      name: 'Sync',
      desc: '',
      args: [],
    );
  }

  /// `Sync Error`
  String get Sync_Error {
    return Intl.message(
      'Sync Error',
      name: 'Sync_Error',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get Ok {
    return Intl.message(
      'Ok',
      name: 'Ok',
      desc: '',
      args: [],
    );
  }

  /// `Untitled`
  String get Untitled {
    return Intl.message(
      'Untitled',
      name: 'Untitled',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get About {
    return Intl.message(
      'About',
      name: 'About',
      desc: '',
      args: [],
    );
  }

  /// `GitHub Repo`
  String get GitHub_Repo {
    return Intl.message(
      'GitHub Repo',
      name: 'GitHub_Repo',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get Preview {
    return Intl.message(
      'Preview',
      name: 'Preview',
      desc: '',
      args: [],
    );
  }

  /// `Disable Encryption`
  String get Disable_Encryption {
    return Intl.message(
      'Disable Encryption',
      name: 'Disable_Encryption',
      desc: '',
      args: [],
    );
  }

  /// `Encrypt`
  String get Encrypt {
    return Intl.message(
      'Encrypt',
      name: 'Encrypt',
      desc: '',
      args: [],
    );
  }

  /// `Add Attachment`
  String get Add_Attachment {
    return Intl.message(
      'Add Attachment',
      name: 'Add_Attachment',
      desc: '',
      args: [],
    );
  }

  /// `Enter Password`
  String get Enter_Password {
    return Intl.message(
      'Enter Password',
      name: 'Enter_Password',
      desc: '',
      args: [],
    );
  }

  /// `Set a password for the current document ( The password cannot be retrieved)`
  String get Set_Password {
    return Intl.message(
      'Set a password for the current document ( The password cannot be retrieved)',
      name: 'Set_Password',
      desc: '',
      args: [],
    );
  }

  /// `Delete Attachment`
  String get Delete_Attachment {
    return Intl.message(
      'Delete Attachment',
      name: 'Delete_Attachment',
      desc: '',
      args: [],
    );
  }

  /// `No MD title`
  String get No_MD_title {
    return Intl.message(
      'No MD title',
      name: 'No_MD_title',
      desc: '',
      args: [],
    );
  }

  /// `Conflict`
  String get Conflict {
    return Intl.message(
      'Conflict',
      name: 'Conflict',
      desc: '',
      args: [],
    );
  }

  /// `There is already a note with this title.`
  String get There_is_already_a_note_with_this_title {
    return Intl.message(
      'There is already a note with this title.',
      name: 'There_is_already_a_note_with_this_title',
      desc: '',
      args: [],
    );
  }

  /// `Decryption Failed`
  String get Decryption_Failed {
    return Intl.message(
      'Decryption Failed',
      name: 'Decryption_Failed',
      desc: '',
      args: [],
    );
  }

  /// `Retry password`
  String get Retry_password {
    return Intl.message(
      'Retry password',
      name: 'Retry_password',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get Back {
    return Intl.message(
      'Back',
      name: 'Back',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get Retry {
    return Intl.message(
      'Retry',
      name: 'Retry',
      desc: '',
      args: [],
    );
  }

  /// `Unsaved changes`
  String get Unsaved_changes {
    return Intl.message(
      'Unsaved changes',
      name: 'Unsaved_changes',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to discard your current changes?`
  String get Do_you_really_want_to_discard_your_current_changes {
    return Intl.message(
      'Do you really want to discard your current changes?',
      name: 'Do_you_really_want_to_discard_your_current_changes',
      desc: '',
      args: [],
    );
  }

  /// `Sort by Title`
  String get Sort_by_Title {
    return Intl.message(
      'Sort by Title',
      name: 'Sort_by_Title',
      desc: '',
      args: [],
    );
  }

  /// `Sort by Created Date`
  String get Sort_by_Created_Date {
    return Intl.message(
      'Sort by Created Date',
      name: 'Sort_by_Created_Date',
      desc: '',
      args: [],
    );
  }

  /// `Sort by Updated Date`
  String get Sort_by_Updated_Date {
    return Intl.message(
      'Sort by Updated Date',
      name: 'Sort_by_Updated_Date',
      desc: '',
      args: [],
    );
  }

  /// `Accent Color`
  String get Accent_Color {
    return Intl.message(
      'Accent Color',
      name: 'Accent_Color',
      desc: '',
      args: [],
    );
  }

  /// `Select accent color`
  String get Select_accent_color {
    return Intl.message(
      'Select accent color',
      name: 'Select_accent_color',
      desc: '',
      args: [],
    );
  }

  /// `Location`
  String get Location {
    return Intl.message(
      'Location',
      name: 'Location',
      desc: '',
      args: [],
    );
  }

  /// `Recreate tutorial notes`
  String get Recreate_tutorial_notes {
    return Intl.message(
      'Recreate tutorial notes',
      name: 'Recreate_tutorial_notes',
      desc: '',
      args: [],
    );
  }

  /// `Recreate`
  String get Recreate {
    return Intl.message(
      'Recreate',
      name: 'Recreate',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to recreate the tutorial notes and attachments?`
  String get Do_you_want_to_recreate_the_tutorial_notes {
    return Intl.message(
      'Do you want to recreate the tutorial notes and attachments?',
      name: 'Do_you_want_to_recreate_the_tutorial_notes',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get Settings {
    return Intl.message(
      'Settings',
      name: 'Settings',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get Language {
    return Intl.message(
      'Language',
      name: 'Language',
      desc: '',
      args: [],
    );
  }

  /// `English`
  String get en {
    return Intl.message(
      'English',
      name: 'en',
      desc: '',
      args: [],
    );
  }

  /// `中文-简体`
  String get zhCn {
    return Intl.message(
      '中文-简体',
      name: 'zhCn',
      desc: '',
      args: [],
    );
  }

  /// `中文-繁体`
  String get zhHant {
    return Intl.message(
      '中文-繁体',
      name: 'zhHant',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get Theme {
    return Intl.message(
      'Theme',
      name: 'Theme',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get Light {
    return Intl.message(
      'Light',
      name: 'Light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get Dark {
    return Intl.message(
      'Dark',
      name: 'Dark',
      desc: '',
      args: [],
    );
  }

  /// `Black / AMOLED`
  String get Black_AMOLED {
    return Intl.message(
      'Black / AMOLED',
      name: 'Black_AMOLED',
      desc: '',
      args: [],
    );
  }

  /// `Data Directory`
  String get Data_Directory {
    return Intl.message(
      'Data Directory',
      name: 'Data_Directory',
      desc: '',
      args: [],
    );
  }

  /// `Use external storage`
  String get Use_external_storage {
    return Intl.message(
      'Use external storage',
      name: 'Use_external_storage',
      desc: '',
      args: [],
    );
  }

  /// `Editor`
  String get Editor {
    return Intl.message(
      'Editor',
      name: 'Editor',
      desc: '',
      args: [],
    );
  }

  /// `Auto Save`
  String get Auto_Save {
    return Intl.message(
      'Auto Save',
      name: 'Auto_Save',
      desc: '',
      args: [],
    );
  }

  /// `Use Mode Switcher`
  String get Use_Mode_Switcher {
    return Intl.message(
      'Use Mode Switcher',
      name: 'Use_Mode_Switcher',
      desc: '',
      args: [],
    );
  }

  /// `Pair Brackets/Quotes`
  String get Pair_Quotes {
    return Intl.message(
      'Pair Brackets/Quotes',
      name: 'Pair_Quotes',
      desc: '',
      args: [],
    );
  }

  /// `Search content of notes`
  String get Search_content_of_notes {
    return Intl.message(
      'Search content of notes',
      name: 'Search_content_of_notes',
      desc: '',
      args: [],
    );
  }

  /// `Sort tags alphabetically in the sidebar`
  String get Sort_tags_alphabetically_in_the_sidebar {
    return Intl.message(
      'Sort tags alphabetically in the sidebar',
      name: 'Sort_tags_alphabetically_in_the_sidebar',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get More {
    return Intl.message(
      'More',
      name: 'More',
      desc: '',
      args: [],
    );
  }

  /// `Experimental`
  String get Experimental {
    return Intl.message(
      'Experimental',
      name: 'Experimental',
      desc: '',
      args: [],
    );
  }

  /// `Enable Dendron support`
  String get Enable_Dendron_support {
    return Intl.message(
      'Enable Dendron support',
      name: 'Enable_Dendron_support',
      desc: '',
      args: [],
    );
  }

  /// `Dendron is a IDEs note-taking tool`
  String get Dendron_is_a_VSCodeBased_NoteTaking_tool {
    return Intl.message(
      'Dendron is a IDEs note-taking tool',
      name: 'Dendron_is_a_VSCodeBased_NoteTaking_tool',
      desc: '',
      args: [],
    );
  }

  /// `Automatic list line mark`
  String get Automatic_list_mark {
    return Intl.message(
      'Automatic list line mark',
      name: 'Automatic_list_mark',
      desc: '',
      args: [],
    );
  }

  /// `Adds a list mark to a new line if the line before it had one`
  String get Adds_a_list_mark_to_a_new_line_if_the_line_before_it_had_one {
    return Intl.message(
      'Adds a list mark to a new line if the line before it had one',
      name: 'Adds_a_list_mark_to_a_new_line_if_the_line_before_it_had_one',
      desc: '',
      args: [],
    );
  }

  /// `Show virtual tags`
  String get Show_virtual_tags {
    return Intl.message(
      'Show virtual tags',
      name: 'Show_virtual_tags',
      desc: '',
      args: [],
    );
  }

  /// `Adds a virtual tag (#/path) to notes which are in a subdirectory`
  String get Adds_a_virtual_tag_to_notes_which_are_in_a_subdirectory {
    return Intl.message(
      'Adds a virtual tag (#/path) to notes which are in a subdirectory',
      name: 'Adds_a_virtual_tag_to_notes_which_are_in_a_subdirectory',
      desc: '',
      args: [],
    );
  }

  /// `Please input password`
  String get Please_input_password {
    return Intl.message(
      'Please input password',
      name: 'Please_input_password',
      desc: '',
      args: [],
    );
  }

  /// `Please enter password`
  String get Please_enter_password {
    return Intl.message(
      'Please enter password',
      name: 'Please_enter_password',
      desc: '',
      args: [],
    );
  }

  /// `Please enter passcode`
  String get Please_enter_passcode {
    return Intl.message(
      'Please enter passcode',
      name: 'Please_enter_passcode',
      desc: '',
      args: [],
    );
  }

  /// `Password is incorrect`
  String get Password_is_incorrect {
    return Intl.message(
      'Password is incorrect',
      name: 'Password_is_incorrect',
      desc: '',
      args: [],
    );
  }

  /// `Clear All`
  String get Clear_All {
    return Intl.message(
      'Clear All',
      name: 'Clear_All',
      desc: '',
      args: [],
    );
  }

  /// `Safety`
  String get Safety {
    return Intl.message(
      'Safety',
      name: 'Safety',
      desc: '',
      args: [],
    );
  }

  /// `Please set the screen lock passcode`
  String get Please_set_the_screen_lock_passcode {
    return Intl.message(
      'Please set the screen lock passcode',
      name: 'Please_set_the_screen_lock_passcode',
      desc: '',
      args: [],
    );
  }

  /// `Set the screen lock passcode`
  String get set_the_screen_lock_passcode {
    return Intl.message(
      'Set the screen lock passcode',
      name: 'set_the_screen_lock_passcode',
      desc: '',
      args: [],
    );
  }

  /// `Set the screen lock duration`
  String get Set_the_screen_lock_duration {
    return Intl.message(
      'Set the screen lock duration',
      name: 'Set_the_screen_lock_duration',
      desc: '',
      args: [],
    );
  }

  /// `Please set the encryption password ( The password cannot be retrieved)`
  String get Please_set_the_encryption_password {
    return Intl.message(
      'Please set the encryption password ( The password cannot be retrieved)',
      name: 'Please_set_the_encryption_password',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get Password {
    return Intl.message(
      'Password',
      name: 'Password',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get Confirm_Password {
    return Intl.message(
      'Confirm Password',
      name: 'Confirm_Password',
      desc: '',
      args: [],
    );
  }

  /// `Password cannot be empty`
  String get Password_cannot_be_empty {
    return Intl.message(
      'Password cannot be empty',
      name: 'Password_cannot_be_empty',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get Passwords_do_not_match {
    return Intl.message(
      'Passwords do not match',
      name: 'Passwords_do_not_match',
      desc: '',
      args: [],
    );
  }

  /// `Do you really want to delete this note?`
  String get Do_you_really_want_to_delete_this_note {
    return Intl.message(
      'Do you really want to delete this note?',
      name: 'Do_you_really_want_to_delete_this_note',
      desc: '',
      args: [],
    );
  }

  /// `This will delete it permanently.`
  String get This_will_delete_it_permanently {
    return Intl.message(
      'This will delete it permanently.',
      name: 'This_will_delete_it_permanently',
      desc: '',
      args: [],
    );
  }

  /// `Never`
  String get Never {
    return Intl.message(
      'Never',
      name: 'Never',
      desc: '',
      args: [],
    );
  }

  /// `Data`
  String get Data {
    return Intl.message(
      'Data',
      name: 'Data',
      desc: '',
      args: [],
    );
  }

  /// `Main Page`
  String get Main_Page {
    return Intl.message(
      'Main Page',
      name: 'Main_Page',
      desc: '',
      args: [],
    );
  }

  /// `Show subtitle`
  String get Show_subtitle {
    return Intl.message(
      'Show subtitle',
      name: 'Show_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `The subtitle contains the file name and tags`
  String get The_subtitle_contains_the_file_name_and_tags {
    return Intl.message(
      'The subtitle contains the file name and tags',
      name: 'The_subtitle_contains_the_file_name_and_tags',
      desc: '',
      args: [],
    );
  }

  /// `Content not found`
  String get Content_not_found {
    return Intl.message(
      'Content not found',
      name: 'Content_not_found',
      desc: '',
      args: [],
    );
  }

  /// `{num} minutes`
  String minutes(Object num) {
    return Intl.message(
      '$num minutes',
      name: 'minutes',
      desc: '',
      args: [num],
    );
  }

  /// `Please enter {len} digits`
  String Please_enter_digits(Object len) {
    return Intl.message(
      'Please enter $len digits',
      name: 'Please_enter_digits',
      desc: '',
      args: [len],
    );
  }

  /// `Please enter {min} to {max} characters`
  String Please_enter_characters(Object min, Object max) {
    return Intl.message(
      'Please enter $min to $max characters',
      name: 'Please_enter_characters',
      desc: '',
      args: [min, max],
    );
  }

  /// `Cannot be entered for {seconds} seconds`
  String Cannot_be_entered_for_seconds(Object seconds) {
    return Intl.message(
      'Cannot be entered for $seconds seconds',
      name: 'Cannot_be_entered_for_seconds',
      desc: '',
      args: [seconds],
    );
  }

  /// `{count} note(s) selected`
  String countSelectedNotes(Object count) {
    return Intl.message(
      '$count note(s) selected',
      name: 'countSelectedNotes',
      desc: '',
      args: [count],
    );
  }

  /// `Do you want to remove the tag {tag} from this note?`
  String Do_you_want_to_remove_the_tag_from_this_note(Object tag) {
    return Intl.message(
      'Do you want to remove the tag $tag from this note?',
      name: 'Do_you_want_to_remove_the_tag_from_this_note',
      desc: '',
      args: [tag],
    );
  }

  /// `Do you want to delete the attachment <{attachment}> ? This will remove it from this note and delete it permanently on disk.`
  String Do_you_want_to_delete_the_attachment(Object attachment) {
    return Intl.message(
      'Do you want to delete the attachment <$attachment> ? This will remove it from this note and delete it permanently on disk.',
      name: 'Do_you_want_to_delete_the_attachment',
      desc: '',
      args: [attachment],
    );
  }

  /// `Please try again in {cd} second(s)`
  String Please_try_again_in_cd_second(Object cd) {
    return Intl.message(
      'Please try again in $cd second(s)',
      name: 'Please_try_again_in_cd_second',
      desc: '',
      args: [cd],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
