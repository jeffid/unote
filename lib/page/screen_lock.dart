import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:preferences/preference_service.dart';

import '/constant/app.dart' as ca;
import '/main.dart';
import '/generated/l10n.dart';
import '/store/encryption.dart';
// import '/utils/logger.dart';
import './form/pwd_form.dart';
import './note_list.dart';

///
void scLock({bool isCheckDuration = true}) {
  if (isCheckDuration) {
    int minute = PrefService.intDefault(ca.screenLockDuration);
    if (minute > 0) {
      // Timer(Duration(seconds: 8), () {
        Timer(Duration(minutes: minute), () {
        _screenLock();
      });
    }
    return;
  }

  _screenLock();
}

///
void _screenLock() {
  final BuildContext context = navKey.currentState!.overlay!.context;

  // get up-to-date pwd
  String pwd = PrefService.stringDefault(ca.screenLockPwd);
  if (pwd.isEmpty) return;

  showDialog(
      context: context,
      // barrierColor: themeData.dividerColor,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) async {},
          child: ScreenLockPage(),
        );
      });

  // showModalBottomSheet(
  //   context: context,
  //   isDismissible: false,
  //   isScrollControlled: true,
  //   // barrierColor: Colors.grey.withOpacity(0.99),
  //   barrierColor: themeData.dividerColor,
  //   backgroundColor: Colors.transparent,
  //   shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.zero)),
  //   builder: (BuildContext context) {
  //     return PopScope(
  //       canPop: false,
  //       onPopInvoked: (bool didPop) async {},
  //       child: Container(
  //         height: MediaQuery.of(context).size.height,
  //         width: MediaQuery.of(context).size.width,
  //         child: ScreenLockPage(),
  //       ),
  //     );
  //   },
  // );
}

///
class ScreenLockPage extends StatefulWidget {
  ScreenLockPage({
    bool this.isFirst = false,
  });

  /// is the first page
  final bool isFirst;

  static show(BuildContext context, {bool isFirst = false}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ScreenLockPage(isFirst: isFirst),
    ));
  }

  ///
  @override
  _ScreenLockPageState createState() => _ScreenLockPageState();
}

///
class _ScreenLockPageState extends State<ScreenLockPage> {
  final editingController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  String _pwd = '';

  @override
  void initState() {
    _pwd = PrefService.stringDefault(ca.screenLockPwd);

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus(); // default focus
    });
  }

  @override
  void dispose() {
    // logger.d('ScreenLockPage dispose');
    editingController.dispose();
    focusNode.dispose();

    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    final theme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(
        fontSize: 22,
        color: cs.onSurface,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.6)),
      ),
    );

    final cursor = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 9),
          width: 22,
          height: 1,
          color: cs.secondary,
        ),
      ],
    );

    return Scaffold(
      body: Container(
        color: themeData.dividerColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                S.current.Please_enter_passcode,
                style: TextStyle(fontSize: 20),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Pinput(
                  controller: editingController,
                  length: PwdForm.screenLockPwdLen,
                  // autofocus: true,
                  focusNode: focusNode,
                  obscureText: true,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  defaultPinTheme: theme,
                  validator: (v) {
                    debugPrint("validator: $v | ${pwdHashStr(v ?? '')}");
                    if (pwdHashStr(v!) == _pwd) {
                      _nav(widget.isFirst);
                      scLock();
                      return null;
                    }

                    return S.current.Password_is_incorrect;
                  },
                  // hapticFeedbackType: HapticFeedbackType.lightImpact,
                  // onCompleted: (v) {
                  //   debugPrint('onCompleted: $v');
                  // },
                  // onChanged: (v) {
                  //   debugPrint('onChanged: $v');
                  // },
                  cursor: cursor,
                  focusedPinTheme: theme.copyWith(
                    decoration: theme.decoration!.copyWith(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cs.onSurface),
                    ),
                  ),
                  errorPinTheme: theme.copyBorderWith(
                    border: Border.all(color: Colors.redAccent),
                  ),
                  errorTextStyle: TextStyle(color: Colors.redAccent),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  editingController.clear();
                  focusNode.requestFocus();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(MdiIcons.backspace),
                    SizedBox(width: 8),
                    Text(S.current.Clear_All),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///
  void _nav(bool isFirst) {
    isFirst
        ? NoteListPage.show(context, isFirst: true)
        : Navigator.pop(context);
  }
}
