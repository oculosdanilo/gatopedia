// ignore_for_file: prefer_const_constructors

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:gatopedia/components/comentario.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:uuid/uuid.dart';

class ComentariosWiki extends StatefulWidget {
  final String gatoID;
  final String gatoName;
  final String gatoHash;

  const ComentariosWiki(this.gatoID, this.gatoName, this.gatoHash, {super.key});

  @override
  State<ComentariosWiki> createState() => _ComentariosWikiState();
}

class _ComentariosWikiState extends State<ComentariosWiki> {
  final uuid = Uuid();
  final _txtComment = TextEditingController();

  late Future<DataSnapshot> _comentarios;

  late Future<String> _imageUrlGet;
  bool _pegouImageUrl = false;

  void _postarC() {}

  dynamic _deletarC(int index) {}

  void _fetchComentarios() {
    final DatabaseReference query = FirebaseDatabase.instance.ref("gatos/${widget.gatoID}");
    _comentarios = query.get();
  }

  @override
  void initState() {
    super.initState();
    _fetchComentarios();

    if (!_pegouImageUrl) {
      _imageUrlGet = FirebaseStorage.instance.ref("gatos/${widget.gatoID}_mini.webp").getDownloadURL();
      _pegouImageUrl = true;
    }
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
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: FutureBuilder(
                          future: _imageUrlGet,
                          builder: (context, asyncSnapshot) {
                            if (asyncSnapshot.hasData && asyncSnapshot.connectionState == ConnectionState.done) {
                              return BlurHash(
                                hash: widget.gatoHash,
                                image: asyncSnapshot.requireData,
                                duration: const Duration(milliseconds: 150),
                                color: Theme.of(context).colorScheme.surface,
                                imageFit: BoxFit.cover,
                                decodingHeight: 30,
                                decodingWidth: 30,
                              );
                            } else {
                              return BlurHash(hash: widget.gatoHash, decodingHeight: 30, decodingWidth: 30);
                            }
                          },
                        ),
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
              /*FilledButton(
                onPressed: () async {
                  final snapgatos = await FirebaseDatabase.instance.ref("gatos").get();
                  for (final e in snapgatos.children) {
                    final ereversed = e.child("comentarios").children.toList().reversed;
                    for (final comentario in ereversed) {
                      await comentario.ref.update({"timestamp": 1669152780000});
                    }
                  }
                },
                child: Text("converter"),
              ),*/
              FutureBuilder<DataSnapshot>(
                future: _comentarios,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    final List<DataSnapshot> comentariosListaRaw =
                        snapshot.requireData.child("comentarios").children.toList();
                    final int nComentarios = snapshot.data!.child("nComentarios").value as int;
                    if (nComentarios != 0) {
                      final List<ComentarioData> comentarios = [];
                      for (DataSnapshot e in comentariosListaRaw) {
                        ComentarioData comentarioConvertido = ComentarioData(
                          id: e.key!,
                          user: e.child("user").value as String,
                          content: e.child("content").value as String,
                          timestamp: e.child("timestamp").value as int,
                        );
                        comentarios.add(comentarioConvertido);
                      }

                      comentarios.sort((a, b) => b.timestamp.compareTo(a.timestamp));

                      return Expanded(
                        child: ListView(
                          children: comentarios.map((comentario) {
                            return Comentario(comentario.user, comentario.content, () {});
                          }).toList(),
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
