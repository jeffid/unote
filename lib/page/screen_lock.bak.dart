import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pin;
import 'package:pinput/pinput.dart';
import 'package:preferences/preference_service.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';

import '/constant/app.dart' as ca;
import '/main.dart';
import '/generated/l10n.dart';
import '/store/encryption.dart';
import '/utils/logger.dart';
import './form/pwd_form.dart';
import './note_list.dart';

class ScreenLockPage extends StatefulWidget {
  ScreenLockPage({
    bool this.isFirst = false,
    bool this.isCheckDuration = true,
  });

  /// password length
  static const int pwdLen = 5;

  /// is the first page
  final bool isFirst;

  /// is waiting duration; `false`: screen lock immediately
  final bool isCheckDuration;

  static show(BuildContext context,
      {bool isFirst = false, bool isCheckDuration = true}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ScreenLockPage(
        isFirst: isFirst,
        isCheckDuration: isCheckDuration,
      ),
    ));
  }

  ///
  @override
  _ScreenLockPageState createState() => _ScreenLockPageState();
}

class _ScreenLockPageState extends State<ScreenLockPage> {
  String _pwd = '';
  // String err = '';
  // Timer? _timer;

  // bool _hasError = false;
  // String _currentText = "";
  // final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // formKey = GlobalKey<FormState>();
    // pinController = TextEditingController();
    // focusNode = FocusNode();

    _pwd = PrefService.stringDefault(ca.screenLockPwd);

    // _errorController = StreamController<ErrorAnimationType>();

    // showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //           title: Text('1233333'),
    //         ));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pwd.isEmpty
          ? _nav(widget.isFirst)
          : _lock(
              isFirst: widget.isFirst, isCheckDuration: widget.isCheckDuration);
    });
  }

  // @override
  void dispose() {
    // _timer?.cancel();
    logger.d('ScreenLockPage dispose');
    // _errorController!.close();

    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Material();
    // return Scaffold(
        // appBar: AppBar(title: Text(S.current.About)),

        // body: Center(
        //     child: ScreenLock(
        //   // context: context,
        //   title: Text(S.current.Please_enter_password),
        //   correctString: _pwd,
        //   maxRetries: 2,
        //   retryDelay: const Duration(seconds: 5),
        //   delayBuilder: (context, delay) => Text(
        //     // 'Cannot be entered for ${(delay.inMilliseconds / 1000).ceil()} seconds.',
        //     S.current.Cannot_be_entered_for_seconds(
        //         (delay.inMilliseconds / 1000).ceil()),
        //   ),
        //   keyPadConfig: const KeyPadConfig(
        //     clearOnLongPressed: true,
        //   ),
        //   onUnlocked: () {
        //     // 跳转到首页
        //     // if (!widget.isFirst) Navigator.pop(context);
        //     // if (widget.isFirst) NoteListPage.show(context, isFirst: true);
        //     widget.isFirst
        //         ? NoteListPage.show(context, isFirst: true)
        //         : Navigator.pop(context);
        //     _reLock();
        //   },
        // )),
        // );
  }

  ///
  void _lock({bool isFirst = false, bool isCheckDuration = true}) {
    if (isCheckDuration) {
      int minute = PrefService.intDefault(ca.screenLockDuration);
      if (minute > 0) {
        Timer(Duration(seconds: 10), () {
          // Timer(Duration(minutes: minute), () {
          _screenLock(isFirst);
        });

        return;
      }
    }
    _screenLock(isFirst);
  }

  ///
  /// Unable to paste text
  void _screenLock1(bool isFirst) {
    _pwd = PrefService.stringDefault(ca.screenLockPwd);
    if (_pwd.isEmpty) return;

    screenLock(
      context: context,
      title: Text(S.current.Please_input_password),
      correctString: _pwd,
      maxRetries: 2,
      retryDelay: const Duration(seconds: 5),
      delayBuilder: (context, delay) => Text(
        S.current.Cannot_be_entered_for_seconds(
            (delay.inMilliseconds / 1000).ceil()),
      ),
      keyPadConfig: const KeyPadConfig(clearOnLongPressed: true),
      canCancel: false,
      onUnlocked: () {
        _nav(isFirst);
        _lock();
      },
    );
  }

  ///
  void _screenLock(bool isFirst) {
    // get up-to-date pwd 
    _pwd = PrefService.stringDefault(ca.screenLockPwd);
    if (_pwd.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      // barrierColor: Colors.grey.withOpacity(0.99),
      barrierColor: themeData.dividerColor,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.zero)),
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) async {},
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(S.current.Please_input_password),
                  ..._pinPut(isFirst),
                  // ..._pinCodeField(isFirst),
                  // _verification(isFirst),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _pinPut(bool isFirst) {
    // final formKey = GlobalKey<FormState>();
    final editingController = TextEditingController();
    final focusNode = FocusNode();
    focusNode.requestFocus(); // default focus

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
    // String err = '';

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

    return <Widget>[
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
              // err = '';
              _nav(isFirst);
              _lock();
              return null;
            }

            return S.current.Password_is_incorrect;
          },
          // hapticFeedbackType: HapticFeedbackType.lightImpact,
          onCompleted: (v) {
            debugPrint('onCompleted: $v');
          },
          onChanged: (v) {
            debugPrint('onChanged: $v');
          },
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
      //
      ElevatedButton(
        onPressed: () {
          debugPrint('editingController.clear');
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
    ];
  }

//   String? _verify(String key, String nonce, String targetHash,bool isFirst)async{
// String? err;
// if(await Encryption.isHashEqual(key, nonce, targetHash)){
//   _nav(isFirst);
//   _lock();
// }else{
//   err = S.current.Password_is_incorrect;
// }

