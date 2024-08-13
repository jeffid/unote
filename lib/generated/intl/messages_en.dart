// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(attachment) =>
      "Do you want to delete the attachment <${attachment}> ? This will remove it from this note and delete it permanently on disk.";

  static String m1(tag) =>
      "Do you want to remove the tag ${tag} from this note?";

  static String m2(cd) => "Please try again in ${cd} second(s)";

  static String m3(count) => "${count} note(s) selected";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "ALL": MessageLookupByLibrary.simpleMessage("ALL"),
        "About": MessageLookupByLibrary.simpleMessage("About"),
        "Accent_Color": MessageLookupByLibrary.simpleMessage("Accent Color"),
        "Add": MessageLookupByLibrary.simpleMessage("Add"),
        "Add_Attachment":
            MessageLookupByLibrary.simpleMessage("Add Attachment"),
        "Add_Tag": MessageLookupByLibrary.simpleMessage("Add Tag"),
        "Add_Tag_to_selected_notes":
            MessageLookupByLibrary.simpleMessage("Add Tag to selected notes"),
        "Adds_a_bullet_point_to_a_new_line_if_the_line_before_it_had_one":
            MessageLookupByLibrary.simpleMessage(
                "Adds a bullet point to a new line if the line before it had one"),
        "Adds_a_virtual_tag_to_notes_which_are_in_a_subdirectory":
            MessageLookupByLibrary.simpleMessage(
                "Adds a virtual tag (#/path) to notes which are in a subdirectory"),
        "All_Notes": MessageLookupByLibrary.simpleMessage("All Notes"),
        "Auto_Save": MessageLookupByLibrary.simpleMessage("Auto Save"),
        "Automatic_bullet_points":
            MessageLookupByLibrary.simpleMessage("Automatic bullet points"),
        "Back": MessageLookupByLibrary.simpleMessage("Back"),
        "Black_AMOLED": MessageLookupByLibrary.simpleMessage("Black / AMOLED"),
        "Cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "Choose_Tag_to_remove":
            MessageLookupByLibrary.simpleMessage("Choose Tag to remove"),
        "Confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
        "Conflict": MessageLookupByLibrary.simpleMessage("Conflict"),
        "Dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "Data_Directory":
            MessageLookupByLibrary.simpleMessage("Data Directory"),
        "Decryption_Failed":
            MessageLookupByLibrary.simpleMessage("Decryption Failed"),
        "Delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "Delete_Attachment":
            MessageLookupByLibrary.simpleMessage("Delete Attachment"),
        "Delete_forever":
            MessageLookupByLibrary.simpleMessage("Delete forever"),
        "Delete_selected":
            MessageLookupByLibrary.simpleMessage("Delete selected"),
        "Dendron_is_a_VSCodeBased_NoteTaking_tool":
            MessageLookupByLibrary.simpleMessage(
                "Dendron is a IDEs note-taking tool"),
        "Disable_Encryption":
            MessageLookupByLibrary.simpleMessage("Disable Encryption"),
        "Do_you_really_want_to_delete_the_selected_notes":
            MessageLookupByLibrary.simpleMessage(
                "Do you really want to delete the selected notes?"),
        "Do_you_really_want_to_discard_your_current_changes":
            MessageLookupByLibrary.simpleMessage(
                "Do you really want to discard your current changes?"),
        "Do_you_want_to_delete_the_attachment": m0,
        "Do_you_want_to_exit_the_app": MessageLookupByLibrary.simpleMessage(
            "Do you want to exit the app?"),
        "Do_you_want_to_recreate_the_tutorial_notes":
            MessageLookupByLibrary.simpleMessage(
                "Do you want to recreate the tutorial notes and attachments?"),
        "Do_you_want_to_remove_the_tag_from_this_note": m1,
        "Editor": MessageLookupByLibrary.simpleMessage("Editor"),
        "Enable_Dendron_support":
            MessageLookupByLibrary.simpleMessage("Enable Dendron support"),
        "Encrypt": MessageLookupByLibrary.simpleMessage("Encrypt"),
        "Enter_password":
            MessageLookupByLibrary.simpleMessage("Enter password"),
        "Exit": MessageLookupByLibrary.simpleMessage("Exit"),
        "Experimental": MessageLookupByLibrary.simpleMessage("Experimental"),
        "Favorite": MessageLookupByLibrary.simpleMessage("Favorite"),
        "Favorite_selected":
            MessageLookupByLibrary.simpleMessage("Favorite selected"),
        "GitHub_Repo": MessageLookupByLibrary.simpleMessage("GitHub Repo"),
        "Language": MessageLookupByLibrary.simpleMessage("Language"),
        "Light": MessageLookupByLibrary.simpleMessage("Light"),
        "Location": MessageLookupByLibrary.simpleMessage("Location"),
        "More": MessageLookupByLibrary.simpleMessage("More"),
        "Move_to_trash": MessageLookupByLibrary.simpleMessage("Move to trash"),
        "NONE": MessageLookupByLibrary.simpleMessage("NONE"),
        "No_MD_title": MessageLookupByLibrary.simpleMessage("No MD title"),
        "Ok": MessageLookupByLibrary.simpleMessage("Ok"),
        "Pair_Quotes":
            MessageLookupByLibrary.simpleMessage("Pair Brackets/Quotes"),
        "Pin": MessageLookupByLibrary.simpleMessage("Pin"),
        "Pin_selected": MessageLookupByLibrary.simpleMessage("Pin selected"),
        "Please_try_again_in_cd_second": m2,
        "Preview": MessageLookupByLibrary.simpleMessage("Preview"),
        "Recreate": MessageLookupByLibrary.simpleMessage("Recreate"),
        "Recreate_tutorial_notes":
            MessageLookupByLibrary.simpleMessage("Recreate tutorial notes"),
        "Remove": MessageLookupByLibrary.simpleMessage("Remove"),
        "Remove_Tag": MessageLookupByLibrary.simpleMessage("Remove Tag"),
        "Remove_Tag_from_selected_notes": MessageLookupByLibrary.simpleMessage(
            "Remove Tag from selected notes"),
        "Restore": MessageLookupByLibrary.simpleMessage("Restore"),
        "Restore_from_trash":
            MessageLookupByLibrary.simpleMessage("Restore from trash"),
        "Retry": MessageLookupByLibrary.simpleMessage("Retry"),
        "Retry_password":
            MessageLookupByLibrary.simpleMessage("Retry password"),
        "Search": MessageLookupByLibrary.simpleMessage("Search"),
        "Search_content_of_notes":
            MessageLookupByLibrary.simpleMessage("Search content of notes"),
        "Select_accent_color":
            MessageLookupByLibrary.simpleMessage("Select accent color"),
        "Settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "Show_virtual_tags":
            MessageLookupByLibrary.simpleMessage("Show virtual tags"),
        "Sort_by_Created_Date":
            MessageLookupByLibrary.simpleMessage("Sort by Created Date"),
        "Sort_by_Title": MessageLookupByLibrary.simpleMessage("Sort by Title"),
        "Sort_by_Updated_Date":
            MessageLookupByLibrary.simpleMessage("Sort by Updated Date"),
        "Sort_tags_alphabetically_in_the_sidebar":
            MessageLookupByLibrary.simpleMessage(
                "Sort tags alphabetically in the sidebar"),
        "Star": MessageLookupByLibrary.simpleMessage("Star"),
        "Sync": MessageLookupByLibrary.simpleMessage("Sync"),
        "Sync_Error": MessageLookupByLibrary.simpleMessage("Sync Error"),
        "Tags": MessageLookupByLibrary.simpleMessage("Tags"),
        "Theme": MessageLookupByLibrary.simpleMessage("Theme"),
        "There_is_already_a_note_with_this_title":
            MessageLookupByLibrary.simpleMessage(
                "There is already a note with this title."),
        "This_will_delete_them_permanently":
            MessageLookupByLibrary.simpleMessage(
                "This will delete them permanently."),
        "Trash": MessageLookupByLibrary.simpleMessage("Trash"),
        "UnStar": MessageLookupByLibrary.simpleMessage("UnStar"),
        "Unfavorite": MessageLookupByLibrary.simpleMessage("Unfavorite"),
        "Unfavorite_selected":
            MessageLookupByLibrary.simpleMessage("Unfavorite selected"),
        "Unpin": MessageLookupByLibrary.simpleMessage("Unpin"),
        "Unpin_selected":
            MessageLookupByLibrary.simpleMessage("Unpin selected"),
        "Unsaved_changes":
            MessageLookupByLibrary.simpleMessage("Unsaved changes"),
        "Untagged": MessageLookupByLibrary.simpleMessage("Untagged"),
        "Untitled": MessageLookupByLibrary.simpleMessage("Untitled"),
        "Use_Mode_Switcher":
            MessageLookupByLibrary.simpleMessage("Use Mode Switcher"),
        "Use_external_storage":
            MessageLookupByLibrary.simpleMessage("Use external storage"),
        "countSelectedNotes": m3,
        "en": MessageLookupByLibrary.simpleMessage("English"),
        "zhCn": MessageLookupByLibrary.simpleMessage("中文-简体"),
        "zhHant": MessageLookupByLibrary.simpleMessage("中文-繁体")
      };
}
