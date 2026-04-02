import 'package:animations/animations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/screens/home/gatos/wiki/info.dart';
import 'package:gatopedia/screens/index.dart';

class GatoCard extends StatefulWidget {
  final int index;
  final DataSnapshot data;
  final EdgeInsets pd;

  const GatoCard(this.index, this.data, this.pd, {super.key});

  @override
  State<GatoCard> createState() => _GatoCardState();
}

class _GatoCardState extends State<GatoCard> with AutomaticKeepAliveClientMixin {
  late final String gatoID = widget.data.key!;
  late final String gatoHash = widget.data.child("img").value as String;

  late Future<String> _imageUrlGet;
  bool _pegouImageUrl = false;

  @override
  void initState() {
    super.initState();

    if (!_pegouImageUrl) {
      _imageUrlGet = FirebaseStorage.instance.ref("gatos/${gatoID}_mini.webp").getDownloadURL();
      _pegouImageUrl = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            ? GatoInfo(widget.data, widget.pd)
            : Theme(
                data: ThemeData.from(
                  colorScheme: temaBaseBW(App.themeNotifier.value, context).colorScheme,
                  textTheme: temaBaseBW(App.themeNotifier.value, context).textTheme.apply(fontFamily: "Jost"),
                ),
                child: GatoInfo(widget.data, widget.pd),
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
            gatoCardContainer(context, openContainer, widget.data),
      ),
    );
  }

  SizedBox gatoCardContainer(BuildContext context, VoidCallback openContainer, DataSnapshot data) {
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
          onTap: () => openContainer.call(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: FutureBuilder(
                    future: _imageUrlGet,
                    builder: (context, data) {
                      if (data.hasData && data.connectionState == ConnectionState.done) {
                        String imageUrl = data.data!;
                        return BlurHash(
                          hash: gatoHash,
                          decodingHeight: 130,
                          decodingWidth: 130,
                          image: imageUrl,
                          duration: const Duration(milliseconds: 150),
                        );
                      } else {
                        return BlurHash(hash: gatoHash, decodingWidth: 130, decodingHeight: 130);
                      }
                    },
                  ),
                  /*FadeInImage(
                          placeholder: BlurHashImage(gatoHash, decodingWidth: 130, decodingHeight: 130),
                          image: CachedNetworkImageProvider(_imageUrl!),
                          fadeInDuration: const Duration(milliseconds: 300),
                          fadeOutDuration: const Duration(milliseconds: 300),
                          width: 130,
                          height: 130,
                        )*/
                ),
                const SizedBox(width: 15),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        "${data.child("nome").value}",
                        style: const TextStyle(fontVariations: [FontVariation.weight(550)], fontSize: 25),
                        softWrap: true,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${data.child("resumo").value}",
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

  @override
  bool get wantKeepAlive => true;
}
