import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gatopedia/home/gatos/forum/image_post.dart';
import 'package:gatopedia/home/gatos/forum/imagem.dart';
import 'package:gatopedia/home/gatos/forum/text_post.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gatopedia/home/gatos/public_profile.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/home/gatos/forum/comentarios.dart';
import 'package:gatopedia/home/gatos/forum/delete_post.dart';
import 'package:gatopedia/home/gatos/forum/edit_post.dart';
import 'package:gatopedia/main.dart';

bool postado = false;
String imgUrl = "";
File? file;
String imagemTipo = "";
String legenda = "";
final txtPost = TextEditingController();
final fagKey = GlobalKey<ExpandableFabState>();

class Forum extends StatefulWidget {
  const Forum({super.key});

  @override
  State<Forum> createState() => _ForumState();
}

enum MenuItems { editar, deletar }

class _ForumState extends State<Forum> {
  bool enabled = true;
  String pedaco1 = "";
  String pedaco2 = "";
  bool flag = true;
  late StreamSubscription<DatabaseEvent> _sub;

  _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    _sub = ref.onValue.listen((event) {
      setState(() {
        snapshot = event.snapshot;
      });
    });
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

  _postarImagem(int post, String filetype) async {
    if (filetype == "img") {
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
      if (!mounted) return;
      Flushbar(
        message: "Postado com sucesso!",
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(50),
      ).show(context);
    } else {
      File finalFile = file!;
      await FirebaseStorage.instance.ref("posts/$post.webp").putFile(finalFile);
      FirebaseDatabase database = FirebaseDatabase.instance;
      DatabaseReference ref = database.ref("posts");
      await ref.update(
        {
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
        },
      );
      if (!mounted) return;
      Flushbar(
        message: "Postado com sucesso!",
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(50),
      ).show(context);
    }
  }

