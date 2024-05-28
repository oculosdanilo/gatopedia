import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

loginGoogle() async {
  try {
    final conta = await GoogleSignIn().signIn();

    debugPrint(conta?.id);
  } catch (e) {
    debugPrint(e.toString());
  }
}
