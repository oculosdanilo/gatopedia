import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/animations/routes.dart';
import 'package:gatopedia/components/comentario.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/screens/home/gatos/forum/forum.dart';
import 'package:gatopedia/screens/home/public_profile.dart';

class ComentariosForum extends StatefulWidget {
  final DataSnapshot post;

  const ComentariosForum(this.post, {super.key});

  @override
  State<ComentariosForum> createState() => _ComentariosForumState();
}

class _ComentariosForumState extends State<ComentariosForum> {
  String pedaco1 = "";
  String pedaco2 = "";
  bool flag = true;
  final txtComment = TextEditingController();
  late StreamSubscription<DatabaseEvent> _sub;

  late DataSnapshot postAtual = widget.post;

  void _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    _sub = ref.onValue.listen((event) {
      if (mounted) {
        setState(() {
          Forum.snapshotForum.value = event.snapshot;
          postAtual = event.snapshot.child("${postAtual.key}");
        });
      }
    });
  }

  Future<void> _postarC() async {
    DatabaseReference ref = postAtual.child("comentarios").ref;
    await ref.update({
      "${int.parse(postAtual.child("comentarios").children.last.key!) + 2}": {
        "username": username,
        "content": txtComment.text,
      },
    });
  }

  Future<void> _deletarC(int comment) async {
    DatabaseReference ref = postAtual.child("comentarios/$comment").ref;
    await ref.remove();
  }

  bool _maisDe2Linhas(String text) {
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
    _sub.cancel();
    super.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            SlideRightAgainRoute(PublicProfile(postAtual.child("username").value as String)),
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
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              SlideRightAgainRoute(PublicProfile(postAtual.child("username").value as String)),
                            ),
                            child: Text(
                              "${postAtual.child("username").value}",
                              style: const TextStyle(fontVariations: [FontVariation("wght", 600)], fontSize: 20),
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _maisDe2Linhas(postAtual.child("content").value as String)
                                ? flag
                                    ? "$pedaco1..."
                                    : pedaco1 + pedaco2
                                : pedaco1,
                            style: const TextStyle(fontSize: 17),
                            softWrap: true,
                            maxLines: 50,
                          ),
                          _maisDe2Linhas(postAtual.child("content").value as String)
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () => setState(() => flag = !flag),
                                    child: Text(
                                      flag ? "mostrar mais" : "mostrar menos",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
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
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).wiki_info_commentHint,
                                prefix: const SizedBox(width: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            flex: 2,
                            child: IconButton.filled(
                              icon: const Icon(Icons.send_rounded),
                              iconSize: 25,
                              padding: const EdgeInsets.all(15),
                              onPressed: () async {
                                if (txtComment.text != "") {
                                  _postarC();
                                  txtComment.text = "";
                                  Flushbar(
                                    message: "Postado com sucesso!",
                                    duration: const Duration(seconds: 3),
                                    margin: const EdgeInsets.all(20),
                                    borderRadius: BorderRadius.circular(50),
                                  ).show(context);
                                }
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
                        itemBuilder: (c, i) {
                          int index = postAtual.child("comentarios").children.length - i;
                          return postAtual.child("comentarios/$index/username").value != null
                              ? Comentario(
                                  index,
                                  postAtual.child("comentarios/$index/username").value as String,
                                  postAtual.child("comentarios/$index/content").value as String,
                                  _deletarC,
                                  key: Key(
                                    (postAtual.child("comentarios/$index/username").value as String) +
                                        (postAtual.child("comentarios/$index/content").value as String) +
                                        index.toString(),
                                  ), /* key pra cada comentario ter sua propria foto certinho */
                                )
                              : const SizedBox();
                        },
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
}