// return err;

//   }

  ///
  /// Clearing text doesn't work
  List<Widget> _pinCodeField(bool isFirst) {
    TextEditingController editingController = TextEditingController();

    StreamController<pin.ErrorAnimationType>? errorController =
        StreamController<pin.ErrorAnimationType>();

    // final FocusNode focusNode = FocusNode();

    String text = '';
    String err = '';

    return <Widget>[
      Container(
        width: 250,
        child: pin.PinCodeTextField(
          appContext: context,
          pastedTextStyle: TextStyle(
            // color: Colors.green.shade600,
            fontWeight: FontWeight.bold,
          ),
          length: PwdForm.screenLockPwdLen,
          obscureText: true,
          obscuringCharacter: '*',
          // obscuringWidget: const FlutterLogo(
          //   size: 24,
          // ),
          blinkWhenObscuring: true,
          autoFocus: true,
          // focusNode: focusNode,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          animationType: pin.AnimationType.fade,
          animationDuration: const Duration(milliseconds: 300),
          enableActiveFill: true,
          keyboardType: TextInputType.number,
          // cursorColor: cs.secondary,
          cursorColor: cs.onSurface,
          backgroundColor: Colors.transparent,
          pinTheme: pin.PinTheme(
            // shape: PinCodeFieldShape.box,
            shape: pin.PinCodeFieldShape.underline,
            // borderRadius: BorderRadius.circular(5),
            fieldHeight: 50,
            fieldWidth: 40,
            selectedColor: cs.primary,
            activeColor: cs.secondary,
            inactiveColor: cs.onSurface,
            selectedFillColor: Colors.transparent,
            inactiveFillColor: Colors.transparent,
            activeFillColor: Colors.transparent,
          ),
          controller: editingController,
          errorAnimationController: errorController,
          validator: (v) {
            debugPrint("validator: $v");

            if (v!.length < 3) {
              return "I'm from validator";
            } else {
              return null;
            }
          },
          boxShadows: const [
            BoxShadow(
              offset: Offset(0, 1),
              color: Colors.black12,
              blurRadius: 10,
            )
          ],
          onCompleted: (v) {
            debugPrint("Completed: $v");
            if (v == _pwd) {
              _nav(isFirst);
              _lock();
            } else {
              errorController.add(pin.ErrorAnimationType.shake);
              setState(() {
                err = 'Pin is incorrect';
              });

              // snackBar(err);
            }
          },
          // onTap: () {
          //   print("Pressed");
          // },
          onChanged: (value) {
            debugPrint('onChanged: $value');
            setState(() {
              text = value;
            });
          },
          beforeTextPaste: (text) {
            debugPrint("Allowing to paste $text");
            //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
            //but you can show anything you want here, like your pop up saying wrong paste format or etc
            return true;
          },
        ),
      ),
      //
      ElevatedButton(
        onPressed: () {
          debugPrint('editingController.clear');
          editingController.clear();
          setState(() {
            err = '';
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(MdiIcons.backspace),
            SizedBox(width: 8),
            Text('Clear All'),
          ],
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: cs.onSurface,
        ),
      ),
      //
      Text(err, style: TextStyle(color: cs.onError)),
    ];
  }

  ///
  /// Pasting text results in an error
  VerificationCode _verification(bool isFirst) {
    // final StreamController<bool> pastStream =
    //     StreamController<bool>.broadcast();
    String err = '---';

    return VerificationCode(
      // textStyle: Theme.of(context)
      //     .textTheme
      //     .bodyText2!
      //     .copyWith(color: Theme.of(context).primaryColor),
      keyboardType: TextInputType.number,
      length: 4,
      // If this is null it will use primaryColor: Colors.red from Theme
      underlineColor: cs.secondary,
      // If this is null it will default to the ambient
      // cursorColor: Colors.blue,
      cursorColor: cs.primary,
      // clearAll is NOT required, you can delete it
      // takes any widget, so you can implement your design
      clearAll: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(MdiIcons.backspace), // 图标
              SizedBox(width: 8), // 间距
              Text('Clear All'), // 文字

              if (err.isNotEmpty)
                Text(err, style: TextStyle(color: cs.onError)),
            ],
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: cs.onSurface,
          ),
        ),
      ),
      margin: const EdgeInsets.all(12),
      onCompleted: (String value) {
        // setState(() {
        //   _code = value;
        // });
        debugPrint('onCompleted: $value');
        if (value == _pwd) {
          _nav(isFirst);
          _lock();
        } else {
          setState(() {
            err = 'Pin is incorrect';
          });
        }
        debugPrint('onCompleted: $err');
      },
      onEditing: (bool isEditing) {
        debugPrint('onEditing: $isEditing');
        if (!isEditing) FocusScope.of(context).unfocus();
      },
      isSecure: true,
      digitsOnly: true,
      autofocus: true,
      fullBorder: true,
      // pasteStream: pastStream.stream,
    );
  }

  ///
  void _nav(bool isFirst) {
    isFirst
        ? NoteListPage.show(context, isFirst: true)
        : Navigator.pop(context);
  }

  // // snackBar Widget
  // snackBar(String? message) {
  //   return ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message!),
  //       duration: const Duration(seconds: 2),
  //     ),
  //   );
  // }
}

// 初进app，检查是否开启屏幕锁功能
// 是，跳转锁屏页，解锁成功后进入首页
// 否，直接进入首页
// 设置定时多少分钟后自动锁屏，0=无限制，5，30，60; 只有当前不是锁屏页才跳转锁屏
// 2233 0000
