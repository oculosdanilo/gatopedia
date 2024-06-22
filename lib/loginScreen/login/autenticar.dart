import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:gatopedia/main.dart';

Future<dynamic> entrar(String usernameDigitado, String senhaDigitada) async {
  final refLocal = FirebaseDatabase.instance.ref("users/${usernameDigitado.toLowerCase()}/");
  final snapshotLocal = await refLocal.get();
  if (snapshotLocal.exists) {
    String senhaDB = String.fromCharCodes(base64.decode(snapshotLocal.child("senha").value.toString()));
    if (senhaDB == senhaDigitada) {
      username = usernameDigitado;
      return true;
    } else {
      return "Senha incorreta :/";
    }
  } else {
    return "Usuário não existe :/";
  }
}

Future<dynamic> cadastrar(String usernameDigitado, String senhaDigitada) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref("users/${usernameDigitado.toLowerCase()}");
  final snapshot = await ref.get();
  if (!snapshot.exists) {
    ref.set({
      "senha": base64Encode(utf8.encode(senhaDigitada)),
      "bio": "(vazio)",
    });
    return true;
  } else {
    return "Usuário já existe :/";
  }
}
