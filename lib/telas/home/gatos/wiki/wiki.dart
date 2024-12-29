import 'package:animations/animations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/gatos/forum/forum.dart';
import 'package:gatopedia/telas/home/gatos/gatos.dart';
import 'package:gatopedia/telas/home/gatos/wiki/info.dart';
import 'package:grayscale/grayscale.dart';

late Future<DataSnapshot> _getData;
bool pegouInfo = false;

class Wiki extends StatefulWidget {
  final ScrollController scrollWiki;
  final void Function() setStateGatos;
  final AnimationController animController;
  final Animation<double> anim;

  const Wiki(this.scrollWiki, this.setStateGatos, this.animController, this.anim, {super.key});

  @override
  State<Wiki> createState() => _WikiState();
}

class _WikiState extends State<Wiki> {
  void _barHideListen() {
    scrollAcumulado = 0;
    widget.setStateGatos();

    widget.scrollWiki.position.isScrollingNotifier.addListener(() {
      double off = widget.scrollWiki.offset;
      if (!widget.scrollWiki.position.isScrollingNotifier.value) {
        if ((scrollAcumulado < 0 && !expandido) || (scrollAcumulado > 0 && expandido)) {
          offsetInicial = off;
        }
      }
    });

    widget.scrollWiki.addListener(() {
      double off = widget.scrollWiki.offset;
      scrollAcumulado = offsetInicial - off;

      if (scrollAcumulado > (kToolbarHeight * 2.86) / 2 && !expandido) {
        if (!mounted) return;
        setState(() {
          expandido = true;
          offsetInicial = off;

          widget.animController.reverse();
        });
        widget.setStateGatos();
      } else if (scrollAcumulado < (-(kToolbarHeight * 2.86) / 2) && expandido) {
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

  @override
  void initState() {
    super.initState();
    tabIndex = 0;
    if (!pegouInfo) {
      _getData = FirebaseDatabase.instance.ref().child("gatos").get();
      pegouInfo = true;
    }
  }

  late double offsetInicial = widget.scrollWiki.offset;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.anim,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.only(
            top: (kToolbarHeight * 2.86) - (widget.anim.value * ((kToolbarHeight * 2.86) / 2)),
          ),
          child: child,
        );
      },
      child: StretchingOverscrollIndicator(
        axisDirection: AxisDirection.down,
        child: FutureBuilder<DataSnapshot>(
          future: _getData,
          builder: (context, snapshot) {
            Widget filho;
            if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
              /*filho = ListView(
                shrinkWrap: true,
                controller: widget.scrollWiki,
                children: username != null
                    ? snapshot.data!.children.map<Widget>((e) => gatoCard(e, snapshot, context)).toList()
                    : [
                        ...snapshot.data!.children.map<Widget>((e) => gatoCard(e, snapshot, context)),
                        const SizedBox(height: 100),
                      ],
              );*/
              filho = ListView.builder(
                controller: widget.scrollWiki,
                itemBuilder: (context, index) {
                  if (!_comecouListen) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _barHideListen();
                      _comecouListen = true;
                    });
                  }
                  return username != null
                      ? gatoCard(snapshot.data!.children.toList()[index], snapshot, context)
                      : Column(
                          children: [
                            gatoCard(snapshot.data!.children.toList()[index], snapshot, context),
                            const SizedBox(height: 100),
                          ],
                        );
                },
                itemCount: snapshot.data!.children.length,
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
      ),
    );
  }

  bool _comecouListen = false;

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
            ? Theme.of(context).colorScheme.surfaceTint.withValues(alpha: dark ? 0.25 : 0.1)
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
                        e.key!,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                        softWrap: true,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${e.child("resumo").value}",
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
}
