import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/telas/home/config/config.dart';
import 'package:gatopedia/telas/home/gatos/forum/edit/delete_post.dart';
import 'package:gatopedia/telas/home/gatos/forum/edit/edit_post.dart';
import 'package:gatopedia/telas/home/gatos/forum/forum.dart';
import 'package:gatopedia/telas/home/gatos/forum/view/comentarios.dart';
import 'package:gatopedia/telas/home/gatos/forum/view/imagem_view.dart';
import 'package:gatopedia/telas/home/gatos/public_profile.dart';
import 'package:gatopedia/main.dart';
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

  @override
  Widget build(BuildContext context) {
    DataSnapshot postSS = snapshotForum!.child("${widget.index}");
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
                      Row(
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
                                    SlideRightAgainRoute(PublicProfile(postSS.child("username").value as String)),
                                  ),
                                  child: FadeInImage(
                                    fadeInDuration: const Duration(milliseconds: 100),
                                    placeholder: const AssetImage("assets/anim/loading.gif"),
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
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontVariations: const [FontVariation("wght", 600.0)],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: username == postSS.child("username").value ? 58 : 10),
                                  ],
                                ),
                                Text(
                                  maisDe2Linhas(postSS.child("content").value.toString())
                                      ? flag
                                          ? "$pedaco1..."
                                          : pedaco1 + pedaco2
                                      : pedaco1,
                                  style: TextStyle(fontSize: 16),
                                  softWrap: true,
                                  maxLines: 50,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () => setState(() => flag = !flag),
                                      child: maisDe2Linhas(postSS.child("content").value.toString())
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
                          SizedBox(width: username == postSS.child("username").value ? 58 : 15)
                        ],
                      ),
                      postSS.child("img").value != null
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 14),
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
                      Padding(
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
                                                "${postSS.child("comentarios").children.length - 2}",
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
                                            "Comentários",
                                            style: TextStyle(
                                              color: GrayColorScheme.highContrastGray(
                                                      dark ? Brightness.dark : Brightness.light)
                                                  .onSurface,
                                              fontSize: 15,
                                              fontVariations: [FontVariation("wght", 600)],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              openBuilder: (context, action) => username != null
                                  ? ComentariosForum(postSS)
                                  : Theme(
                                      data: ThemeData.from(
                                        colorScheme:
                                            GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light),
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
                                            widget.like(int.parse(postSS.key!));
                                          } else {
                                            widget.unlike(int.parse(postSS.key!));
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
                                        postSS.child("likes/users").value.toString().contains(",$username,")
                                            ? 600
                                            : 400,
                                      )
                                    ],
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

Widget opcoes(int index, DataSnapshot postSS) {
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
