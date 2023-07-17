import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/home/config/config.dart';
import 'package:gatopedia/home/gatos/wiki/info.dart';
import 'package:gatopedia/main.dart';

late Future<DataSnapshot> _getData;
bool pegouInfo = false;

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
    if (!pegouInfo) {
      _getData = FirebaseDatabase.instance.ref().child("gatos").get();
      pegouInfo = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: FutureBuilder<DataSnapshot>(
        future: _getData,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(
                  top: -20,
                  child: ListView(
                    shrinkWrap: true,
                    children: snapshot.data!.children
                        .map<Widget>(
                          (e) => Container(
                            margin: EdgeInsets.fromLTRB(
                              15,
                              e == snapshot.data?.children.first ? 15 : 10,
                              15,
                              e == snapshot.data?.children.last ? 15 : 5,
                            ),
                            child: OpenContainer(
                              closedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              transitionType: ContainerTransitionType.fade,
                              transitionDuration:
                                  const Duration(milliseconds: 500),
                              openBuilder: (context, _) => GatoInfo(e),
                              closedElevation: 0,
                              tappable: false,
                              openColor:
                                  Theme.of(context).colorScheme.background,
                              closedColor: dark
                                  ? const Color(0xff23232a)
                                  : const Color(0xfff5f2fb),
                              closedBuilder: (
                                context,
                                VoidCallback openContainer,
                              ) =>
                                  SizedBox(
                                height: 130,
                                child: Card(
                                  shadowColor: Colors.transparent,
                                  margin: const EdgeInsets.all(0),
                                  child: InkWell(
                                    onTap: () => openContainer.call(),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 10, 0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            child: CachedNetworkImage(
                                              imageUrl: e
                                                  .child("img")
                                                  .value
                                                  .toString(),
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                "lib/assets/loading.gif",
                                              ),
                                              fadeInDuration: const Duration(
                                                  milliseconds: 150),
                                              fadeOutDuration: const Duration(
                                                  milliseconds: 150),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  e.key ?? "",
                                                  style: const TextStyle(
                                                      fontFamily: "Jost",
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 25),
                                                  softWrap: true,
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  e
                                                      .child("resumo")
                                                      .value
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontFamily: "Jost",
                                                      fontSize: 15),
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
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
