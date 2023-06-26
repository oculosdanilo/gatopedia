// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/main.dart';

import '../../home.dart';
import '../public_profile.dart';

class Comentarios extends StatefulWidget {
  final int post;

  const Comentarios(this.post, {super.key});

  @override
  State<Comentarios> createState() => _ComentariosState();
}

class _ComentariosState extends State<Comentarios> {
  String pedaco1 = "";
  String pedaco2 = "";
  bool flag = true;
  final txtComment = TextEditingController();

  _firebasePegar() async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    snapshot = await ref.get();
    if (mounted) {
      setState(() {});
    }
  }

  _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    ref.onValue.listen((event) {
      _firebasePegar();
    });
  }

  _postarC() async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/${widget.post}/comentarios");
    await ref.update({
      // ignore: unnecessary_null_comparison
      "${((snapshot?.value as List)[widget.post]["comentarios"] as List) != null ? ((snapshot?.value as List)[widget.post]["comentarios"] as List).length : 1}":
          {
        "username": username,
        "content": txtComment.text,
      },
    });
  }

  _deletarC(comment) {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/${widget.post}/comentarios");
    ref.update({"$comment": null});
  }

  _maisDe2Linhas(String text) {
    if (text.length > 30) {
      pedaco1 = text.substring(0, 30);
      pedaco2 = text.substring(30, text.length);
      return true;
    } else {
      pedaco1 = text;
      return false;
    }
  }

  @override
  void initState() {
    _atualizar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              padding: const EdgeInsets.all(10),
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
                              (snapshot?.value as List)[widget.post]
                                  ["username"],
                            ),
                          ),
                        );
                      },
                      child: Image(
                        image: listaTemImagem.contains((snapshot?.value
                                as List)[widget.post]["username"])
                            ? NetworkImage(
                                "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F${(snapshot?.value as List)[widget.post]["username"]}.webp?alt=media")
                            : AssetImage("lib/assets/user.webp")
                                as ImageProvider,
                        width: 30,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              SlideRightAgainRoute(
                                PublicProfile(
                                  (snapshot?.value as List)[widget.post]
                                      ["username"],
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "@${(snapshot?.value as List)[widget.post]["username"]}",
                            style: const TextStyle(
                              fontFamily: "Jost",
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            softWrap: true,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          _maisDe2Linhas(
                            (snapshot?.value as List)[widget.post]["content"],
                          )
                              ? flag
                                  ? "$pedaco1..."
                                  : pedaco1 + pedaco2
                              : pedaco1,
                          style: const TextStyle(
                            fontFamily: "Jost",
                            fontSize: 15,
                          ),
                          softWrap: true,
                          maxLines: 50,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                flag = !flag;
                              });
                            },
                            child: Text(
                              _maisDe2Linhas((snapshot?.value
                                      as List)[widget.post]["content"])
                                  ? flag
                                      ? "mostrar mais"
                                      : "mostrar menos"
                                  : "",
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 7,
                    child: TextField(
                      controller: txtComment,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Flexible(
                    flex: 5,
                    child: FilledButton(
                      onPressed: () async {
                        _postarC();
                        txtComment.text = "";
                        Flushbar(
                          message: "Postado com sucesso!",
                          duration: const Duration(seconds: 3),
                          margin: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(50),
                        ).show(context);
                      },
                      child: const Text("COMENTAR"),
                    ),
                  )
                ],
              ),
            ),
            ((snapshot?.value as List)[widget.post]["comentarios"] as List)
                        .length >
                    2
                ? Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return ((snapshot?.value as List)[widget.post]
                                        ["comentarios"] as List)[
                                    ((snapshot?.value as List)[widget.post]
                                                ["comentarios"] as List)
                                            .length -
                                        index -
                                        1] !=
                                null
                            ? Card(
                                margin:
                                    const EdgeInsets.fromLTRB(15, 10, 15, 5),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 25, 10, 25),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              SlideRightAgainRoute(
                                                PublicProfile(
                                                  (snapshot?.value
                                                          as List)[widget.post]
                                                      ["comentarios"][((snapshot
                                                                          ?.value
                                                                      as List)[
                                                                  widget.post][
                                                              "comentarios"] as List)
                                                          .length -
                                                      index -
                                                      1]["username"],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Image(
                                            image: listaTemImagem.contains(
                                                    (snapshot?.value as List)[widget.post]
                                                            ["comentarios"][
                                                        ((snapshot?.value as List)[widget.post]
                                                                        ["comentarios"]
                                                                    as List)
                                                                .length -
                                                            index -
                                                            1]["username"])
                                                ? NetworkImage(
                                                    "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F${(snapshot?.value as List)[widget.post]["comentarios"][((snapshot?.value as List)[widget.post]["comentarios"] as List).length - index - 1]["username"]}.webp?alt=media")
                                                : AssetImage("lib/assets/user.webp")
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                      (snapshot?.value as List)[
                                                              widget.post][
                                                          "comentarios"][((snapshot
                                                                              ?.value
                                                                          as List)[
                                                                      widget
                                                                          .post]
                                                                  ["comentarios"] as List)
                                                              .length -
                                                          index -
                                                          1]["username"],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                "@${(snapshot?.value as List)[widget.post]["comentarios"][((snapshot?.value as List)[widget.post]["comentarios"] as List).length - index - 1]["username"]}",
                                                style: const TextStyle(
                                                    fontFamily: "Jost",
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                                softWrap: true,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              "${(snapshot?.value as List)[widget.post]["comentarios"][((snapshot?.value as List)[widget.post]["comentarios"] as List).length - index - 1]["content"]}",
                                              style: const TextStyle(
                                                  fontFamily: "Jost",
                                                  fontSize: 15),
                                              softWrap: true,
                                              maxLines: 50,
                                            )
                                          ],
                                        ),
                                      ),
                                      "${(snapshot?.value as List)[widget.post]["comentarios"][((snapshot?.value as List)[widget.post]["comentarios"] as List).length - index - 1]["username"]}" ==
                                              username
                                          ? Ink(
                                              decoration: ShapeDecoration(
                                                color:
                                                    blueScheme.errorContainer,
                                                shape: const CircleBorder(),
                                              ),
                                              child: IconButton(
                                                icon: const Icon(Icons.delete),
                                                color: Colors.white,
                                                onPressed: () {
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                          (timeStamp) {
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (context) =>
                                                          AlertDialog(
                                                        icon: const Icon(
                                                          Icons.delete_rounded,
                                                        ),
                                                        title: const Text(
                                                          "Tem certeza que deseja deletar esse comentário?",
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        content: const Text(
                                                          "Ele sumirá para sempre! (muito tempo)",
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                              "CANCELAR",
                                                            ),
                                                          ),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              _deletarC(((snapshot?.value
                                                                              as List)[
                                                                          widget
                                                                              .post]["comentarios"] as List)
                                                                      .length -
                                                                  index -
                                                                  1);
                                                              Navigator.pop(
                                                                  context);
                                                              Flushbar(
                                                                message:
                                                                    "Excluído com sucesso!",
                                                                duration:
                                                                    const Duration(
                                                                        seconds:
                                                                            3),
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(20),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50),
                                                              ).show(
                                                                context,
                                                              );
                                                            },
                                                            child: const Text(
                                                              "OK",
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                                },
                                              ),
                                            )
                                          : const Row(),
                                    ],
                                  ),
                                ),
                              )
                            : Row();
                      },
                      itemCount: (snapshot?.value as List)[widget.post]
                                  ["comentarios"] !=
                              null
                          ? ((snapshot?.value as List)[widget.post]
                                      ["comentarios"] as List)
                                  .length -
                              2
                          : 0,
                    ),
                  )
                : SizedBox(
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
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
    );
  }
}
