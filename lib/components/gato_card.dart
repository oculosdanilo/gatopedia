import 'package:animations/animations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/gatos/wiki/info.dart';
import 'package:gatopedia/telas/index.dart';

class GatoCard extends StatefulWidget {
  final int index;
  final DataSnapshot? e;
  final EdgeInsets pd;

  const GatoCard(this.index, this.e, this.pd, {super.key});

  @override
  State<GatoCard> createState() => _GatoCardState();
}

class _GatoCardState extends State<GatoCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        15,
        widget.index == 0 ? (kToolbarHeight * 2.86) + 15 : 10,
        15,
        widget.index == 9 ? 5 + widget.pd.bottom : 5,
      ),
      child: OpenContainer(
        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        transitionDuration: const Duration(milliseconds: 500),
        openBuilder: (context, _) => username != null
            ? GatoInfo(widget.e!, widget.pd)
            : Theme(
                data: ThemeData.from(
                  colorScheme: temaBaseBW(App.themeNotifier.value, context).colorScheme,
                  textTheme: temaBaseBW(App.themeNotifier.value, context).textTheme.apply(fontFamily: "Jost"),
                ),
                child: GatoInfo(widget.e!, widget.pd),
              ),
        closedElevation: 0,
        tappable: false,
        openColor: username != null
            ? Theme.of(context).colorScheme.surface
            : temaBaseBW(App.themeNotifier.value, context).colorScheme.surface,
        closedColor: username != null ? Theme.of(context).colorScheme.surfaceContainerLow : Colors.transparent,
        closedBuilder: (
          context,
          VoidCallback openContainer,
        ) =>
            gatoCardContainer(context, openContainer, widget.e),
      ),
    );
  }

  SizedBox gatoCardContainer(BuildContext context, VoidCallback openContainer, DataSnapshot? e) {
    return SizedBox(
      height: 130,
      child: Card(
        shadowColor: Colors.transparent,
        color: username == null
            ? temaBaseBW(App.themeNotifier.value, context)
                .colorScheme
                .surfaceTint
                .withValues(alpha: _isDark(context) ? 0.25 : 0.1)
            : Theme.of(context).colorScheme.surfaceContainerLow,
        margin: const EdgeInsets.all(0),
        child: InkWell(
          onTap: e != null ? () => openContainer.call() : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: e != null
                      ? FadeInImage(
                          image: NetworkImage(
                              "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/gatos%2F${e.child("img").value.toString().split("&")[0]}.webp?alt=media"),
                          placeholder: BlurHashImage(e.child("img").value.toString().split("&")[1],
                              decodingHeight: 130, decodingWidth: 130),
                          fadeInDuration: const Duration(milliseconds: 150),
                          fadeOutDuration: const Duration(milliseconds: 1),
                          width: 130,
                          height: 130,
                        )
                      : null,
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "${e?.child("nome").value}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                        softWrap: true,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${e?.child("resumo").value}",
                        style: const TextStyle(fontSize: 16),
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

  bool _isDark(BuildContext context) {
    if (App.themeNotifier.value == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    } else {
      return App.themeNotifier.value == ThemeMode.dark;
    }
  }
}
