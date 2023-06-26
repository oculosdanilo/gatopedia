import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

Future<(bool, String?)> autenticar(
  String usernameDigitado,
  String senhaDigitada,
) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref(
    "users/${usernameDigitado.toLowerCase()}",
  );
  final snapshot = await ref.get();
  if (snapshot.exists) {
    final senha = String.fromCharCodes(
      base64Decode(snapshot.child("senha").value.toString()),
    );
    if (senhaDigitada == senha) {
      return (true, null);
    } else {
      return (false, "Senha incorreta: usuário já existe!");
    }
  } else {
    await ref.update({
      "senha": base64Encode(utf8.encode(senhaDigitada)),
      "bio": "(vazio)",
    });
    return (
      false,
      "Cadastrado com sucesso! Entre as credenciais novamente para entrar"
    );
  }
}
