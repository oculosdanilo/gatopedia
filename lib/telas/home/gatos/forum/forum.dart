import 'dart:io';

import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gatopedia/components/post.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/gatos/forum/new/image_post.dart';
import 'package:gatopedia/telas/home/gatos/forum/new/text_post.dart';
import 'package:gatopedia/telas/home/gatos/gatos.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool postado = false;
String imagemTipo = "";
String legenda = "";
File? file; /* arquivo pra comprimir a imagem de upload do post */
final txtPost = TextEditingController();
final fagKey = GlobalKey<ExpandableFabState>();

class Forum extends StatefulWidget {
  final ScrollController scrollForum;

  const Forum(this.scrollForum, {super.key});

  @override
  State<Forum> createState() => _ForumState();
}

enum MenuItems { editar, deletar }

bool iniciouListenForum = false;
double scrollSalvo = 0;

class _ForumState extends State<Forum> {
  _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    ref.onValue.listen((event) {
      setState(() {
        snapshotForum = event.snapshot;
      });
    });
  }

  _postarImagem(int post, String filetype) async {
    CachedNetworkImage.evictFromCache(
        "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F$post.webp?alt=media");
    if (filetype == "img") {
      XFile? result = await FlutterImageCompress.compressAndGetFile(
        file!.absolute.path,
        "${(await getApplicationDocumentsDirectory()).path}aa.webp",
        quality: 80,
        format: CompressFormat.webp,
      );
      File finalFile = File(result!.path);
      await FirebaseStorage.instance.ref("posts/$post.webp").putFile(finalFile);
    } else {
      await FirebaseStorage.instance.ref("posts/$post.webp").putFile(file!);
    }
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
  }

  @override
  void initState() {
    // TODO: fazer o appbar() encolher beijos :*
    super.initState();
    tabIndex = 1;
    widget.scrollForum.addListener(() {
      scrollSalvo = widget.scrollForum.offset;
      if ((offsetInicial - scrollSalvo) > kToolbarHeight * 2.86 && !expandido) {
        debugPrint("expandiu");
        expandido = true;
      } else if ((offsetInicial - scrollSalvo) < -(kToolbarHeight * 2.86) && expandido) {
        debugPrint("encolheu");
        expandido = false;
      }
      SharedPreferences.getInstance().then((sp) {
        sp.setDouble("scrollSalvo", widget.scrollForum.offset);
      });
    });
    if (!iniciouListenForum) {
      _atualizar();
      iniciouListenForum = true;
    }
  }

  late double offsetInicial = widget.scrollForum.offset;

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
                child: GestureDetector(
                  onVerticalDragCancel: () {
                    setState(() {
                      offsetInicial = widget.scrollForum.offset;
                    });
                  },
                  child: ListView.builder(
                    controller: widget.scrollForum,
                    itemCount: int.parse(snapshotForum!.children.last.key!) + 1,
                    itemBuilder: (context, i) {
                      return snapshotForum!.child("${int.parse(snapshotForum!.children.last.key!) - i}").value != null
                          ? Post(int.parse("${int.parse(snapshotForum!.children.last.key!) - i}"))
                          : const SizedBox();
                    },
                  ),
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
