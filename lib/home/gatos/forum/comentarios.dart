// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/home/config/config.dart';
import 'package:gatopedia/home/gatos/public_profile.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/main.dart';

class Comentarios extends StatefulWidget {
  final DataSnapshot post;

  const Comentarios(this.post, {super.key});

  @override
  State<Comentarios> createState() => _ComentariosState();
}

class _ComentariosState extends State<Comentarios> {
  String pedaco1 = "";
  String pedaco2 = "";
  bool flag = true;
  final txtComment = TextEditingController();
  late StreamSubscription<DatabaseEvent> _sub;

  late DataSnapshot postAtual = widget.post;

  _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    _sub = ref.onValue.listen((event) {
      if (mounted) {
        setState(() {
          snapshotForum = event.snapshot;
          postAtual = event.snapshot.child("${postAtual.key}");
        });
      }
    });
  }

  _postarC() async {
    DatabaseReference ref = postAtual.child("comentarios").ref;
    await ref.update({
      "${postAtual.child("comentarios").value != null ? postAtual.child("comentarios").children.length : 1}": {
        "username": username,
        "content": txtComment.text,
      },
    });
  }

  _deletarC(comment) {
    DatabaseReference ref = postAtual.child("comentarios/$comment").ref;
    ref.remove();
  }

  _maisDe2Linhas(String text) {
    if (text.length > 65) {
      pedaco1 = text.substring(0, 65);
      pedaco2 = text.substring(65, text.length);
      return true;
    } else {
      pedaco1 = text;
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _atualizar();
  }

  @override
  void dispose() {
    super.dispose();
    _sub.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        FocusManager.instance.primaryFocus?.unfocus();
      }),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            SlideRightAgainRoute(
                              PublicProfile(postAtual.child("username").value as String),
                            ),
                          );
                        },
                        child: Image(
                          image: NetworkImage(
                              "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F${postAtual.child("username").value}.webp?alt=media"),
                          width: 30,
                          errorBuilder: (c, obj, stacktrace) {
                            return Image.asset("assets/user.webp", width: 30);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                SlideRightAgainRoute(
                                  PublicProfile(postAtual.child("username").value as String),
                                ),
                              );
                            },
                            child: Text(
                              "@${postAtual.child("username").value}",
                              style: const TextStyle(
                                fontFamily: "Jost",
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            _maisDe2Linhas(postAtual.child("content").value as String)
                                ? flag
                                    ? "$pedaco1..."
                                    : pedaco1 + pedaco2
                                : pedaco1,
                            style: const TextStyle(
                              fontFamily: "Jost",
                              fontSize: 15,
                            ),
                            softWrap: true,
                            maxLines: 50,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  flag = !flag;
                                });
                              },
                              child: Text(
                                _maisDe2Linhas(postAtual.child("content").value as String)
                                    ? flag
                                        ? "mostrar mais"
                                        : "mostrar menos"
                                    : "",
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              username != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            flex: 7,
                            child: TextField(
                              controller: txtComment,
                              decoration: const InputDecoration(
                                hintText: "Comentar...",
                                prefix: SizedBox(width: 10),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            flex: 2,
                            child: IconButton.filled(
                              icon: const Icon(Icons.send_rounded),
                              iconSize: 25,
                              padding: const EdgeInsets.all(15),
                              onPressed: () async {
                                _postarC();
                                txtComment.text = "";
                                Flushbar(
                                  message: "Postado com sucesso!",
                                  duration: const Duration(seconds: 3),
                                  margin: const EdgeInsets.all(20),
                                  borderRadius: BorderRadius.circular(50),
                                ).show(context);
                              },
                            ),
                          )
                        ],
                      ),
                    )
                  : const SizedBox(),
              postAtual.child("comentarios").children.length > 2
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: postAtual.child("comentarios").children.length,
                        itemBuilder: (c, i) => postAtual
                                    .child("comentarios/${postAtual.child("comentarios").children.length - i}/username")
                                    .value !=
                                null
                            ? comentario(context, postAtual.child("comentarios").children.length - i)
                            : const SizedBox(),
                        /*children: postAtual
                            .child("comentarios")
                            .children
                            .map((e) => e.child("username").value == null ? Text("data") : const SizedBox())
                            .toList(),*/
                      ),
                    )
                  : const SizedBox(
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Nenhum comentário (ainda...)",
                            style: TextStyle(fontFamily: "Jost"),
                          )
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Card comentario(BuildContext context, int index) {
    return Card(
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
      color: username == null && dark
          ? Theme.of(context).colorScheme.surfaceTint.withOpacity(0.25)
          : Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  SlideRightAgainRoute(PublicProfile(postAtual.child("comentarios/$index/username").value as String)),
                ),
                child: Image(
                  image: NetworkImage(
                      "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F${postAtual.child("comentarios/$index/username").value}.webp?alt=media"),
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (c, obj, stacktrace) {
                    return Image.asset("assets/user.webp", width: 50);
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideRightAgainRoute(
                          PublicProfile(
                            postAtual.child("comentarios/$index/username").value as String,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "@${postAtual.child("comentarios/$index/username").value}",
                      style: const TextStyle(fontFamily: "Jost", fontWeight: FontWeight.bold, fontSize: 15),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${postAtual.child("comentarios/$index/content").value}",
                    style: const TextStyle(fontFamily: "Jost", fontSize: 15),
                    softWrap: true,
                    maxLines: 50,
                  )
                ],
              ),
            ),
            "${postAtual.child("comentarios/$index/username").value}" == username
                ? Ink(
                    decoration: ShapeDecoration(
                      color: blueScheme.errorContainer,
                      shape: const CircleBorder(),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      color: Colors.white,
                      onPressed: () {
                        showCupertinoDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                            icon: const Icon(Icons.delete_rounded),
                            title: const Text(
                              "Tem certeza que deseja deletar esse comentário?",
                              textAlign: TextAlign.center,
                            ),
                            content: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text("Ele sumirá para sempre! (muito tempo)")],
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
                                  _deletarC(index);
                                  Navigator.pop(context);
                                  Flushbar(
                                    message: "Excluído com sucesso!",
                                    duration: const Duration(seconds: 3),
                                    margin: const EdgeInsets.all(20),
                                    borderRadius: BorderRadius.circular(50),
                                  ).show(context);
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
