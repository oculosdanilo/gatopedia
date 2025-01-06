import 'package:animations/animations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/gatos/gatos.dart';
import 'package:gatopedia/telas/home/gatos/wiki/info.dart';
import 'package:gatopedia/telas/index.dart';
import 'package:grayscale/grayscale.dart';

late Future<DataSnapshot> _getData;
bool pegouInfo = false;

class Wiki extends StatefulWidget {
  final ScrollController scrollWiki;
  final void Function() setStateGatos;
  final AnimationController animController;
  final Animation<double> anim;
  final EdgeInsets pd;

  const Wiki(this.scrollWiki, this.setStateGatos, this.animController, this.anim, this.pd, {super.key});

  @override
  State<Wiki> createState() => _WikiState();
}

double scrollSalvoWiki = 0;
double scrollAcumuladoWiki = 0;

class _WikiState extends State<Wiki> {
  void _barHideListen() {
    scrollAcumuladoWiki = 0;
    widget.setStateGatos();

    widget.scrollWiki.position.isScrollingNotifier.addListener(() {
      double off = widget.scrollWiki.offset;
      if (!widget.scrollWiki.position.isScrollingNotifier.value) {
        if ((scrollAcumuladoWiki < 0 && !expandido) || (scrollAcumuladoWiki > 0 && expandido)) {
          offsetInicial = off;
        }
      }
    });

    widget.scrollWiki.addListener(() {
      double off = widget.scrollWiki.offset;
      scrollSalvoWiki = off;
      scrollAcumuladoWiki = offsetInicial - off;

      if (scrollAcumuladoWiki > (kToolbarHeight * 2.86) / 2 && !expandido) {
        if (!mounted) return;
        setState(() {
          expandido = true;
          offsetInicial = off;

          widget.animController.reverse();
        });
        widget.setStateGatos();
      } else if (scrollAcumuladoWiki < -(kToolbarHeight * 2.86) / 2 && expandido) {
        if (!mounted) return;
        setState(() {
          expandido = false;
          offsetInicial = off;

          widget.animController.forward();
        });
        widget.setStateGatos();
      }
    });
  }

  late double offsetInicial = widget.scrollWiki.offset;

  @override
  void initState() {
    super.initState();
    tabIndex = 0;
    if (!pegouInfo) {
      _getData = FirebaseDatabase.instance.ref().child("gatos").get();
      pegouInfo = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!expandido && scrollSalvoWiki < ((kToolbarHeight * 2.86) / 2)) {
        setState(() {
          expandido = true;

          widget.animController.reverse();
        });
      }
    });
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
            filho = ListView.builder(
              controller: widget.scrollWiki,
              itemBuilder: (context, index) {
                if (!_comecouListen) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    widget.scrollWiki.jumpTo(scrollSalvoWiki);
                    _barHideListen();
                    _comecouListen = true;
                  });
                }
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

  bool _comecouListen = false;
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
        closedColor: username != null
            ? Theme.of(context).colorScheme.surfaceContainerLow
            : GrayColorScheme.highContrastGray(
                    App.themeNotifier.value == ThemeMode.dark ? Brightness.dark : Brightness.light)
                .surface,
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
