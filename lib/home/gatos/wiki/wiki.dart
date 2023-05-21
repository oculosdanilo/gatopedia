import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/config.dart';
import 'info.dart';
import '../../../main.dart';

final Uri _urlCList = Uri.parse(
  'http://etec199-2023-danilolima.atwebpages.com/2022/1103/commentListar.php',
);
bool clicavel = true;

class Wiki extends StatefulWidget {
  const Wiki({super.key});

  @override
  State<Wiki> createState() => _WikiState();
}

class _WikiState extends State<Wiki> with AutomaticKeepAliveClientMixin {
  pegarImagens() async {
    await Firebase.initializeApp();
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users/");
    DataSnapshot userinfo = await ref.get();
    int i = 0;
    while (i < userinfo.children.length) {
      if (((userinfo.children).toList()[i].value as Map)["img"] != null) {
        setState(() {
          listaTemImagem.add(
            "${(userinfo.children.map((i) => i)).toList()[i].key}",
          );
        });
      } else {
        setState(() {
          listaTemImagem.remove(
            "${(userinfo.children.map((i) => i)).toList()[i].key}",
          );
        });
      }
      i++;
    }
    debugPrint("$listaTemImagem");
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: ListView.builder(
        itemCount: gatoLista.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.fromLTRB(
              15,
              index == 0 ? 15 : 10,
              15,
              index == 9 ? 15 : 5,
            ),
            child: OpenContainer(
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              transitionType: ContainerTransitionType.fade,
              transitionDuration: const Duration(milliseconds: 500),
              openBuilder: (context, _) => const GatoInfo(),
              closedElevation: 0,
              tappable: clicavel,
              openColor: Theme.of(context).colorScheme.background,
              onClosed: (data) {
                setState(() {
                  clicavel = true;
                });
              },
              closedColor:
                  dark ? const Color(0xff23232a) : const Color(0xfff5f2fb),
              closedBuilder: (context, VoidCallback openContainer) => SizedBox(
                height: 130,
                child: Card(
                  shadowColor: Colors.transparent,
                  margin: const EdgeInsets.all(0),
                  child: InkWell(
                    onTap: clicavel
                        ? () async {
                            setState(() {
                              clicavel = false;
                            });
                            indexClicado = index;
                            var map = <String, String>{};
                            int indexMais1 = indexClicado + 1;
                            map['id'] = "$indexMais1";
                            final response =
                                await http.post(_urlCList, body: map);
                            cLista = jsonDecode(response.body);
                            cListaTamanho = cLista.length;
                            openContainer.call();
                          }
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            child: CachedNetworkImage(
                              imageUrl: gatoLista[index]["IMG"],
                              placeholder: (context, url) =>
                                  Image.asset("lib/assets/loading.gif"),
                              fadeInDuration: const Duration(milliseconds: 150),
                              fadeOutDuration:
                                  const Duration(milliseconds: 150),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  gatoLista[index]["NOME"],
                                  style: const TextStyle(
                                      fontFamily: "Jost",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25),
                                  softWrap: true,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  gatoLista[index]["RESUMO"],
                                  style: const TextStyle(
                                      fontFamily: "Jost", fontSize: 15),
                                  softWrap: true,
                                  maxLines: 3,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
