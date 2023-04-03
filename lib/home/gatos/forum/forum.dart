// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'delete_post.dart';
import 'edit_post.dart';
import 'image_post.dart';
import '../../../main.dart';

bool postado = false;
String imgUrl = "";
File? file;
String imagemTipo = "";
String legenda = "";

class Forum extends StatefulWidget {
  const Forum({super.key});

  @override
  State<Forum> createState() => _ForumState();
}

enum MenuItems { itemUm, itemDois }

class _ForumState extends State<Forum> {
  bool enabled = true;
  final txtPost = TextEditingController();
  String pedaco1 = "";
  String pedaco2 = "";
  bool flag = true;
  bool liked = false;

  _firebasePegar() async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    snapshot = await ref.get();
    if (mounted) {
      setState(() {});
    }
    debugPrint("${snapshot?.value}");
  }

  _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    debugPrint("aiai");
    ref.onValue.listen((event) {
      _firebasePegar();
    });
  }

  _maisDe2Linhas(String text) {
    if (text.length > 30) {
      pedaco1 = text.substring(0, 30);
      pedaco2 = text.substring(30, text.length);
      return true;
    } else {
      pedaco1 = text;
      return false;
    }
  }

  _postarImagem(int post) async {
    await FirebaseStorage.instance.ref("posts/$post.png").putFile(file!);
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    await ref.update({
      "$post": {
        "username": username,
        "content": legenda,
        "likes": {
          "lenght": 0,
          "users": "",
        },
        "img": true,
      }
    });
    Flushbar(
      message: "Postado com sucesso!",
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(50),
    ).show(context);
  }

  _postar(int postN) async {
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
      }
    });
  }

  _like(int post) {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$post/likes");
    ref.update({
      "lenght": (snapshot?.value as List)[post]["likes"]["lenght"] + 1,
      "users": "${(snapshot?.value as List)[post]["likes"]["users"]}$username"
    });
    liked = true;
  }

  _unlike(int post) {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$post/likes");
    ref.update({
      "lenght": (snapshot?.value as List)[post]["likes"]["lenght"] - 1,
      "users": (snapshot?.value as List)[post]["likes"]["users"]
          .toString()
          .replaceAll(
            username,
            "",
          ),
    });
    liked = false;
  }

  @override
  void initState() {
    _atualizar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: Container(
        margin: const EdgeInsets.fromLTRB(30, 30, 30, 0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Image(
                  image: AssetImage("lib/assets/user.webp"),
                  width: 50,
                ),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: TextField(
                    onSubmitted: (value) {
                      if (txtPost.text != "") {
                        _postar(
                          int.parse("${snapshot?.children.last.key ?? 0}") + 1,
                        );
                        txtPost.text = "";
                        Flushbar(
                          message: "Postado com sucesso!",
                          duration: const Duration(seconds: 3),
                          margin: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(50),
                        ).show(context);
                      }
                    },
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
                        borderRadius: BorderRadius.circular(10),
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
                OpenContainer(
                  closedColor: Theme.of(context).colorScheme.surfaceVariant,
                  closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  openColor: Theme.of(context).colorScheme.background,
                  transitionDuration: const Duration(milliseconds: 400),
                  transitionType: ContainerTransitionType.fadeThrough,
                  openBuilder: (context, action) => ImagePost("image"),
                  openShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onClosed: (data) async {
                    debugPrint("$postado");
                    if (postado) {
                      Flushbar(
                        message: "Postando...",
                        duration: const Duration(seconds: 5),
                        margin: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(50),
                      ).show(context);
                      _postarImagem(
                          int.parse("${snapshot?.children.last.key ?? 0}") + 1);
                    }
                  },
                  closedBuilder: (context, action) {
                    return IconButton(
                      onPressed: () {
                        action.call();
                      },
                      icon: Icon(
                        Icons.image,
                        color: colors.primary,
                      ),
                      style: IconButton.styleFrom(
                        focusColor: colors.onSurfaceVariant.withOpacity(0.12),
                        highlightColor: colors.onSurface.withOpacity(0.12),
                        side: BorderSide(color: colors.primary),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  width: 5,
                ),
                OpenContainer(
                  closedColor: Theme.of(context).colorScheme.surfaceVariant,
                  closedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  openColor: Theme.of(context).colorScheme.background,
                  transitionDuration: const Duration(milliseconds: 400),
                  transitionType: ContainerTransitionType.fadeThrough,
                  onClosed: (data) {
                    debugPrint("$postado");
                    if (postado) {
                      Flushbar(
                        message: "Postando...",
                        duration: const Duration(seconds: 5),
                        margin: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(50),
                      ).show(context);
                      _postarImagem(
                          int.parse("${snapshot?.children.last.key ?? 0}") + 1);
                    }
                  },
                  openBuilder: (context, action) => ImagePost("gif"),
                  openShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  closedBuilder: (context, action) {
                    return IconButton(
                      onPressed: () {
                        action.call();
                      },
                      icon: Icon(
                        Icons.gif,
                        color: colors.primary,
                      ),
                      style: IconButton.styleFrom(
                        focusColor: colors.onSurfaceVariant.withOpacity(0.12),
                        highlightColor: colors.onSurface.withOpacity(0.12),
                        side: BorderSide(color: colors.primary),
                      ),
                    );
                  },
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (txtPost.text != "") {
                          _postar(
                            int.parse("${snapshot?.children.last.key ?? 0}") +
                                1,
                          );
                          txtPost.text = "";
                          Flushbar(
                            message: "Postado com sucesso!",
                            duration: const Duration(seconds: 3),
                            margin: const EdgeInsets.all(20),
                            borderRadius: BorderRadius.circular(50),
                          ).show(context);
                        }
                      },
                      icon: const Icon(Icons.send),
                      label: const Text("ENVIAR"),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return (snapshot?.value as List)[
                              int.parse(snapshot?.children.last.key ?? "0") -
                                  index] !=
                          null
                      ? Card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Image(
                                    image: AssetImage("lib/assets/user.webp"),
                                    width: 50,
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              "@${(snapshot?.value as List)[int.parse(snapshot?.children.last.key ?? "0") - index]["username"]}",
                                              style: const TextStyle(
                                                fontFamily: "Jost",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                              softWrap: true,
                                            ),
                                          ),
                                          username ==
                                                  (snapshot?.value as List)[
                                                      int.parse(snapshot
                                                                  ?.children
                                                                  .last
                                                                  .key ??
                                                              "0") -
                                                          index]["username"]
                                              ? Flexible(
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: PopupMenuButton<
                                                        MenuItems>(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      itemBuilder: (context) =>
                                                          [
                                                        PopupMenuItem(
                                                          onTap: () {
                                                            WidgetsBinding
                                                                .instance
                                                                .addPostFrameCallback(
                                                                    (_) {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        EditPost(
                                                                  int.parse(snapshot
                                                                              ?.children
                                                                              .last
                                                                              .key ??
                                                                          "0") -
                                                                      index,
                                                                ),
                                                              ).then((value) {
                                                                if (value) {
                                                                  Flushbar(
                                                                    message:
                                                                        "Editado com sucesso!",
                                                                    duration: const Duration(
                                                                        seconds:
                                                                            3),
                                                                    margin:
                                                                        const EdgeInsets.all(
                                                                            20),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            50),
                                                                  ).show(
                                                                      context);
                                                                }
                                                              });
                                                            });
                                                          },
                                                          child: const Text(
                                                              "Editar"),
                                                        ),
                                                        PopupMenuItem(
                                                          onTap: () {
                                                            WidgetsBinding
                                                                .instance
                                                                .addPostFrameCallback(
                                                                    (_) {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        DeletePost(
                                                                  int.parse(snapshot
                                                                              ?.children
                                                                              .last
                                                                              .key ??
                                                                          "0") -
                                                                      index,
                                                                ),
                                                              );
                                                            });
                                                          },
                                                          child: const Text(
                                                            "Deletar",
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : const Text(""),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        _maisDe2Linhas(
                                          (snapshot?.value as List)[int.parse(
                                                  snapshot?.children.last.key ??
                                                      "0") -
                                              index]["content"],
                                        )
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                flag = !flag;
                                              });
                                            },
                                            child: Text(
                                              _maisDe2Linhas(
                                                      (snapshot?.value as List)[
                                                          int.parse(snapshot
                                                                      ?.children
                                                                      .last
                                                                      .key ??
                                                                  "0") -
                                                              index]["content"])
                                                  ? flag
                                                      ? "mostrar mais"
                                                      : "mostrar menos"
                                                  : "",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      (snapshot?.value as List)[int.parse(
                                                      snapshot?.children.last
                                                              .key ??
                                                          "0") -
                                                  index]["img"] !=
                                              null
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 10, 10, 10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: FadeInImage(
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  fadeInDuration:
                                                      const Duration(
                                                          milliseconds: 300),
                                                  fadeOutDuration:
                                                      const Duration(
                                                          milliseconds: 300),
                                                  placeholder: const AssetImage(
                                                      'lib/assets/loading.gif'),
                                                  image: NetworkImage(
                                                      "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${(int.parse(snapshot?.children.last.key ?? "0") - index).toString()}.png?alt=media"),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton.icon(
                                          style: ButtonStyle(
                                            iconColor:
                                                MaterialStateProperty.all(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            ),
                                          ),
                                          onPressed: () {
                                            if (!(snapshot?.value as List)[
                                                    int.parse(snapshot?.children
                                                                .last.key ??
                                                            "0") -
                                                        index]["likes"]["users"]
                                                .toString()
                                                .contains(username)) {
                                              _like(int.parse(snapshot
                                                          ?.children.last.key ??
                                                      "0") -
                                                  index);
                                            } else {
                                              _unlike(int.parse(snapshot
                                                          ?.children.last.key ??
                                                      "0") -
                                                  index);
                                            }
                                            setState(() {
                                              liked = !liked;
                                            });
                                          },
                                          icon: Icon(
                                            (snapshot?.value as List)[int.parse(
                                                            snapshot?.children
                                                                    .last.key ??
                                                                "0") -
                                                        index]["likes"]["users"]
                                                    .contains(username)
                                                ? Icons.thumb_up_alt
                                                : Icons.thumb_up_alt_outlined,
                                            color: (snapshot?.value
                                                        as List)[int.parse(
                                                            snapshot?.children
                                                                    .last.key ??
                                                                "0") -
                                                        index]["likes"]["users"]
                                                    .contains(username)
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                          ),
                                          label: Text(
                                            "${(snapshot?.value as List)[int.parse(snapshot?.children.last.key ?? "0") - index]["likes"]["lenght"]}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Row();
                },
                itemCount: (int.parse("${snapshot?.children.last.key}") + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
