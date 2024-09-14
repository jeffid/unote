import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

///
Logger logger = Logger();
Logger lo = logger;

///
DateTime now() => DateTime.now();

///
void dp(String? msg, {int? wrapWidth}) {
  debugPrint(msg, wrapWidth: wrapWidth);
}

/// snackBar Widget
void snackBar(BuildContext context, String? message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message ?? 'nil'),
      duration: const Duration(seconds: 2),
    ),
  );
}
