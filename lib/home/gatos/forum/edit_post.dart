// ignore_for_file: must_be_immutable

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'package:gatopedia/main.dart';

class EditPost extends StatefulWidget {
  dynamic post;

  EditPost(this.post, {super.key});

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final txtEdit = TextEditingController();

  _editar(post) {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$post");
    ref.update({
      "content": txtEdit.text,
    });
  }

  @override
  void initState() {
    txtEdit.text = (snapshot?.value as Map)[widget.post.toString()]["content"];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            false,
          ),
          child: const Text(
            "CANCELAR",
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if ((snapshot?.value as Map)[widget.post.toString()]["content"] !=
                txtEdit.text) {
              _editar(widget.post);
              Navigator.pop(
                context,
                true,
              );
            }
          },
          child: const Text(
            "OK",
          ),
        ),
      ],
      title: const Text(
        "Editar post...",
        textAlign: TextAlign.center,
      ),
      icon: const Icon(Icons.edit_rounded),
      content: SizedBox(
        height: 160,
        child: Column(
          children: [
            TextField(
              maxLines: 4,
              maxLength: 400,
              controller: txtEdit,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
