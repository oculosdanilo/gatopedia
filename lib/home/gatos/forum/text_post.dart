import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:gatopedia/home/gatos/forum/forum.dart';
import 'package:gatopedia/main.dart';

class TextPost extends StatefulWidget {
  const TextPost({super.key});

  @override
  State<TextPost> createState() => _TextPostState();
}

class _TextPostState extends State<TextPost> {
  _postar(int postN) async {
    Navigator.pop(context);
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    await ref.update({
      "$postN": {
        "username": username,
        "content": txtPost.text,
        "likes": {
          "lenght": 0,
          "users": "",
        },
        "comentarios": [
          {"a": "a"},
          {"a": "a"}
        ]
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (poppou) async {
        if (txtPost.text != "") {
          final resposta = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              icon: const Icon(Icons.info_rounded),
              title: const Text(
                "Tem certeza que deseja descartar seu post?",
              ),
              content: const Text("Seu rascunho será deletado."),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Descartar"),
                ),
              ],
            ),
          );
          if (!context.mounted) return;
          if (resposta ?? false) Navigator.pop(context);
        } else {
          Navigator.pop(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Consumer<ScreenHeight>(
          builder: (context, res, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: FadeInImage(
                          fadeInDuration: const Duration(milliseconds: 100),
                          placeholder: const AssetImage("assets/user.webp"),
                          image: NetworkImage(
                            "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Flexible(
                      child: TextField(
                        controller: txtPost,
                        maxLength: 400,
                        decoration: InputDecoration(
                          hintText: "No que está pensando, $username?",
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
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          onPressed: () {
                            if (txtPost.text != "") {
                              _postar(
                                int.parse("${snapshotForum!.children.last.key ?? 0}") + 1,
                              );
                              Flushbar(
                                message: "Postado com sucesso!",
                                duration: const Duration(seconds: 3),
                                margin: const EdgeInsets.all(20),
                                borderRadius: BorderRadius.circular(50),
                              ).show(context);
                            }
                          },
                          icon: const Icon(Icons.send_rounded),
                          label: const Text("ENVIAR"),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: res.keyboardHeight,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
