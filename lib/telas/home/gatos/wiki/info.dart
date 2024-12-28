import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:gatopedia/components/comentario.dart';
import 'package:gatopedia/main.dart';

late Future<DataSnapshot> _getData;

class GatoInfo extends StatefulWidget {
  final DataSnapshot gatoInfo;

  const GatoInfo(this.gatoInfo, {super.key});

  @override
  GatoInfoState createState() {
    return GatoInfoState();
  }
}

class GatoInfoState extends State<GatoInfo> {
  final txtControllerC = TextEditingController();
  bool mandando = false;

  late String img = widget.gatoInfo.child("img").value.toString();
  late String titulo = widget.gatoInfo.key!;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => FocusManager.instance.primaryFocus?.unfocus()),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              iconTheme:
                  const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 20)]),
              expandedHeight: 360,
              pinned: true,
              backgroundColor: !dark ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 2,
                title: Text(titulo, style: const TextStyle(color: Colors.white)),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).width,
                      child: BlurHash(
                        hash: img.split("&")[1],
                        image:
                            "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/gatos%2F${img.split("&")[0]}.webp?alt=media",
                        duration: const Duration(milliseconds: 150),
                        color: Theme.of(context).colorScheme.surface,
                        imageFit: BoxFit.cover,
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, 0.5),
                          end: Alignment.center,
                          colors: [Color(0x60000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList.list(
              children: [
                StretchingOverscrollIndicator(
                  axisDirection: AxisDirection.up,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              "${widget.gatoInfo.child("resumo").value}",
                              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 28),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "${widget.gatoInfo.child("descricao").value}".replaceAll("\\n", "\n"),
                              style: const TextStyle(fontSize: 20),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              "COMENTÁRIOS",
                              style: TextStyle(fontVariations: [FontVariation("wght", 600)], fontSize: 25),
                            ),
                          ],
                        ),
                      ),
                      username != null
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    flex: 7,
                                    child: TextField(
                                      controller: txtControllerC,
                                      enabled: !mandando,
                                      decoration:
                                          const InputDecoration(hintText: "Comentar...", prefix: SizedBox(width: 10)),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton.filled(
                                    onPressed: !mandando
                                        ? () async {
                                            FocusManager.instance.primaryFocus?.unfocus();
                                            if (txtControllerC.text != "") {
                                              setState(() => mandando = true);
                                              await _getData.then((value) async {
                                                await value.ref
                                                    .child("${int.parse(value.children.last.key!) + 1}")
                                                    .update({"user": username, "content": txtControllerC.text});
                                              });
                                              setState(() {
                                                _getData = FirebaseDatabase.instance
                                                    .ref("gatos/${widget.gatoInfo.key}/comentarios")
                                                    .get();
                                              });
                                              if (!context.mounted) return;
                                              Flushbar(
                                                message: "Postado com sucesso!",
                                                duration: const Duration(seconds: 2),
                                                margin: const EdgeInsets.all(20),
                                                borderRadius: BorderRadius.circular(50),
                                              ).show(context);
                                              txtControllerC.text = "";
                                              setState(() => mandando = false);
                                            }
                                          }
                                        : null,
                                    icon: const Icon(Icons.send_rounded),
                                    iconSize: 25,
                                    padding: const EdgeInsets.all(15),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
                      widget.gatoInfo.child("comentarios").children.length > 2
                          ? ComentariosWiki(widget.gatoInfo)
                          : const SizedBox(
                              height: 80,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [Text("Nenhum comentário (ainda...)")],
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 25))
          ],
        ),
      ),
    );
  }
}

class ComentariosWiki extends StatefulWidget {
  final DataSnapshot gatoInfo;

  const ComentariosWiki(this.gatoInfo, {super.key});

  @override
  State<ComentariosWiki> createState() => _ComentariosWikiState();
}

class _ComentariosWikiState extends State<ComentariosWiki> {
  @override
  void initState() {
    super.initState();
    _getData = FirebaseDatabase.instance.ref().child("gatos/${widget.gatoInfo.key}/comentarios").get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataSnapshot>(
      future: _getData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final comentarioSS = snapshot.data!;
          return Transform.translate(
            offset: Offset(0, username != null ? -25 : -50),
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              reverse: true,
              children: comentarioSS.children
                  .map<Widget>(
                    (e) => e.value != "null"
                        ? Comentario(int.parse(e.key!), e.child("user").value as String,
                            e.child("content").value as String, deletarC,
                            key: Key(
                                "${int.parse(e.key!)}${e.child("user").value as String}${e.child("content").value as String}"))
                        : const SizedBox(),
                  )
                  .toList(),
            ),
          );
        } else {
          return Transform.translate(
            offset: Offset(0, username == null ? 60 : 50),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  deletarC(int index) {
    FirebaseDatabase.instance.ref("gatos/${widget.gatoInfo.key}/comentarios/$index").remove();
    setState(() {
      _getData = FirebaseDatabase.instance.ref("gatos/${widget.gatoInfo.key}/comentarios").get();
    });
  }

/*Card comentario(
    BuildContext context,
    DataSnapshot snapshot,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: username == null && dark
          ? Theme.of(context).colorScheme.surfaceTint.withOpacity(0.25)
          : Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    SlideRightAgainRoute(PublicProfile(snapshot.child("user").value.toString())),
                  );
                },
                child: Image(
                  image: NetworkImage(
                      "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F${snapshot.child("user").value.toString()}.webp?alt=media"),
                  errorBuilder: (c, obj, stacktrace) => Image.asset("assets/user.webp", width: 50),
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideRightAgainRoute(
                          PublicProfile(
                            snapshot.child("user").value.toString(),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      snapshot.child("user").value.toString(),
                      style: const TextStyle(
                        fontFamily: "Jost",
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    snapshot.child("content").value.toString(),
                    style: const TextStyle(
                      fontFamily: "Jost",
                      fontSize: 15,
                    ),
                    softWrap: true,
                    maxLines: 50,
                  )
                ],
              ),
            ),
            snapshot.child("user").value.toString() == username
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.white,
                    style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(blueScheme.errorContainer)),
                    onPressed: () async {
                      var dialogo = await showCupertinoDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            icon: Icon(Icons.delete_rounded, color: Theme.of(context).colorScheme.error),
                            title: const Text(
                              "Tem certeza que deseja deletar esse comentário?",
                              textAlign: TextAlign.center,
                            ),
                            content: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text("Ele sumirá para sempre! (muito tempo)")],
                            ),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCELAR')),
                              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
                            ],
                          );
                        },
                      );
                      if (dialogo) {
                        await FirebaseDatabase.instance
                            .ref()
                            .child("gatos/${widget.gatoInfo.key}/comentarios/${snapshot.key}")
                            .remove();
                        setState(() {
                          _getData = FirebaseDatabase.instance.ref("gatos/${widget.gatoInfo.key}/comentarios").get();
                        });
                        if (!context.mounted) return;
                        Flushbar(
                          message: "Removido com sucesso!",
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(50),
                        ).show(context);
                      }
                    },
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }*/
}
