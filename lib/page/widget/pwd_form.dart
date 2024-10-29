import 'package:flutter/material.dart';
import 'package:password_strength_checker/password_strength_checker.dart';

import '/generated/l10n.dart';
import '/main.dart';

///
Future<String> screenLockPwdDialog(BuildContext context) async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.current.Please_set_the_screen_lock_passcode),
          titleTextStyle: TextStyle(fontSize: 22, color: cs.onSurface),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300),
            child: PwdForm.screenLockPwd(),
          ),
        ),
      ) ??
      '';
}

///
Future<String> encryptionPwdDialog(BuildContext context) async {
  return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(S.current.Please_set_the_encryption_password),
          titleTextStyle: TextStyle(fontSize: 22, color: cs.onSurface),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 300),
            child: PwdForm.encryptionPwd(),
          ),
        ),
      ) ??
      '';
}

///
class PwdForm extends StatefulWidget {
  PwdForm.screenLockPwd({
    Key? super.key,
    String? errorText,
    String? helpText,
    String valueExp = '^\\d{${PwdForm.screenLockPwdLen}}\$',
    int maxLen = PwdForm.screenLockPwdLen,
  })  : _errorText = errorText ?? S.current.Please_enter_digits(maxLen),
        _helpText = helpText ?? S.current.Please_enter_digits(maxLen),
        _valueRegExp = RegExp(valueExp),
        _maxLength = maxLen;

  PwdForm.encryptionPwd({
    Key? super.key,
    String? errorText,
    String? helpText,
    String valueExp =
        '^\\d{${PwdForm.encryptionPwdMinLen},${PwdForm.encryptionPwdMaxLen}}\$',
    int minLen = PwdForm.encryptionPwdMinLen,
    int maxLen = PwdForm.encryptionPwdMaxLen,
  })  : _errorText =
            errorText ?? S.current.Please_enter_characters(minLen, maxLen),
        _helpText =
            helpText ?? S.current.Please_enter_characters(minLen, maxLen),
        _valueRegExp = RegExp(valueExp),
        _maxLength = maxLen;

  static const int screenLockPwdLen = 5;

  static const int encryptionPwdMinLen = 6;
  static const int encryptionPwdMaxLen = 64;

  final String _errorText;
  final String _helpText;
  final RegExp _valueRegExp;
  final int _maxLength;

  ///
  @override
  State<PwdForm> createState() => _PwdFormState();
}

class _PwdFormState extends State<PwdForm> {
  final _formKey = GlobalKey<FormState>();

  final _editingController = TextEditingController();

  bool _isObscure = true;

  String? _errorText;

  String _text = '';

  ///
  @override
  void dispose() {
    _editingController.dispose();

    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    //
    IconButton visIcon = IconButton(
      icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
      onPressed: () {
        setState(() {
          _isObscure = !_isObscure;
        });
      },
    );

    //
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        // autovalidateMode: AutovalidateMode.always,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PasswordStrengthFormChecker(
              minimumStrengthRequired: PasswordStrength.alreadyExposed,
              // minimumStrengthRequired: PasswordStrength.strong,
              // topInstructions: Text('PWD'),
              textFormFieldConfiguration: TextFormFieldConfiguration(
                controller: _editingController,
                obscureText: _isObscure,
                maxLength: widget._maxLength,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: S.current.Password,
                  border: const OutlineInputBorder(),
                  suffixIcon: visIcon,
                  errorText: _errorText,
                  helperText: widget._helpText,
                ),
                onSaved: (String? v) {
                  debugPrint('onSaved $v');
                  if (v == null) return;
                  RegExpMatch? match = widget._valueRegExp.firstMatch(v);
                  if (match == null) {
                    setState(() {
                      _errorText = widget._errorText;
                    });
                  } else {
                    _text = v;
                    debugPrint('onSaved $v >>> ok');
                  }
                },
              ),
              needConfirmation: true,
              confirmationTextFormFieldConfiguration:
                  TextFormFieldConfiguration(
                obscureText: _isObscure,
                maxLength: widget._maxLength,
                decoration: InputDecoration(
                  labelText: S.current.Confirm_Password,
                  border: OutlineInputBorder(),
                  suffixIcon: visIcon,
                  errorStyle: TextStyle(height: 0),
                ),
                onFieldSubmitted: (String? v) {
                  // debugPrint('onFieldSubmitted $v');
                  _submit();
                },
              ),
              hideErrorMessage: true,
              emptyTextErrorMessage: S.current.Password_cannot_be_empty,
              confirmationErrorMessage: S.current.Passwords_do_not_match,
              // hide passwordStrengthChecker
              passwordStrengthCheckerConfiguration:
                  const PasswordStrengthCheckerConfiguration(
                height: 0,
                hasBorder: false,
                showStatusWidget: false,
              ),
              // showGenerator: true,
              // onPasswordGenerated: (password, notifier) {
              //   debugPrint('$password - length: ${password.length}');
              //   // Don't forget to update the notifier!
              //   notifier.value = PasswordStrength.calculate(text: password);
              // },
              onChanged: (String v, ValueNotifier<PasswordStrength?> notifier) {
                debugPrint('onChanged $v');
                // Don't forget to update the notifier!
                notifier.value = PasswordStrength.calculate(text: v);
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.maxFinite,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.onSurface.withOpacity(0.5),
                  foregroundColor: cs.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop('');
                },
                child: Text(S.current.Cancel),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.maxFinite,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: cs.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _submit();
                },
                child: Text(S.current.Confirm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // _formKey.
      // TextFormField();
      debugPrint('Submit value: ${_editingController.text}');
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Processing Data')),
      // );
      if (_text.isNotEmpty) Navigator.of(context).pop(_text);
    }
  }
}
