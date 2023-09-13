import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gatopedia/main.dart';

class DeletePost extends StatefulWidget {
  final int post;

  const DeletePost(this.post, {super.key});

  @override
  State<DeletePost> createState() => _DeletePostState();
}

class _DeletePostState extends State<DeletePost> {
  _deletar(int postN) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$postN");
    debugPrint("post/$postN");
    if ((snapshot?.value as List)[postN]["img"] != null) {
      Reference refI = FirebaseStorage.instance.ref("posts/$postN.webp");
      Uint8List? lista = await refI.getData();
      if (lista?.isNotEmpty ?? false) {
        refI.delete();
      }
    }
    ref.remove();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.delete_rounded,
      ),
      title: const Text(
        "Tem certeza que deseja deletar esse post?",
        textAlign: TextAlign.center,
      ),
      content: const Text(
        "Ele sumirá para sempre! (muito tempo)",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "CANCELAR",
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _deletar(widget.post);
            Navigator.pop(context);
            Flushbar(
              message: "Excluído com sucesso!",
              duration: const Duration(seconds: 3),
              margin: const EdgeInsets.all(20),
              borderRadius: BorderRadius.circular(50),
            ).show(
              context,
            );
          },
          child: const Text(
            "OK",
          ),
        ),
      ],
    );
  }
}
