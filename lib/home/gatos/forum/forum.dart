// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gatopedia/home/gatos/public_profile.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/home/gatos/forum/comentarios.dart';
import 'package:gatopedia/home/gatos/forum/imagem.dart';
import 'package:gatopedia/home/gatos/forum/delete_post.dart';
import 'package:gatopedia/home/gatos/forum/edit_post.dart';
import 'package:gatopedia/home/gatos/forum/image_post.dart';
import 'package:gatopedia/main.dart';

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

class _ForumState extends State<Forum> with AutomaticKeepAliveClientMixin {
  bool enabled = true;
  final txtPost = TextEditingController();
  String pedaco1 = "";
  String pedaco2 = "";
  bool flag = true;

  _firebasePegar() async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    snapshot = await ref.get();
    if (mounted) {
      setState(() {});
    }
  }

  _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    ref.onValue.listen((event) {
      _firebasePegar();
    });
  }

  _maisDe2Linhas(String text) {
    if (text.length > 50) {
      pedaco1 = text.substring(0, 50);
      pedaco2 = text.substring(50, text.length);
      return true;
    } else {
      pedaco1 = text;
      return false;
    }
  }

  _postarImagem(int post) async {
    XFile? result = await FlutterImageCompress.compressAndGetFile(
      file!.absolute.path,
      "${(await getApplicationDocumentsDirectory()).path}aa.webp",
      quality: 80,
      format: CompressFormat.webp,
    );
    File finalFile = File(result!.path);
    await FirebaseStorage.instance.ref("posts/$post.webp").putFile(finalFile);
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
        "comentarios": [
          {"a": "a"},
          {"a": "a"}
        ]
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
        "comentarios": [
          {"a": "a"},
          {"a": "a"}
        ]
      }
    });
  }

  _like(int post) {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$post/likes");
    ref.update({
      "lenght": (snapshot?.value as List)[post]["likes"]["lenght"] + 1,
      "users": "${(snapshot?.value as List)[post]["likes"]["users"]}$username,"
    });
  }

  _unlike(int post) {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$post/likes");
    ref.update(
      {
        "lenght": (snapshot?.value as List)[post]["likes"]["lenght"] - 1,
        "users": (snapshot?.value as List)[post]["likes"]["users"]
            .toString()
            .replaceAll(
              "$username,",
              "",
            ),
      },
    );
  }

  _pegarImagens() async {
    await Firebase.initializeApp();
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users/");
    DataSnapshot userinfo = await ref.get();
    int i = 0;
    while (i < userinfo.children.length) {
      if (((userinfo.children).toList()[i].value as Map)["img"] != null) {
        setState(() {
          listaTemImagem.add(
            "${(userinfo.children.map((i) => i)).toList()[i].key}",
          );
        });
      } else {
        setState(() {
          listaTemImagem.remove(
            "${(userinfo.children.map((i) => i)).toList()[i].key}",
          );
        });
      }
      i++;
    }
  }

  @override
  void initState() {
    _pegarImagens();
    _atualizar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 25, 10, 0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                          SlideRightAgainRoute(PublicProfile(username)));
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset("lib/assets/user.webp"),
                        listaTemImagem.contains(username)
                            ? FadeInImage(
                                fadeInDuration:
                                    const Duration(milliseconds: 100),
                                placeholder:
                                    const AssetImage("lib/assets/user.webp"),
                                image: NetworkImage(
                                  "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media",
                                ),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                "lib/assets/user.webp",
                                fit: BoxFit.cover,
                              ),
                      ],
                    ),
                  ),
                ),
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
                    _postarImagem((snapshot?.exists ?? false)
                        ? (int.parse("${snapshot?.children.last.key ?? 0}") + 1)
                        : 0);
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
                          (snapshot?.exists ?? false)
                              ? int.parse(
                                      "${snapshot?.children.last.key ?? 0}") +
                                  1
                              : 0,
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
                    label: const Text("POSTAR"),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          (snapshot?.exists ?? false)
              ? (Expanded(
                  child: StretchingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return (snapshot?.value as List)[int.parse(
                                        snapshot?.children.last.key ?? "0") -
                                    index] !=
                                null
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(
                                    0,
                                    0,
                                    0,
                                    (snapshot?.value as List).length - 1 ==
                                            index
                                        ? 10
                                        : 0),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        10, 20, 10, 20),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 5, 0, 0),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        SlideRightAgainRoute(
                                                          PublicProfile(
                                                            (snapshot?.value
                                                                as List)[int.parse(snapshot
                                                                        ?.children
                                                                        .last
                                                                        .key ??
                                                                    "0") -
                                                                index]["username"],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    child: Stack(
                                                      fit: StackFit.expand,
                                                      children: [
                                                        Image.asset(
                                                            "lib/assets/user.webp"),
                                                        listaTemImagem.contains((snapshot
                                                                    ?.value
                                                                as List)[int.parse(snapshot
                                                                        ?.children
                                                                        .last
                                                                        .key ??
                                                                    "0") -
                                                                index]["username"])
                                                            ? FadeInImage(
                                                                fadeInDuration:
                                                                    const Duration(
                                                                        milliseconds:
                                                                            100),
                                                                placeholder:
                                                                    const AssetImage(
                                                                        "lib/assets/user.webp"),
                                                                image:
                                                                    NetworkImage(
                                                                  "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F${(snapshot?.value as List)[int.parse(snapshot?.children.last.key ?? "0") - index]["username"]}.webp?alt=media",
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                              )
                                                            : Image.asset(
                                                                "lib/assets/user.webp",
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
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
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 4,
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              SlideRightAgainRoute(
                                                                PublicProfile(
                                                                  (snapshot
                                                                          ?.value
                                                                      as List)[int.parse(snapshot
                                                                              ?.children
                                                                              .last
                                                                              .key ??
                                                                          "0") -
                                                                      index]["username"],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                            "@${(snapshot?.value as List)[int.parse(snapshot?.children.last.key ?? "0") - index]["username"]}",
                                                            style:
                                                                const TextStyle(
                                                              fontFamily:
                                                                  "Jost",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20,
                                                            ),
                                                            softWrap: true,
                                                          ),
                                                        ),
                                                      ),
                                                      username ==
                                                              (snapshot?.value
                                                                  as List)[int.parse(snapshot
                                                                          ?.children
                                                                          .last
                                                                          .key ??
                                                                      "0") -
                                                                  index]["username"]
                                                          ? Flexible(
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .topRight,
                                                                child: PopupMenuButton<
                                                                    MenuItems>(
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            20),
                                                                  ),
                                                                  itemBuilder:
                                                                      (context) =>
                                                                          [
                                                                    PopupMenuItem(
                                                                      onTap:
                                                                          () {
                                                                        WidgetsBinding
                                                                            .instance
                                                                            .addPostFrameCallback((_) {
                                                                          showDialog(
                                                                            barrierDismissible:
                                                                                false,
                                                                            context:
                                                                                context,
                                                                            builder: (context) =>
                                                                                EditPost(
                                                                              (int.parse(snapshot?.children.last.key ?? "0") - index),
                                                                              (snapshot?.value as List)[int.parse(snapshot?.children.last.key ?? "0") - index]["img"] != null,
                                                                            ),
                                                                          ).then(
                                                                              (value) {
                                                                            if (value) {
                                                                              Flushbar(
                                                                                message: "Editado com sucesso!",
                                                                                duration: const Duration(seconds: 3),
                                                                                margin: const EdgeInsets.all(20),
                                                                                borderRadius: BorderRadius.circular(50),
                                                                              ).show(context);
                                                                            }
                                                                          });
                                                                        });
                                                                      },
                                                                      child: const Text(
                                                                          "Editar"),
                                                                    ),
                                                                    PopupMenuItem(
                                                                      onTap:
                                                                          () {
                                                                        WidgetsBinding
                                                                            .instance
                                                                            .addPostFrameCallback((_) {
                                                                          showDialog(
                                                                            context:
                                                                                context,
                                                                            builder: (context) =>
                                                                                DeletePost(
                                                                              int.parse(snapshot?.children.last.key ?? "0") - index,
                                                                            ),
                                                                          );
                                                                        });
                                                                      },
                                                                      child:
                                                                          const Text(
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
                                                      (snapshot?.value as List)[
                                                          int.parse(snapshot
                                                                      ?.children
                                                                      .last
                                                                      .key ??
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
                                                        child: _maisDe2Linhas((snapshot
                                                                    ?.value
                                                                as List)[int.parse(snapshot
                                                                        ?.children
                                                                        .last
                                                                        .key ??
                                                                    "0") -
                                                                index]["content"])
                                                            ? Text(
                                                                flag
                                                                    ? "mostrar mais"
                                                                    : "mostrar menos",
                                                                style:
                                                                    const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              )
                                                            : const SizedBox(
                                                                height: 5,
                                                              ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  (snapshot?.value
                                                              as List)[int.parse(
                                                                  snapshot
                                                                          ?.children
                                                                          .last
                                                                          .key ??
                                                                      "0") -
                                                              index]["img"] !=
                                                          null
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                            0,
                                                            10,
                                                            10,
                                                            10,
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child:
                                                                OpenContainer(
                                                              onClosed:
                                                                  (data) {},
                                                              closedColor: Colors
                                                                  .transparent,
                                                              openColor:
                                                                  Colors.black,
                                                              openBuilder: (context,
                                                                      action) =>
                                                                  Imagem(
                                                                      "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${(int.parse(snapshot?.children.last.key ?? "0") - index).toString()}.webp?alt=media"),
                                                              closedBuilder: (context,
                                                                      action) =>
                                                                  AspectRatio(
                                                                aspectRatio: 1,
                                                                child:
                                                                    FadeInImage(
                                                                  key:
                                                                      UniqueKey(),
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  width: double
                                                                      .infinity,
                                                                  fadeInDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              150),
                                                                  fadeOutDuration:
                                                                      const Duration(
                                                                          milliseconds:
                                                                              150),
                                                                  placeholder:
                                                                      const AssetImage(
                                                                    'lib/assets/loading.gif',
                                                                  ),
                                                                  image:
                                                                      NetworkImage(
                                                                    "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${(int.parse(snapshot?.children.last.key ?? "0") - index).toString()}.webp?alt=media",
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox(),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            OpenContainer(
                                              closedColor: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                              closedShape:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                              ),
                                              transitionDuration:
                                                  const Duration(
                                                milliseconds: 500,
                                              ),
                                              onClosed: (value) {},
                                              openColor: Theme.of(context)
                                                  .colorScheme
                                                  .background,
                                              closedBuilder:
                                                  (context, action) => Align(
                                                alignment: Alignment.centerLeft,
                                                child: TextButton(
                                                  onPressed: () async {
                                                    action.call();
                                                  },
                                                  child: Text(
                                                    "Comentários (${(snapshot?.value as List)[int.parse(snapshot?.children.last.key ?? "0") - index]["comentarios"] != null ? (((snapshot?.value as List)[int.parse(snapshot?.children.last.key ?? "0") - index]["comentarios"] as List).whereType<Map>().toList().length - 2) : 0})",
                                                  ),
                                                ),
                                              ),
                                              openBuilder: (context, action) =>
                                                  Comentarios(int.parse(snapshot
                                                              ?.children
                                                              .last
                                                              .key ??
                                                          "0") -
                                                      index),
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
                                                  backgroundColor:
                                                      MaterialStatePropertyAll(
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .background,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  if (!(snapshot?.value
                                                          as List)[int.parse(
                                                              snapshot
                                                                      ?.children
                                                                      .last
                                                                      .key ??
                                                                  "0") -
                                                          index]["likes"]["users"]
                                                      .toString()
                                                      .split(",")
                                                      .contains(username)) {
                                                    _like(int.parse(snapshot
                                                                ?.children
                                                                .last
                                                                .key ??
                                                            "0") -
                                                        index);
                                                  } else {
                                                    _unlike(int.parse(snapshot
                                                                ?.children
                                                                .last
                                                                .key ??
                                                            "0") -
                                                        index);
                                                  }
                                                },
                                                icon: Icon(
                                                  (snapshot?.value
                                                              as List)[int.parse(
                                                                  snapshot
                                                                          ?.children
                                                                          .last
                                                                          .key ??
                                                                      "0") -
                                                              index]["likes"]["users"]
                                                          .toString()
                                                          .split(",")
                                                          .contains(username)
                                                      ? Icons.thumb_up_alt
                                                      : Icons.thumb_up_alt_outlined,
                                                  color: (snapshot?.value
                                                                      as List)[
                                                                  int.parse(
                                                                        snapshot?.children.last.key ??
                                                                            "0",
                                                                      ) -
                                                                      index]
                                                              ["likes"]["users"]
                                                          .toString()
                                                          .split(",")
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
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : const Row();
                      },
                      itemCount: (snapshot?.exists ?? false)
                          ? (int.parse("${snapshot?.children.last.key}") + 1)
                          : 0,
                    ),
                  ),
                ))
              : const Text("Nenhum comentário!"),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
