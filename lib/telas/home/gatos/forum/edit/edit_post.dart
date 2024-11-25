import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/main.dart';

class EditPost extends StatefulWidget {
  final String post;

  const EditPost(this.post, {super.key});

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final txtEdit = TextEditingController();

  _editar(String post) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("posts/$post");
    ref.update(
      {"content": txtEdit.text},
    );
  }

  @override
  void initState() {
    txtEdit.text = snapshotForum!.child("${widget.post}/content").value as String;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCELAR")),
        ElevatedButton(
          onPressed: () async {
            if (snapshotForum!.child("${widget.post}/content").value != txtEdit.text) {
              _editar(widget.post);
              Navigator.pop(
                context,
                true,
              );
            }
          },
          child: const Text("OK"),
        ),
      ],
      title: const Text("Editar post...", textAlign: TextAlign.center),
      icon: const Icon(Icons.edit_rounded),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.70,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLines: 4,
                maxLength: 400,
                controller: txtEdit,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
