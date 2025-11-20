// ignore_for_file: prefer_const_constructors

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/components/comentario.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';

class ComentariosWiki extends StatefulWidget {
  final String gatoID;
  final String gatoName;
  final String gatoHash;
  final String gatoImgID;

  const ComentariosWiki(this.gatoID, this.gatoName, this.gatoHash, this.gatoImgID, {super.key});

  @override
  State<ComentariosWiki> createState() => _ComentariosWikiState();
}

class _ComentariosWikiState extends State<ComentariosWiki> {
  final _txtComment = TextEditingController();

  void _postarC() {}

  dynamic _deletarC(int index) {}

  Future<DataSnapshot> _fetchComentarios() {
    return FirebaseDatabase.instance.ref("gatos/${widget.gatoID}/comentarios").get();
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
          flexibleSpace: FlexibleSpaceBar(
            title: Transform.translate(
              offset: Offset(0, 3),
              child: Padding(
                padding: const EdgeInsets.only(left: 56),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image(
                        image: NetworkImage(
                            "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/gatos%2F${widget.gatoImgID}.webp?alt=media"),
                        width: 30,
                        errorBuilder: (c, obj, stacktrace) {
                          return Image.asset("assets/user.webp", width: 30);
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        widget.gatoName,
                        style: const TextStyle(fontVariations: [FontVariation("wght", 600)], fontSize: 20),
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
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
                              controller: _txtComment,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).wiki_info_commentHint,
                                prefix: SizedBox(width: 10),
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
                                if (_txtComment.text != "") {
                                  _postarC();
                                  _txtComment.text = "";
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
              FutureBuilder<DataSnapshot>(
                future: _fetchComentarios(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    DataSnapshot snapData = snapshot.data!;
                    if (snapData.children.length > 2) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapData.children.length - 2,
                          itemBuilder: (context, i) {
                            final index = snapData.children.length - i;
                            final thisComment = snapData.child("$index");
                            return thisComment.child("user").value != null
                                ? Comentario(
                                    index,
                                    thisComment.child("user").value as String,
                                    thisComment.child("content").value as String,
                                    _deletarC,
                                    key: Key(
                                      (thisComment.child("user").value as String) +
                                          (thisComment.child("content").value as String) +
                                          index.toString(),
                                    ), /* key pra cada comentario ter sua propria foto certinho */
                                  )
                                : const SizedBox();
                          },
                        ),
                      );
                    } else {
                      return const SizedBox(
                        height: 80,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [Text("Nenhum comentário (ainda...)")],
                        ),
                      );
                    }
                  } else {
                    return CircularProgressIndicator(value: null);
                  }
                },
              ),
              /*postAtual.child("comentarios").children.length > 2
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
                                  ), */ /* key pra cada comentario ter sua propria foto certinho */ /*
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
                    ),*/
            ],
          ),
        ),
      ),
    );
  }
}
