import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/home/gatos/public_profile.dart';
import 'package:gatopedia/home/home.dart';
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

  pegarImagens() async {
    await Firebase.initializeApp();
    DatabaseReference ref = FirebaseDatabase.instance.ref("users/");
    DataSnapshot userinfo = await ref.get();
    int i = 0;
    while (i < userinfo.children.length) {
      if (((userinfo.children).toList()[i].value as Map)["img"] != null) {
        if (!listaTemImagem
            .contains("${(userinfo.children.map((i) => i)).toList()[i].key}")) {
          setState(() {
            listaTemImagem.add(
              "${(userinfo.children.map((i) => i)).toList()[i].key}",
            );
          });
        }
      } else {
        setState(() {
          listaTemImagem.remove(
            "${(userinfo.children.map((i) => i)).toList()[i].key}",
          );
        });
      }
      i++;
    }
  }

  @override
  void initState() {
    pegarImagens();
    _getData = FirebaseDatabase.instance
        .ref("gatos/${widget.gatoInfo.key}/comentarios")
        .get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        scrollBehavior: MyBehavior(),
        slivers: [
          SliverAppBar.large(
            iconTheme: const IconThemeData(
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 20,
                ),
              ],
            ),
            expandedHeight: 360,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 2,
              title: Text(
                widget.gatoInfo.key ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Jost",
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.gatoInfo.child("img").value.toString(),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      "lib/assets/loading.gif",
                      fit: BoxFit.cover,
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.0, 0.5),
                        end: Alignment.center,
                        colors: <Color>[
                          Color(0x60000000),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    widget.gatoInfo.child("resumo").value.toString(),
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 27,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    widget.gatoInfo
                        .child("descricao")
                        .value
                        .toString()
                        .replaceAll("\\n", "\n"),
                    style: const TextStyle(
                      fontFamily: "Jost",
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "COMENTÁRIOS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Jost",
                      fontSize: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 25, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 7,
                    child: TextField(
                      controller: txtControllerC,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton.filled(
                    onPressed: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (txtControllerC.text != "") {
                        await _getData.then((value) async {
                          await value.ref
                              .child(
                            "${int.parse(value.children.last.key!) + 1}",
                          )
                              .update({
                            "user": username,
                            "content": txtControllerC.text,
                          });
                        });
                        setState(() {
                          _getData = FirebaseDatabase.instance
                              .ref("gatos/${widget.gatoInfo.key}/comentarios")
                              .get();
                        });
                        if (!mounted) return;
                        Flushbar(
                          message: "Postado com sucesso!",
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(50),
                        ).show(context);
                        txtControllerC.text = "";
                      }
                    },
                    icon: const Icon(Icons.send),
                    iconSize: 35,
                  ),
                ],
              ),
            ),
          ),
          widget.gatoInfo.child("comentarios").children.length > 2
              ? Comentarios(widget.gatoInfo)
              : const SliverToBoxAdapter(
                  child: SizedBox(
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
                ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 25,
            ),
          )
        ],
      ),
    );
  }
}

class Comentarios extends StatefulWidget {
  final DataSnapshot gatoInfo;
  const Comentarios(this.gatoInfo, {super.key});

  @override
  State<Comentarios> createState() => _ComentariosState();
}

class _ComentariosState extends State<Comentarios> {
  @override
  void initState() {
    _getData = FirebaseDatabase.instance
        .ref()
        .child("gatos/${widget.gatoInfo.key}/comentarios")
        .get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: FutureBuilder<DataSnapshot>(
        future: _getData,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: int.parse(snapshot.data!.children.last.key!) - 1,
              itemBuilder: (context, index) {
                if ((snapshot.data!.value as List)[
                        (snapshot.data!.value as List).length - index - 1] !=
                    null) {
                  return comentario(context, snapshot, index);
                } else {
                  return const Row();
                }
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Card comentario(
    BuildContext context,
    AsyncSnapshot<DataSnapshot> snapshot,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    SlideRightAgainRoute(
                      PublicProfile(
                        (snapshot.data!.value as List)[
                                (snapshot.data!.value as List).length -
                                    index -
                                    1]["user"]
                            .toString(),
                      ),
                    ),
                  );
                },
                child: Image(
                  image: listaTemImagem.contains((snapshot.data!.value as List)[
                              (snapshot.data!.value as List).length -
                                  index -
                                  1]["user"]
                          .toString())
                      ? NetworkImage(
                          "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F${(snapshot.data!.value as List)[(snapshot.data!.value as List).length - index - 1]["user"].toString()}.webp?alt=media",
                        )
                      : const AssetImage("lib/assets/user.webp")
                          as ImageProvider,
                  width: 50,
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              flex: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideRightAgainRoute(
                          PublicProfile(
                            (snapshot.data!.value as List)[
                                    (snapshot.data!.value as List).length -
                                        index -
                                        1]["user"]
                                .toString(),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      (snapshot.data!.value as List)[
                              (snapshot.data!.value as List).length -
                                  index -
                                  1]["user"]
                          .toString(),
                      style: const TextStyle(
                        fontFamily: "Jost",
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    (snapshot.data!.value as List)[
                            (snapshot.data!.value as List).length -
                                index -
                                1]["content"]
                        .toString(),
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
            (snapshot.data!.value as List)[
                            (snapshot.data!.value as List).length -
                                index -
                                1]["user"]
                        .toString() ==
                    username
                ? IconButton(
                    icon: const Icon(Icons.delete),
                    color: Colors.white,
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        blueScheme.errorContainer,
                      ),
                    ),
                    onPressed: () async {
                      var dialogo = await showCupertinoDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            icon: const Icon(
                              Icons.delete_rounded,
                            ),
                            title: const Text(
                              "Tem certeza que deseja deletar esse comentário?",
                            ),
                            content: const Text(
                              "Ele sumirá para sempre! (muito tempo)",
                              style: TextStyle(fontSize: 15),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(
                                  context,
                                  false,
                                ),
                                child: const Text('CANCELAR'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(
                                  context,
                                  true,
                                ),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                      if (dialogo) {
                        await FirebaseDatabase.instance
                            .ref()
                            .child(
                                "gatos/${widget.gatoInfo.key}/comentarios/${(snapshot.data!.value as List).length - index - 1}")
                            .remove();
                        setState(() {
                          _getData = FirebaseDatabase.instance
                              .ref("gatos/${widget.gatoInfo.key}/comentarios")
                              .get();
                        });
                        if (!mounted) return;
                        Flushbar(
                          message: "Removido com sucesso!",
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(50),
                        ).show(context);
                      }
                    },
                  )
                : const Text(""),
          ],
        ),
      ),
    );
  }
}
