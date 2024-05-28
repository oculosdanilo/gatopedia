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
import 'package:gatopedia/home/config/config.dart';
import 'package:gatopedia/home/gatos/forum/comentarios.dart';
import 'package:gatopedia/home/gatos/forum/delete_post.dart';
import 'package:gatopedia/home/gatos/forum/edit_post.dart';
import 'package:gatopedia/home/gatos/forum/image_post.dart';
import 'package:gatopedia/home/gatos/forum/imagem_view.dart';
import 'package:gatopedia/home/gatos/forum/text_post.dart';
import 'package:gatopedia/home/gatos/public_profile.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grayscale/grayscale.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:path_provider/path_provider.dart';

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
        snapshotForum = event.snapshot;
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
      "lenght": int.parse(snapshotForum!.child("$post/likes/lenght").value.toString()) + 1,
      "users": "${snapshotForum!.child("$post/likes/users").value},$username,"
    });
  }

  _unlike(int post) {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$post/likes");
    ref.update(
      {
        "lenght": (snapshotForum!.value as List)[post]["likes"]["lenght"] - 1,
        "users": (snapshotForum!.value as List)[post]["likes"]["users"].toString().replaceAll(
              ",$username,",
              "",
            ),
      },
    );
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
    return Scaffold(
      floatingActionButton: username != null
          ? ExpandableFab(
              key: fagKey,
              distance: 70,
              overlayStyle: ExpandableFabOverlayStyle(blur: 4),
              openButtonBuilder: DefaultFloatingActionButtonBuilder(child: const Icon(Icons.edit_rounded)),
              closeButtonBuilder: DefaultFloatingActionButtonBuilder(
                  child: const Icon(Icons.close_rounded), fabSize: ExpandableFabSize.small),
              type: ExpandableFabType.up,
              children: [
                FloatingActionButton.extended(
                  heroTag: null,
                  onPressed: () async {
                    final state = fagKey.currentState;
                    if (state != null) state.toggle();
                    await showModalBottomSheet(
                      context: context,
                      showDragHandle: true,
                      useSafeArea: true,
                      isScrollControlled: true,
                      builder: (ctx) => const TextPost(),
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
                      if (state != null) state.toggle();
                      Flushbar(
                        message: "Postando...",
                        duration: const Duration(seconds: 5),
                        margin: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(50),
                      ).show(context);
                      CachedNetworkImage.evictFromCache(
                          "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${int.parse("${snapshotForum!.children.last.key ?? 0}") + 1}.webp?alt=media");
                      _postarImagem(int.parse("${snapshotForum!.children.last.key ?? 0}") + 1, "img");
                    }
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                  closedElevation: 5,
                  openColor: Theme.of(context).colorScheme.surface,
                  openBuilder: (context, action) => const ImagePost("image"),
                  closedColor: Theme.of(context).colorScheme.primaryContainer,
                  closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                      if (state != null) state.toggle();
                      Flushbar(
                        message: "Postando...",
                        duration: const Duration(seconds: 5),
                        margin: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(50),
                      ).show(context);
                      CachedNetworkImage.evictFromCache(
                          "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${int.parse("${snapshotForum!.children.last.key ?? 0}") + 1}.webp?alt=media");
                      _postarImagem(int.parse("${snapshotForum!.children.last.key ?? 0}") + 1, "gif");
                    }
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                  closedElevation: 5,
                  openColor: Theme.of(context).colorScheme.surface,
                  openBuilder: (context, action) => const ImagePost("gif"),
                  closedColor: Theme.of(context).colorScheme.primaryContainer,
                  closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  closedBuilder: (context, action) => FloatingActionButton.extended(
                    heroTag: null,
                    onPressed: () => action.call(),
                    elevation: 0,
                    label: const Text("GIF"),
                    icon: const Icon(Icons.gif_rounded),
                  ),
                ),
              ],
            )
          : null,
      floatingActionButtonLocation: ExpandableFab.location,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: snapshotForum != null
                  ? StretchingOverscrollIndicator(
                      axisDirection: AxisDirection.down,
                      child: ListView(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: snapshotForum!.children
                            .map((e) => e.value != null ? post(context, int.parse(e.key!)) : const SizedBox())
                            .toList()
                            .reversed
                            .toList(),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }

  Widget post(BuildContext context, int index) {
    final DataSnapshot postSS = snapshotForum!.child("$index");
    return Stack(
      children: [
        Container(
          transform: Matrix4.translationValues(0, username != null ? -20 : 0, 0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            color: username == null && dark
                ? Theme.of(context).colorScheme.surfaceTint.withOpacity(0.25)
                : Theme.of(context).colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
              child: StreamBuilder<Object>(
                stream: null,
                builder: (context, snapshot) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: ClipOval(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    SlideRightAgainRoute(PublicProfile(postSS.child("username").value as String)),
                                  ),
                                  child: FadeInImage(
                                    fadeInDuration: const Duration(milliseconds: 100),
                                    placeholder: const AssetImage("assets/user.webp"),
                                    image: NetworkImage(
                                        "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F${postSS.child("username").value}.webp?alt=media"),
                                    imageErrorBuilder: (c, obj, stacktrace) =>
                                        Image.asset("assets/user.webp", fit: BoxFit.cover),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () => Navigator.push(
                                          context,
                                          SlideRightAgainRoute(PublicProfile("${postSS.child("username").value}")),
                                        ),
                                        child: Text(
                                          "${postSS.child("username").value}",
                                          style: GoogleFonts.jost(fontWeight: FontWeight.w500, fontSize: 20),
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: username == postSS.child("username").value ? 35 : 0),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _maisDe2Linhas(postSS.child("content").value.toString())
                                      ? flag
                                          ? "$pedaco1..."
                                          : pedaco1 + pedaco2
                                      : pedaco1,
                                  style: GoogleFonts.jost(fontSize: 16),
                                  softWrap: true,
                                  maxLines: 50,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () => setState(() => flag = !flag),
                                      child: _maisDe2Linhas(postSS.child("content").value.toString())
                                          ? Text(
                                              flag ? "mostrar mais" : "mostrar menos",
                                              style: const TextStyle(color: Colors.grey),
                                            )
                                          : const SizedBox(height: 5),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      postSS.child("img").value != null
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  splashFactory: NoSplash.splashFactory,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => Imagem(
                                        "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F$index.webp?alt=media",
                                        "$index",
                                      ),
                                    ),
                                  ),
                                  child: Hero(
                                    tag: "$index",
                                    child: FadeInImage(
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      fadeInDuration: const Duration(milliseconds: 150),
                                      fadeOutDuration: const Duration(milliseconds: 150),
                                      placeholder: const AssetImage('assets/anim/loading.gif'),
                                      image: CachedNetworkImageProvider(
                                          "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F$index.webp?alt=media"),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            OpenContainer(
                              closedColor: username != null
                                  ? Theme.of(context).colorScheme.surface
                                  : GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light).surface,
                              closedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                              openColor: username != null
                                  ? Theme.of(context).colorScheme.surface
                                  : GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light).surface,
                              closedBuilder: (context, action) => username != null
                                  ? Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton(
                                        onPressed: () async {
                                          action.call();
                                        },
                                        child: Text(
                                          "Comentários (${postSS.child("comentarios").children.length - 2})",
                                          style: GoogleFonts.jost(fontSize: 15, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    )
                                  : Theme(
                                      data: ThemeData.from(
                                        colorScheme:
                                            GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light),
                                        useMaterial3: true,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton(
                                          onPressed: () async {
                                            action.call();
                                          },
                                          child: Text(
                                            "Comentários (${postSS.child("comentarios").children.length - 2})",
                                            style: GoogleFonts.jost(
                                              color: GrayColorScheme.highContrastGray(
                                                      dark ? Brightness.dark : Brightness.light)
                                                  .onSurface,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              openBuilder: (context, action) => username != null
                                  ? Comentarios(postSS)
                                  : Theme(
                                      data: ThemeData.from(
                                        colorScheme:
                                            GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light),
                                        useMaterial3: true,
                                      ),
                                      child: Comentarios(postSS),
                                    ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                style: ButtonStyle(
                                  elevation: const WidgetStatePropertyAll(1),
                                  shadowColor: const WidgetStatePropertyAll(Colors.black),
                                  backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surface),
                                ),
                                onPressed: username != null
                                    ? () {
                                        if (!postSS.child("likes/users").value.toString().contains(",$username,")) {
                                          _like(int.parse(postSS.key!));
                                        } else {
                                          _unlike(int.parse(postSS.key!));
                                        }
                                      }
                                    : null,
                                icon: Icon(
                                  postSS.child("likes/users").value.toString().contains(",$username,")
                                      ? Icons.thumb_up_off_alt_rounded
                                      : Icons.thumb_up_off_alt_outlined,
                                  color: username != null
                                      ? postSS.child("likes/users").value.toString().contains(",$username,")
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurface
                                      : Colors.grey,
                                ),
                                label: Text(
                                  "${postSS.child("likes/lenght").value}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: username != null
                                        ? postSS.child("likes/users").value.toString().contains(",$username,")
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.onSurface
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        username == postSS.child("username").value
            ? Positioned(
                right: 5,
                top: 0,
                child: Transform.translate(offset: const Offset(0, -10), child: opcoes(index, postSS)),
              )
            : const SizedBox(),
      ],
    );
  }

  Widget opcoes(int index, DataSnapshot postSS) {
    return PopupMenuButton<MenuItems>(
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
                imagem = snapshotForum!.child("${int.parse(postSS.key!)}/img").value != null;
                return EditPost((int.parse(postSS.key!)).toString());
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
          child: Row(
            children: [
              const Icon(Symbols.edit_rounded, fill: 1),
              const SizedBox(width: 10),
              Text("Editar", style: GoogleFonts.jost(fontSize: 15)),
            ],
          ),
        ),
        PopupMenuItem(
          onTap: () => showCupertinoDialog(context: context, builder: (context) => DeletePost(int.parse(postSS.key!))),
          child: Row(
            children: [
              Icon(Symbols.delete_rounded, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 10),
              Text("Deletar", style: GoogleFonts.jost(color: Theme.of(context).colorScheme.error, fontSize: 15)),
            ],
          ),
        )
      ],
    );
  }
}
