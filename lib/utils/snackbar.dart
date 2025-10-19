import 'package:another_flushbar/flushbar.dart';
import 'package:cleaner_app/main.dart';
import 'package:flutter/material.dart';

class MySnackbar {
  static void show({
    String? title,
    required String? message,
  }) {
    Flushbar(
      barBlur: 1,
      // backgroundColor: MyColors.scaffoldBackground,
      borderRadius: BorderRadius.circular(20),
      title: title,
      padding: const EdgeInsets.all(20),
      message: message ?? 'Bildirim',
      margin: const EdgeInsets.all(8),
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(navigatorKey.currentState!.context);
  }
}
