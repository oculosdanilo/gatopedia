import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/home/config/config.dart';
import 'package:gatopedia/home/gatos/wiki/info.dart';
import 'package:gatopedia/main.dart';
import 'package:grayscale/grayscale.dart';

late Future<DataSnapshot> _getData;
bool pegouInfo = false;

class Wiki extends StatefulWidget {
  const Wiki({super.key});

  @override
  State<Wiki> createState() => _WikiState();
}

class _WikiState extends State<Wiki> {
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
    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: FutureBuilder<DataSnapshot>(
        future: _getData,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(
                  top: username != null ? -40 : 0,
                  child: ListView(
                    shrinkWrap: true,
                    controller: ScrollController(),
                    children: username != null
                        ? snapshot.data!.children
                            .map<Widget>(
                              (e) => gatoCard(e, snapshot, context),
                            )
                            .toList()
                        : [
                            ...snapshot.data!.children.map<Widget>(
                              (e) => gatoCard(e, snapshot, context),
                            ),
                            const SizedBox(height: 100),
                          ],
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

  Container gatoCard(DataSnapshot e, AsyncSnapshot<DataSnapshot> snapshot, BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
          15, e == snapshot.data?.children.first ? 15 : 10, 15, e == snapshot.data?.children.last ? 15 : 5),
      child: OpenContainer(
        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        transitionType: ContainerTransitionType.fade,
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, _) => username != null
            ? GatoInfo(e)
            : Theme(
                data: ThemeData.from(
                    colorScheme: GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light)),
                child: GatoInfo(e),
              ),
        closedElevation: 0,
        tappable: false,
        openColor: username != null
            ? Theme.of(context).colorScheme.surface
            : GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light).surface,
        closedColor: username != null
            ? dark
                ? const Color(0xff23232a)
                : const Color(0xfff5f2fb)
            : GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light).surface,
        closedBuilder: (
          context,
          VoidCallback openContainer,
        ) =>
            gatoCardContainer(context, openContainer, e),
      ),
    );
  }

  SizedBox gatoCardContainer(BuildContext context, VoidCallback openContainer, DataSnapshot e) {
    return SizedBox(
      height: 130,
      child: Card(
        shadowColor: Colors.transparent,
        color: username == null
            ? Theme.of(context).colorScheme.surfaceTint.withOpacity(dark ? 0.25 : 0.1)
            : Theme.of(context).colorScheme.surfaceContainerLow,
        margin: const EdgeInsets.all(0),
        child: InkWell(
          onTap: () => openContainer.call(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  child: CachedNetworkImage(
                    imageUrl:
                        "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/gatos%2F${e.child("img").value.toString().split("&")[0]}.webp?alt=media",
                    placeholder: (context, url) => Image.asset(
                      "assets/anim/loading.gif",
                    ),
                    fadeInDuration: const Duration(milliseconds: 150),
                    fadeOutDuration: const Duration(milliseconds: 150),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        e.key ?? "",
                        style: const TextStyle(fontFamily: "Jost", fontWeight: FontWeight.bold, fontSize: 25),
                        softWrap: true,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        e.child("resumo").value.toString(),
                        style: const TextStyle(fontFamily: "Jost", fontSize: 15),
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
    );
  }
}
