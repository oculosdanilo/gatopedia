import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../config/config.dart';
import 'info.dart';
import '../../../main.dart';

final Uri _urlCList = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/commentListar.php');

class Wiki extends StatefulWidget {
  const Wiki({super.key});

  @override
  State<Wiki> createState() => _WikiState();
}

class _WikiState extends State<Wiki> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: gatoLista.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
          child: OpenContainer(
            closedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            transitionType: ContainerTransitionType.fade,
            transitionDuration: const Duration(milliseconds: 500),
            openBuilder: (context, _) => const GatoInfo(),
            closedElevation: 0,
            openColor: Theme.of(context).colorScheme.background,
            onClosed: (data) {},
            closedColor:
                dark ? const Color(0xff23232a) : const Color(0xfff5f2fb),
            closedBuilder: (context, VoidCallback openContainer) => SizedBox(
              height: 140,
              child: Card(
                shadowColor: Colors.transparent,
                margin: const EdgeInsets.all(0),
                child: InkWell(
                  onTap: () async {
                    indexClicado = index;
                    var map = <String, String>{};
                    int indexMais1 = indexClicado + 1;
                    map['id'] = "$indexMais1";
                    final response = await http.post(_urlCList, body: map);
                    cLista = jsonDecode(response.body);
                    cListaTamanho = cLista.length;
                    openContainer.call();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: FadeInImage(
                            width: 100,
                            placeholder:
                                const AssetImage('lib/assets/loading.gif'),
                            image: NetworkImage(gatoLista[index]["IMG"]),
                            fadeInDuration: const Duration(milliseconds: 300),
                            fadeOutDuration: const Duration(milliseconds: 300),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        SizedBox(
                          width: 200,
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
                                maxLines: 2,
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
    );
  }
}
