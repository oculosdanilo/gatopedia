import 'package:animations/animations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:gatopedia/telas/home/config/config.dart';
import 'package:gatopedia/telas/home/gatos/wiki/info.dart';
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
          Widget filho;
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            filho = ListView(
              shrinkWrap: true,
              controller: ScrollController(),
              children: username != null
                  ? snapshot.data!.children.map<Widget>((e) => gatoCard(e, snapshot, context)).toList()
                  : [
                      ...snapshot.data!.children.map<Widget>((e) => gatoCard(e, snapshot, context)),
                      const SizedBox(height: 100),
                    ],
            );
          } else {
            filho = const Center(child: CircularProgressIndicator());
          }

          return AnimatedSwitcher(
            duration: Duration(milliseconds: 500),
            child: filho,
          );
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
            ? Theme.of(context).colorScheme.surfaceContainerLow
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
                SizedBox(
                  width: 130,
                  height: 130,
                  child: BlurHash(
                    hash: e.child("img").value.toString().split("&")[1],
                    image:
                        "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/gatos%2F${e.child("img").value.toString().split("&")[0]}.webp?alt=media",
                    decodingWidth: 130,
                    decodingHeight: 130,
                    duration: const Duration(milliseconds: 150),
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                ),
                /*CachedNetworkImage(
                  imageUrl:
                      "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/gatos%2F${e.child("img").value.toString().split("&")[0]}.webp?alt=media",
                  placeholder: (context, url) => AspectRatio(
                    aspectRatio: 1 / 1,
                    child: BlurHash(hash: e.child("img").value.toString().split("&")[1]),
                  ),
                  fadeInDuration: const Duration(milliseconds: 150),
                  fadeOutDuration: const Duration(milliseconds: 150),
                  width: 130,
                  height: 130,
                ),*/
                const SizedBox(width: 15),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        e.key ?? "",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                        softWrap: true,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        e.child("resumo").value.toString(),
                        style: const TextStyle(fontSize: 15),
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