  _like(int post) {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$post/likes");
    ref.update({
      "lenght":
          int.parse(snapshot!.child("$post/likes/lenght").value.toString()) + 1,
      "users": "${snapshot!.child("$post/likes/users").value}$username,"
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
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users/");
    DataSnapshot userinfo = await ref.get();
    int i = 0;
    while (i < userinfo.children.length) {
      if ((userinfo.children.toList()[i].value as Map)["img"] != null) {
        if (!listaTemImagem.contains("${userinfo.child(i.toString()).key}")) {
          setState(() {
            listaTemImagem.add(
              "${userinfo.child(i.toString()).key}",
            );
          });
        }
      } else {
        setState(() {
          listaTemImagem.remove(
            "${userinfo.child(i.toString()).key}",
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
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ExpandableFab(
        key: fagKey,
        distance: 70,
        overlayStyle: ExpandableFabOverlayStyle(
          blur: 4,
        ),
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.edit_rounded),
        ),
        closeButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.close_rounded),
          fabSize: ExpandableFabSize.small,
        ),
        type: ExpandableFabType.up,
        children: [
          FloatingActionButton.extended(
            heroTag: null,
            onPressed: () async {
              final state = fagKey.currentState;
              if (state != null) {
                state.toggle();
              }
              await showModalBottomSheet(
                context: context,
                showDragHandle: true,
                builder: (ctx) {
                  return const TextPost();
                },
              );
              txtPost.text = "";
            },
            label: const Text("Texto"),
            icon: const Icon(Icons.text_fields_rounded),
          ),
          OpenContainer(
            onClosed: (data) {
              if (postado) {
                final state = fagKey.currentState;
                if (state != null) {
                  state.toggle();
                }
                Flushbar(
                  message: "Postando...",
                  duration: const Duration(seconds: 5),
                  margin: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(50),
                ).show(context);
                CachedNetworkImage.evictFromCache(
                  "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${int.parse("${snapshot?.children.last.key ?? 0}") + 1}.webp?alt=media",
                );
                _postarImagem(
                  int.parse("${snapshot?.children.last.key ?? 0}") + 1,
                  "img",
                );
              }
            },
            transitionDuration: const Duration(milliseconds: 400),
            closedElevation: 5,
            openColor: Theme.of(context).colorScheme.background,
            openBuilder: (context, action) => const ImagePost("image"),
            closedColor: Theme.of(context).colorScheme.primaryContainer,
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            closedBuilder: (context, action) => FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => action.call(),
              elevation: 0,
              label: const Text("Imagem"),
              icon: const Icon(Icons.image_rounded),
            ),
          ),
          OpenContainer(
            onClosed: (data) {
              if (postado) {
                final state = fagKey.currentState;
                if (state != null) {
                  state.toggle();
                }
                Flushbar(
                  message: "Postando...",
                  duration: const Duration(seconds: 5),
                  margin: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(50),
                ).show(context);
                CachedNetworkImage.evictFromCache(
                  "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${int.parse("${snapshot?.children.last.key ?? 0}") + 1}.webp?alt=media",
                );
                _postarImagem(
                  int.parse("${snapshot?.children.last.key ?? 0}") + 1,
                  "gif",
                );
              }
            },
            transitionDuration: const Duration(milliseconds: 400),
            closedElevation: 5,
            openColor: Theme.of(context).colorScheme.background,
            openBuilder: (context, action) => const ImagePost("gif"),
            closedColor: Theme.of(context).colorScheme.primaryContainer,
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            closedBuilder: (context, action) => FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => action.call(),
              elevation: 0,
              label: const Text("GIF"),
              icon: const Icon(Icons.gif_rounded),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      body: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Stack(
          children: [
            (snapshot?.exists ?? false)
                ? StretchingOverscrollIndicator(
                    axisDirection: AxisDirection.down,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return snapshot!
                                .child(
                                  "${int.parse(snapshot?.children.last.key ?? '0') - index}",
                                )
                                .exists
                            ? post(context, index)
                            : const Row();
                      },
                      itemCount: (snapshot?.exists ?? false)
                          ? (int.parse("${snapshot?.children.last.key}") + 1)
                          : 0,
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Container post(BuildContext context, int index) {
    final DataSnapshot postSS = snapshot!
        .child("${int.parse(snapshot?.children.last.key ?? "0") - index}");
    return Container(
      transform: Matrix4.translationValues(0, -20, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            10,
            10,
            10,
            20,
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      5,
                      0,
                      0,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              SlideRightAgainRoute(
                                PublicProfile(
                                  postSS.child("username").value as String,
                                ),
                              ),
                            );
                          },
                          child: listaTemImagem.contains(
                            postSS.child("username").value,
                          )
                              ? FadeInImage(
                                  fadeInDuration:
                                      const Duration(milliseconds: 100),
                                  placeholder:
                                      const AssetImage("assets/user.webp"),
                                  image: NetworkImage(
                                    "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F${postSS.child("username").value}.webp?alt=media",
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  "assets/user.webp",
                                  fit: BoxFit.cover,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 4,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SlideRightAgainRoute(
                                      PublicProfile(
                                        postSS
                                            .child("username")
                                            .value
                                            .toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  postSS.child("username").value.toString(),
                                  style: const TextStyle(
                                    fontFamily: "Jost",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ),
                            username == postSS.child("username").value
                                ? opcoes(index, postSS)
                                : const SizedBox(),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          _maisDe2Linhas(
                            postSS.child("content").value.toString(),
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  flag = !flag;
                                });
                              },
                              child: _maisDe2Linhas(
                                postSS.child("content").value.toString(),
                              )
                                  ? Text(
                                      flag ? "mostrar mais" : "mostrar menos",
                                      style: const TextStyle(
                                        color: Colors.grey,
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
                        postSS.child("img").value != null
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  10,
                                  10,
                                  10,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: InkWell(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (ctx) => Imagem(
                                            "${int.parse(snapshot!.children.last.key!) - index}",
                                          ),
                                        ),
                                      ),
                                      child: Hero(
                                        tag:
                                            "${int.parse(snapshot!.children.last.key!) - index}",
                                        child: FadeInImage(
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          fadeInDuration:
                                              const Duration(milliseconds: 150),
                                          fadeOutDuration:
                                              const Duration(milliseconds: 150),
                                          placeholder: const AssetImage(
                                            'assets/loading.gif',
                                          ),
                                          image: CachedNetworkImageProvider(
                                            "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${int.parse(snapshot!.children.last.key!) - index}.webp?alt=media",
                                          ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OpenContainer(
                    closedColor: Theme.of(context).colorScheme.background,
                    closedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    transitionDuration: const Duration(
                      milliseconds: 300,
                    ),
                    onClosed: (value) {},
                    openColor: Theme.of(context).colorScheme.background,
                    closedBuilder: (context, action) => Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () async {
                          action.call();
                        },
                        child: Text(
                          "Comentários (${postSS.child("comentarios").children.length - 2})",
                        ),
                      ),
                    ),
                    openBuilder: (context, action) => Comentarios(
                      int.parse(postSS.key!),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      style: ButtonStyle(
                        elevation: const MaterialStatePropertyAll(1),
                        shadowColor: const MaterialStatePropertyAll(
                          Colors.black,
                        ),
                        iconColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.onBackground,
                        ),
                        backgroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.background,
                        ),
                      ),
                      onPressed: () {
                        if (!postSS
                            .child("likes")
                            .child("users")
                            .value
                            .toString()
                            .split(",")
                            .contains(username)) {
                          _like(int.parse(postSS.key!));
                        } else {
                          _unlike(int.parse(postSS.key!));
                        }
                      },
                      icon: Icon(
                        postSS
                                .child("likes")
                                .child("users")
                                .value
                                .toString()
                                .split(",")
                                .contains(username)
                            ? Icons.thumb_up_alt
                            : Icons.thumb_up_alt_outlined,
                        color: postSS
                                .child("likes")
                                .child("users")
                                .value
                                .toString()
                                .split(",")
                                .contains(username)
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onBackground,
                      ),
                      label: Text(
                        "${postSS.child("likes").child("lenght").value}",
                        style: TextStyle(
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onBackground,
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
    );
  }

  Flexible opcoes(int index, DataSnapshot postSS) {
    return Flexible(
      child: Align(
        alignment: Alignment.topRight,
        child: PopupMenuButton<MenuItems>(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              onTap: () {
                showCupertinoDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    imagem = (snapshot?.value as List)[
                            int.parse(snapshot?.children.last.key ?? "0") -
                                index]["img"] !=
                        null;
                    return EditPost(
                      (int.parse(snapshot?.children.last.key ?? "0") - index)
                          .toString(),
                    );
                  },
                ).then((value) {
                  if (value) {
                    Flushbar(
                      message: "Editado com sucesso!",
                      duration: const Duration(seconds: 3),
                      margin: const EdgeInsets.all(20),
                      borderRadius: BorderRadius.circular(50),
                    ).show(context);
                  }
                });
              },
              child: const Text("Editar"),
            ),
            PopupMenuItem(
              onTap: () => showCupertinoDialog(
                context: context,
                builder: (context) => DeletePost(
                  int.parse(postSS.key!),
                ),
              ),
              child: const Text(
                "Deletar",
              ),
            )
          ],
        ),
      ),
    );
  }
}
