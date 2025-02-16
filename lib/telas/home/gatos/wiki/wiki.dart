import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/gatos/gatos.dart';
import 'package:gatopedia/telas/home/gatos/wiki/info.dart';
import 'package:gatopedia/telas/index.dart';

class Wiki extends StatefulWidget {
  final ScrollController scrollWiki;
  final AnimationController animController;
  final EdgeInsets pd;

  const Wiki(this.scrollWiki, this.animController, this.pd, {super.key});

  @override
  State<Wiki> createState() => _WikiState();
}

double scrollSalvoWiki = 0;
double scrollAcumuladoWiki = 0;

class _WikiState extends State<Wiki> with AutomaticKeepAliveClientMixin {
  late Future<DataSnapshot> _getData;
  bool pegouInfo = false;

  @override
  void initState() {
    super.initState();
    tabIndex = 0;
    if (!pegouInfo) {
      _getData = FirebaseDatabase.instance.ref().child("gatos").get();
      pegouInfo = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: FutureBuilder<DataSnapshot>(
        future: _getData,
        builder: (context, snapshot) {
          Widget filho;
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            filho = ListView.builder(
              controller: widget.scrollWiki,
              itemBuilder: (context, index) {
                return username == null && index == 10
                    ? SizedBox(height: 80 + MediaQuery.paddingOf(context).bottom)
                    : GatoCard(index, snapshot.data!.children.toList()[index], widget.pd);
              },
              itemCount: snapshot.data!.children.length + (username != null ? 0 : 1),
            );
          } else {
            filho = const Center(child: CircularProgressIndicator());
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: filho,
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

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
                      ? BlurHash(
                          hash: e.child("img").value.toString().split("&")[1],
                          image:
                              "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/gatos%2F${e.child("img").value.toString().split("&")[0]}.webp?alt=media",
                          decodingWidth: 130,
                          decodingHeight: 130,
                          duration: const Duration(milliseconds: 150),
                          color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                        e?.key ?? "Teste",
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
