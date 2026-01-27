import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/screens/home/gatos/forum/forum.dart';

class DeletePost extends StatefulWidget {
  final int post;

  const DeletePost(this.post, {super.key});

  @override
  State<DeletePost> createState() => _DeletePostState();
}

class _DeletePostState extends State<DeletePost> {
  Future<void> _deletar(int postN) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$postN");
    await ref.remove();
    if (!mounted) return;
    Flushbar(
      message: AppLocalizations.of(context).forum_delete_flush,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(50),
    ).show(context);
    if (Forum.snapshotForum.value!.child("$postN/img").value != null) {
      Reference refI = FirebaseStorage.instance.ref("posts/$postN.webp");
      Uint8List? lista = await refI.getData();
      if (lista?.isNotEmpty ?? false) {
        await refI.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(Icons.delete_rounded, color: Theme.of(context).colorScheme.error),
      title: Text(
        AppLocalizations.of(context).forum_delete_title,
        textAlign: TextAlign.center,
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text(AppLocalizations.of(context).forum_delete_desc)],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        ElevatedButton(
          onPressed: () {
            _deletar(widget.post);
            Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}
