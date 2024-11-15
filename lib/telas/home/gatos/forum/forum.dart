import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gatopedia/telas/home/gatos/forum/new/image_post.dart';
import 'package:gatopedia/telas/home/gatos/forum/new/text_post.dart';
import 'package:gatopedia/telas/home/gatos/forum/view/post.dart';
import 'package:gatopedia/telas/main.dart';
import 'package:path_provider/path_provider.dart';

bool postado = false;
String imagemTipo = "";
String legenda = "";
File? file; /* arquivo pra comprimir o a imagem de upload do post */
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
        "users": (snapshotForum!.value as List)[post]["likes"]["users"].toString().replaceAll(",$username,", ""),
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
      body: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: snapshotForum != null
            ? StretchingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                child: ListView(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: snapshotForum!.children
                      .map((e) => e.value != null ? Post(int.parse(e.key!), _like, _unlike) : const SizedBox())
                      .toList()
                      .reversed
                      .toList(),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
