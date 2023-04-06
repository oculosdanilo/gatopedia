// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gatopedia/main.dart';

final Uri _urlCAdd = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/commentAdd.php');
final Uri _urlCDelete = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/commentDelete.php');
final Uri _urlCList = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/commentListar.php');

class GatoInfo extends StatefulWidget {
  const GatoInfo({super.key});

  @override
  GatoInfoState createState() {
    return GatoInfoState();
  }
}

class GatoInfoState extends State {
  final txtControllerC = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (cLista.isNotEmpty) {
      return Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar.large(
            iconTheme: const IconThemeData(color: Colors.white, shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 1,
              ),
            ]),
            expandedHeight: 360,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 2,
              title: Text(
                gatoLista[indexClicado]["NOME"],
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Jost",
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: NetworkImage(gatoLista[indexClicado]["IMG"]),
                    fit: BoxFit.cover,
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
                    gatoLista[indexClicado]["RESUMO"],
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
                    gatoLista[indexClicado]["DESC"],
                    style: const TextStyle(
                      fontFamily: "Jost",
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "COMENTÁRIOS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Jost",
                        fontSize: 25),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
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
                      Flexible(
                        flex: 5,
                        child: FilledButton(
                          onPressed: () async {
                            if (txtControllerC.text != "") {
                              var map = <String, String>{};
                              map['id'] = "${indexClicado + 1}";
                              map['username'] = username;
                              map['comentario'] = txtControllerC.text;
                              final response =
                                  await http.post(_urlCAdd, body: map);

                              Flushbar(
                                message: response.body,
                                duration: const Duration(seconds: 2),
                                margin: const EdgeInsets.all(20),
                                borderRadius: BorderRadius.circular(50),
                              ).show(context);

                              txtControllerC.text = "";
                              var mapUp = <String, String>{};
                              int indexMais1 = indexClicado + 1;
                              mapUp['id'] = "$indexMais1";
                              final responseUp =
                                  await http.post(_urlCList, body: mapUp);
                              cLista = jsonDecode(responseUp.body);
                              cListaTamanho = cLista.length;
                              setState(() {});
                            }
                          },
                          child: const Text("COMENTAR"),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Card(
                  margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: const Image(
                            image: AssetImage("lib/assets/user.webp"),
                            width: 50,
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
                              Text(
                                '@${cLista[index]["USERNAME"]}',
                                style: const TextStyle(
                                    fontFamily: "Jost",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                                softWrap: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                cLista[index]["COMENTARIO"],
                                style: const TextStyle(
                                    fontFamily: "Jost", fontSize: 15),
                                softWrap: true,
                                maxLines: 50,
                              )
                            ],
                          ),
                        ),
                        cLista[index]["USERNAME"] == username
                            ? IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.white,
                                style: ButtonStyle(
                                  backgroundColor: MaterialStatePropertyAll(
                                    Theme.of(context)
                                        .colorScheme
                                        .errorContainer,
                                  ),
                                ),
                                onPressed: () async {
                                  var dialogo = await showDialog(
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
                                    final map = <String, String>{};
                                    map['id'] = cLista[index]["ID"];
                                    final response = await http.post(
                                      _urlCDelete,
                                      body: map,
                                    );

                                    Flushbar(
                                      message: response.body,
                                      duration: const Duration(seconds: 2),
                                      margin: const EdgeInsets.all(20),
                                      borderRadius: BorderRadius.circular(50),
                                    ).show(context);

                                    var mapUp = <String, String>{};
                                    int indexMais1 = indexClicado + 1;
                                    mapUp['id'] = "$indexMais1";
                                    final responseUp =
                                        await http.post(_urlCList, body: mapUp);
                                    cLista = jsonDecode(responseUp.body);
                                    cListaTamanho = cLista.length;
                                    setState(() {});
                                  }
                                },
                              )
                            : const Text(""),
                      ],
                    ),
                  ),
                );
              },
              childCount: cListaTamanho,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 25,
            ),
          )
        ]),
      );
    } else {
      return Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar.large(
            iconTheme: const IconThemeData(color: Colors.white, shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 1,
              )
            ]),
            expandedHeight: 360,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                gatoLista[indexClicado]["NOME"],
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Jost",
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: NetworkImage(gatoLista[indexClicado]["IMG"]),
                    fit: BoxFit.cover,
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
                    gatoLista[indexClicado]["RESUMO"],
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
                    gatoLista[indexClicado]["DESC"],
                    style: const TextStyle(
                      fontFamily: "Jost",
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "COMENTÁRIOS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Jost",
                        fontSize: 25),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
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
                      Flexible(
                        flex: 5,
                        child: FilledButton(
                          onPressed: () async {
                            if (txtControllerC.text != "") {
                              var map = <String, String>{};
                              map['id'] = "${indexClicado + 1}";
                              map['username'] = username;
                              map['comentario'] = txtControllerC.text;
                              final response =
                                  await http.post(_urlCAdd, body: map);

                              Flushbar(
                                message: response.body,
                                duration: const Duration(seconds: 2),
                                margin: const EdgeInsets.all(20),
                                borderRadius: BorderRadius.circular(50),
                              ).show(context);

                              txtControllerC.text = "";
                              var mapUp = <String, String>{};
                              int indexMais1 = indexClicado + 1;
                              mapUp['id'] = "$indexMais1";
                              final responseUp =
                                  await http.post(_urlCList, body: mapUp);
                              cLista = jsonDecode(responseUp.body);
                              cListaTamanho = cLista.length;
                              setState(() {});
                            }
                          },
                          child: const Text("COMENTAR"),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
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
                const SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ]),
      );
    }
  }
}
