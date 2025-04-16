import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';

Future<dynamic> entrar(BuildContext c, String usernameDigitado, String senhaDigitada) async {
  final refLocal = FirebaseDatabase.instance.ref("users/${usernameDigitado.toLowerCase()}/");
  final snapshotLocal = await refLocal.get();
  if (!c.mounted) return;
  if (snapshotLocal.exists) {
    String senhaDB = String.fromCharCodes(base64.decode(snapshotLocal.child("senha").value.toString()));
    if (senhaDB == senhaDigitada) {
      username = usernameDigitado;
      return true;
    } else {
      return AppLocalizations.of(c).login_errPassword;
    }
  } else {
    return AppLocalizations.of(c).login_errUsername;
  }
}

Future<void> cadastrar(String username, String senha, String bio, {File? imagem}) async {
  final refUsers = FirebaseDatabase.instance.ref("users");
  final refUserStorage = FirebaseStorage.instance.ref("users/${username.toLowerCase()}.webp");

  if (imagem != null) {
    XFile? result = await FlutterImageCompress.compressAndGetFile(
      imagem.absolute.path,
      "${(await getTemporaryDirectory()).path}aa.webp",
      quality: 80,
      format: CompressFormat.webp,
    );
    await refUserStorage.putFile(File(result!.path));
  }
  await refUsers.update({
    username.toLowerCase(): {
      "bio": bio != "" ? bio : "(vazio)",
      "senha": base64.encode(utf8.encode(senha)),
      "img": imagem != null ? true : null,
    },
  });
}

Future<GoogleSignInAccount?> loginGoogle() async {
  try {
    final conta = await GoogleSignIn().signIn();

    return conta;
  } catch (e) {
    return null;
  }
}

Future<void> cadastrarGoogle(
  String username,
  String bio,
  GoogleSignInAccount google, {
  File? imagem,
}) async {
  final refUsers = FirebaseDatabase.instance.ref("users");
  final refUserStorage = FirebaseStorage.instance.ref("users/${username.toLowerCase()}.webp");
  final pic = google.photoUrl;

  if (imagem != null) {
    XFile? result = await FlutterImageCompress.compressAndGetFile(
      imagem.absolute.path,
      "${(await getTemporaryDirectory()).path}aa.webp",
      quality: 80,
      format: CompressFormat.webp,
    );
    await refUserStorage.putFile(File(result!.path));
  }
  await refUsers.update({
    username.toLowerCase(): {
      "bio": bio != "" ? bio : "(vazio)",
      "google": google.id,
      "img": imagem == null ? pic?.replaceAll("=s96", "=s1080") : true,
    },
  });
}
