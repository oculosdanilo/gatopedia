import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/config/config.dart';
import 'package:gatopedia/telas/home/gatos/forum/edit/delete_post.dart';
import 'package:gatopedia/telas/home/gatos/forum/edit/edit_post.dart';
import 'package:gatopedia/telas/home/gatos/forum/forum.dart';
import 'package:gatopedia/telas/home/gatos/forum/view/comentarios.dart';
import 'package:gatopedia/telas/home/gatos/forum/view/imagem_view.dart';
import 'package:gatopedia/telas/home/public_profile.dart';
import 'package:grayscale/grayscale.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:material_symbols_icons/symbols.dart';

class Post extends StatefulWidget {
  final int index;
  final void Function(int) like;
  final void Function(int) unlike;

  const Post(this.index, this.like, this.unlike, {super.key});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  @override
  Widget build(BuildContext context) {
    DataSnapshot postSS =
        snapshotForum!.child("${widget.index}"); // tem que deixar isso aqui pra ele atualizar os likes
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
            color: username == null && dark
                ? Theme.of(context).colorScheme.surfaceTint.withOpacity(0.25)
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
                                      placeholder: const AssetImage('assets/anim/loading.gif'),
                                      image: CachedNetworkImageProvider(
                                          "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${widget.index}.webp?alt=media"),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(height: 15),
                      FooterPost(postSS, widget.like, widget.unlike),
                    ],
                  );
                },
              ),
            ),
          ),
          username == postSS.child("username").value
              ? Positioned(
                  right: 10,
                  top: 10,
                  child: opcoes(widget.index, postSS),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

class CabecalhoPost extends StatefulWidget {
  final DataSnapshot postSS;

  const CabecalhoPost(this.postSS, {super.key});

  @override
  State<CabecalhoPost> createState() => _CabecalhoPostState();
}

class _CabecalhoPostState extends State<CabecalhoPost> {
  String pedaco1 = "";
  String pedaco2 = "";
  bool flag = true;

  maisDe2Linhas(String text) {
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
                  placeholder: AssetImage("assets/anim/loading.gif"),
                  width: 40,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration(milliseconds: 125),
                  fadeOutDuration: Duration(milliseconds: 125),
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
                          duration: Duration(milliseconds: 250),
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
                        style: TextStyle(
                          fontSize: 20,
                          fontVariations: const [FontVariation("wght", 600.0)],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      maisDe2Linhas(widget.postSS.child("content").value.toString())
                          ? flag
                              ? "$pedaco1..."
                              : pedaco1 + pedaco2
                          : pedaco1,
                      style: TextStyle(fontSize: 16),
                      softWrap: true,
                      maxLines: 50,
                    ),
                    maisDe2Linhas(widget.postSS.child("content").value.toString())
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () => setState(() => flag = !flag),
                                child: Text(
                                  flag ? "mostrar mais" : "mostrar menos",
                                  style: const TextStyle(color: Colors.grey),
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
                    style: TextStyle(
                      fontSize: 20,
                      fontVariations: const [FontVariation("wght", 600.0)],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
        SizedBox(width: username == widget.postSS.child("username").value ? 58 : 15)
      ],
    );
  }
}

Widget opcoes(int index, DataSnapshot postSS) {
  // TODO: fazer o coiso de bloquear um usuário
  return PopupMenuButton<MenuItems>(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    itemBuilder: (context) => [
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
            Text("Editar", style: TextStyle(fontSize: 15)),
          ],
        ),
      ),
      PopupMenuItem(
        onTap: () => showCupertinoDialog(context: context, builder: (context) => DeletePost(int.parse(postSS.key!))),
        child: Row(
          children: [
            Icon(Symbols.delete_rounded, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 10),
            Text("Deletar", style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 15)),
          ],
        ),
      )
    ],
  );
}

class FooterPost extends StatefulWidget {
  final DataSnapshot postSS;
  final void Function(int) like;
  final void Function(int) unlike;

  const FooterPost(this.postSS, this.like, this.unlike, {super.key});

  @override
  State<FooterPost> createState() => _FooterPostState();
}

class _FooterPostState extends State<FooterPost> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OpenContainer(
            closedColor: username != null
                ? Theme.of(context).colorScheme.surface
                : GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light).surface,
            closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            transitionDuration: const Duration(milliseconds: 300),
            openColor: username != null
                ? Theme.of(context).colorScheme.surface
                : GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light).surface,
            closedBuilder: (context, action) => username != null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        action.call();
                      },
                      icon: Icon(AntDesign.comment_outline),
                      label: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        constraints: BoxConstraints(minWidth: 21),
                        height: 21,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Text(
                              "${widget.postSS.child("comentarios").children.length - 2}",
                              style: TextStyle(
                                fontSize: 15,
                                fontVariations: [FontVariation("wght", 600)],
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : Theme(
                    data: ThemeData.from(
                      colorScheme: GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light),
                      useMaterial3: true,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () async {
                          action.call();
                        },
                        child: Text(
                          "Comentários",
                          style: TextStyle(
                            color:
                                GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light).onSurface,
                            fontSize: 15,
                            fontVariations: [FontVariation("wght", 600)],
                          ),
                        ),
                      ),
                    ),
                  ),
            openBuilder: (context, action) => username != null
                ? ComentariosForum(widget.postSS)
                : Theme(
                    data: ThemeData.from(
                      colorScheme: GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light),
                      useMaterial3: true,
                    ),
                    child: ComentariosForum(widget.postSS),
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
                        if (!widget.postSS.child("likes/users").value.toString().contains(",$username,")) {
                          widget.like(int.parse(widget.postSS.key!));
                        } else {
                          widget.unlike(int.parse(widget.postSS.key!));
                        }
                      });
                    }
                  : null,
              icon: Icon(
                widget.postSS.child("likes/users").value.toString().contains(",$username,")
                    ? Icons.thumb_up_off_alt_rounded
                    : Icons.thumb_up_off_alt_outlined,
                color: username != null
                    ? widget.postSS.child("likes/users").value.toString().contains(",$username,")
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface
                    : Colors.grey,
              ),
              label: Text(
                "${widget.postSS.child("likes/lenght").value}",
                style: TextStyle(
                  fontSize: 18,
                  color: username != null
                      ? widget.postSS.child("likes/users").value.toString().contains(",$username,")
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface
                      : Colors.grey,
                  fontVariations: [
                    FontVariation(
                      "wght",
                      widget.postSS.child("likes/users").value.toString().contains(",$username,") ? 600 : 400,
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
}
