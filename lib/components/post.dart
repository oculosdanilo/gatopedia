import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/components/loading.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/gatos/forum/edit/delete_post.dart';
import 'package:gatopedia/telas/home/gatos/forum/edit/edit_post.dart';
import 'package:gatopedia/telas/home/gatos/forum/forum.dart';
import 'package:gatopedia/telas/home/gatos/forum/view/comentarios.dart';
import 'package:gatopedia/telas/home/gatos/forum/view/imagem_view.dart';
import 'package:gatopedia/telas/home/public_profile.dart';
import 'package:gatopedia/telas/index.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:material_symbols_icons/symbols.dart';

class Post extends StatefulWidget {
  final int index;
  final EdgeInsets pd;
  final bool last;

  const Post(this.index, this.pd, this.last, {super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  void _notificar() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    DataSnapshot postSS = Forum.snapshotForum.value!.child("${widget.index}");
    return Padding(
      padding: EdgeInsets.only(top: widget.last ? (kToolbarHeight * 2.86) + 5 : 5),
      child: Stack(
        children: [
          postSS.key == "0"
              ? Positioned(
                  bottom: username != null ? 35 : 115 + widget.pd.bottom,
                  width: MediaQuery.sizeOf(context).width - 20,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).end,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                )
              : const SizedBox(),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
            margin: EdgeInsets.fromLTRB(
              4,
              4,
              4,
              postSS.key == "0"
                  ? username != null
                      ? 85
                      : 165 + widget.pd.bottom
                  : 4,
            ),
            color: username == null && _isDark(context)
                ? Theme.of(context).colorScheme.surfaceTint.withValues(alpha: 0.25)
                : Theme.of(context).colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 15),
              child: StreamBuilder<Object>(
                stream: null,
                builder: (context, snapshot) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CabecalhoPost(postSS),
                      postSS.child("img").value != null
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 14),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  splashFactory: NoSplash.splashFactory,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => Imagem(
                                        "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${widget.index}.webp?alt=media",
                                        "${widget.index}",
                                      ),
                                    ),
                                  ),
                                  child: Hero(
                                    tag: "${widget.index}",
                                    child: FadeInImage(
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      fadeInDuration: const Duration(milliseconds: 150),
                                      fadeOutDuration: const Duration(milliseconds: 150),
                                      placeholder: const NetworkImage(""),
                                      image: CachedNetworkImageProvider(
                                          "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${widget.index}.webp?alt=media"),
                                      placeholderErrorBuilder: (ctx, _, __) {
                                        return const Align(
                                          alignment: Alignment.center,
                                          child: LoadingImage(),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(height: 15),
                      FooterPost(postSS, _notificar),
                    ],
                  );
                },
              ),
            ),
          ),
          username != null
              ? Positioned(
                  right: 10,
                  top: 10,
                  child: _opcoes(widget.index, postSS),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  bool _isDark(BuildContext context) {
    if (App.themeNotifier.value == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    } else {
      return App.themeNotifier.value == ThemeMode.dark;
    }
  }
}

class CabecalhoPost extends StatefulWidget {
  final DataSnapshot postSS;

  const CabecalhoPost(this.postSS, {super.key});

  @override
  State<CabecalhoPost> createState() => _CabecalhoPostState();
}

List<String> _mostrarMais = [];

class _CabecalhoPostState extends State<CabecalhoPost> {
  String pedaco1 = "";
  String pedaco2 = "";

  bool maisDe2Linhas(String text) {
    if (text.length > 65) {
      pedaco1 = text.substring(0, 65);
      pedaco2 = text.substring(65, text.length);
      return true;
    } else {
      pedaco1 = text;
      return false;
    }
  }

  late Future<String?> Function(String usernamePost) _pegarFotoGoogle;

  @override
  void initState() {
    super.initState();
    _pegarFotoGoogle = (String usernamePost) async {
      final ref = FirebaseDatabase.instance.ref("users/$usernamePost/img");
      DataSnapshot link = await ref.get();
      return link.value as String?;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 5, 0, 0),
          child: SizedBox(
            width: 40,
            height: 40,
            child: ClipOval(
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  SlideRightAgainRoute(PublicProfile(widget.postSS.child("username").value as String)),
                ),
                child: FadeInImage(
                  image: NetworkImage(
                      "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F${widget.postSS.child("username").value}.webp?alt=media"),
                  placeholder: const AssetImage("assets/anim/loading.gif"),
                  width: 40,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 125),
                  fadeOutDuration: const Duration(milliseconds: 125),
                  imageErrorBuilder: (c, obj, stacktrace) {
                    return FutureBuilder(
                      future: _pegarFotoGoogle(widget.postSS.child("username").value.toString()),
                      builder: (context, snapshotFoto) {
                        Widget filho;
                        if (snapshotFoto.connectionState == ConnectionState.done) {
                          if (snapshotFoto.hasData) {
                            filho = Image.network(
                              snapshotFoto.data!,
                              width: 40,
                              fit: BoxFit.cover,
                            );
                          } else {
                            filho = Image.asset(
                              "assets/user.webp",
                              width: 40,
                              fit: BoxFit.cover,
                            );
                          }
                        } else {
                          filho = Image.asset(
                            "assets/anim/loading.gif",
                            width: 40,
                            fit: BoxFit.cover,
                          );
                        }

                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: filho,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        widget.postSS.child("content").value.toString() != ""
            ? Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        SlideRightAgainRoute(PublicProfile("${widget.postSS.child("username").value}")),
                      ),
                      child: Text(
                        "@${widget.postSS.child("username").value}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontVariations: [FontVariation("wght", 600.0)],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      maisDe2Linhas(widget.postSS.child("content").value.toString())
                          ? !_mostrarMais.contains(widget.postSS.key!)
                              ? "$pedaco1..."
                              : pedaco1 + pedaco2
                          : pedaco1,
                      style: const TextStyle(fontSize: 16),
                      softWrap: true,
                      maxLines: 50,
                    ),
                    maisDe2Linhas(widget.postSS.child("content").value.toString())
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () => setState(() {
                                  if (!_mostrarMais.contains(widget.postSS.key!)) {
                                    _mostrarMais.add(widget.postSS.key!);
                                  } else {
                                    _mostrarMais.remove(widget.postSS.key!);
                                  }
                                }),
                                child: Text(
                                  !_mostrarMais.contains(widget.postSS.key!) ? "mostrar mais" : "mostrar menos",
                                  style:
                                      const TextStyle(color: Colors.grey, fontVariations: [FontVariation.weight(450)]),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
              )
            : Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 45,
                  child: Text(
                    "${widget.postSS.child("username").value}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontVariations: [FontVariation("wght", 600.0)],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
        const SizedBox(width: 58)
      ],
    );
  }
}

Widget _opcoes(int index, DataSnapshot postSS) {
  // TODO: fazer o coiso de bloquear um usuário
  return PopupMenuButton<MenuItems>(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    itemBuilder: postSS.child("username").value == username
        ? (context) => [
              PopupMenuItem(
                onTap: () {
                  showCupertinoDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return EditPost(postSS.key!);
                    },
                  ).then((value) {
                    if (value) {
                      if (!context.mounted) return;
                      Flushbar(
                        message: AppLocalizations.of(context).forum_editPost_success,
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
                    Text(AppLocalizations.of(context).forum_editPost_btn, style: const TextStyle(fontSize: 15)),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () =>
                    showCupertinoDialog(context: context, builder: (context) => DeletePost(int.parse(postSS.key!))),
                child: Row(
                  children: [
                    Icon(Symbols.delete_rounded, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context).forum_delete_btn,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 15),
                    ),
                  ],
                ),
              )
            ]
        : (context) => [
              PopupMenuItem(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Symbols.block, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context).forum_block,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
  );
}

Widget alertaBlock(String userBloqueado) {
  return const AlertDialog();
}

class FooterPost extends StatefulWidget {
  final DataSnapshot postSS;
  final void Function() notificarPost;

  const FooterPost(this.postSS, this.notificarPost, {super.key});

  @override
  State<FooterPost> createState() => _FooterPostState();
}

class _FooterPostState extends State<FooterPost> {
  late DataSnapshot postSS = widget.postSS;

  Future<void> _like(int post) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$post/likes");
    await ref.update({
      "lenght": int.parse(Forum.snapshotForum.value!.child("$post/likes/lenght").value.toString()) + 1,
      "users": "${Forum.snapshotForum.value!.child("$post/likes/users").value},$username,"
    });
    widget.notificarPost();
    setState(() {});
  }

  Future<void> _unlike(int post) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$post/likes");
    await ref.update(
      {
        "lenght": (Forum.snapshotForum.value!.value as List)[post]["likes"]["lenght"] - 1,
        "users":
            (Forum.snapshotForum.value!.value as List)[post]["likes"]["users"].toString().replaceAll(",$username,", ""),
      },
    );
    widget.notificarPost();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    postSS = widget.postSS;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OpenContainer(
            closedColor: username != null
                ? Theme.of(context).colorScheme.surface
                : temaBaseBW(App.themeNotifier.value, context).colorScheme.surface,
            closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            transitionDuration: const Duration(milliseconds: 300),
            openColor: username != null
                ? Theme.of(context).colorScheme.surface
                : temaBaseBW(App.themeNotifier.value, context).colorScheme.surface,
            closedBuilder: (context, action) => username != null
                ? _comentariosBtn(action, context)
                : Theme(
                    data: ThemeData.from(
                      colorScheme: temaBaseBW(App.themeNotifier.value, context).colorScheme,
                      useMaterial3: true,
                    ),
                    child: _comentariosBtn(action, context),
                  ),
            openBuilder: (context, action) => username != null
                ? ComentariosForum(postSS)
                : Theme(
                    data: ThemeData.from(
                      textTheme: temaBaseBW(App.themeNotifier.value, context).textTheme.apply(fontFamily: "Jost"),
                      colorScheme: temaBaseBW(App.themeNotifier.value, context).colorScheme,
                      useMaterial3: true,
                    ),
                    child: ComentariosForum(postSS),
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
                      setState(() {
                        if (!postSS.child("likes/users").value.toString().contains(",$username,")) {
                          _like(int.parse(postSS.key!));
                        } else {
                          _unlike(int.parse(postSS.key!));
                        }
                      });
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
                  fontVariations: [
                    FontVariation(
                      "wght",
                      postSS.child("likes/users").value.toString().contains(",$username,") ? 600 : 400,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Align _comentariosBtn(VoidCallback action, BuildContext context) {
    final comentarios = postSS.child("comentarios").value as List<Object?>;
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () async => action.call(),
        icon: Icon(
          AntDesign.comment_outline,
          color: username != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
        ),
        label: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(999),
          ),
          constraints: const BoxConstraints(minWidth: 21),
          height: 21,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                "${comentarios.where((snap) => snap != null).length - 2}",
                style: TextStyle(
                  fontSize: 15,
                  fontVariations: [const FontVariation("wght", 600)],
                  color: username != null
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
