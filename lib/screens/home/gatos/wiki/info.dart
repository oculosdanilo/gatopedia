import 'package:animations/animations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/screens/home/gatos/forum/view/imagem_view.dart';
import 'package:gatopedia/screens/home/gatos/wiki/comentarios.dart';
import 'package:gatopedia/screens/index.dart';
import 'package:icons_plus/icons_plus.dart';

class GatoInfo extends StatefulWidget {
  final DataSnapshot gatoInfo;
  final EdgeInsets pd;

  const GatoInfo(this.gatoInfo, this.pd, {super.key});

  @override
  GatoInfoState createState() {
    return GatoInfoState();
  }
}

class GatoInfoState extends State<GatoInfo> {
  late String img = widget.gatoInfo.child("img").value.toString();
  late String titulo = widget.gatoInfo.child("nome").value as String;
  late String gatoID = widget.gatoInfo.key ?? "error";
  late String gatoImgID = img.split("&")[0];
  late String gatoHash = img.split("&")[1];

  late final scP = MediaQuery.of(context).padding;

  late Future<DataSnapshot> _nComentarios;

  void _fetchNComentarios() {
    _nComentarios = FirebaseDatabase.instance.ref("gatos/$gatoID/nComentarios").get();
  }

  @override
  void initState() {
    super.initState();
    _fetchNComentarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: scP.bottom, left: 75, right: 75),
        child: OpenContainer(
          transitionDuration: const Duration(milliseconds: 350),
          closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          closedColor: username != null
              ? Theme.of(context).colorScheme.surface
              : temaBaseBW(App.themeNotifier.value, context).colorScheme.surface,
          closedBuilder: (context, action) {
            return ElevatedButton.icon(
              style: const ButtonStyle(
                padding: WidgetStatePropertyAll(EdgeInsets.all(13.5)),
              ),
              onPressed: () async => action.call(),
              icon: Icon(
                AntDesign.comment_outline,
                color:
                    username != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
              ),
              label: SizedBox(
                height: 26,
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).wiki_info_commentBtn,
                          style: const TextStyle(fontSize: 18, fontVariations: [FontVariation.weight(500)]),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      constraints: const BoxConstraints(minWidth: 21),
                      height: 21,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: FutureBuilder(
                            future: _nComentarios,
                            builder: (context, asyncSnapshot) {
                              final bool carregou =
                                  asyncSnapshot.connectionState == ConnectionState.done && asyncSnapshot.hasData;
                              late DataSnapshot data;
                              if (carregou) {
                                data = asyncSnapshot.data!;
                              }
                              return Text(
                                carregou ? "${data.value}" : "O",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontVariations: [const FontVariation.weight(600)],
                                  color: username != null
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          openColor: Theme.of(context).colorScheme.surface,
          openBuilder: (context, value) => ComentariosWiki(gatoID, titulo, gatoHash, gatoImgID),
        ),
      ),
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            iconTheme: const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 20)]),
            expandedHeight: 360,
            pinned: true,
            backgroundColor: !_isDark(context)
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainer,
            flexibleSpace: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => ClipRect(
                    child: Imagem(
                      "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/gatos%2F$gatoImgID.webp?alt=media",
                      gatoImgID,
                    ),
                  ),
                ),
              ),
              child: FlexibleSpaceBar(
                expandedTitleScale: 2,
                centerTitle: true,
                title: Text(
                  titulo,
                  style: const TextStyle(color: Colors.white, fontVariations: [FontVariation.weight(550)]),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    SizedBox(
                      width: MediaQuery.sizeOf(context).width,
                      height: MediaQuery.sizeOf(context).width,
                      child: BlurHash(
                        hash: gatoHash,
                        image:
                            "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/gatos%2F$gatoImgID.webp?alt=media",
                        duration: const Duration(milliseconds: 150),
                        color: Theme.of(context).colorScheme.surface,
                        imageFit: BoxFit.cover,
                      ),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.0, 0.5),
                          end: Alignment.center,
                          colors: [Color(0x60000000), Color(0x00000000)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(bottom: widget.pd.bottom + 25),
            sliver: SliverList.list(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "${widget.gatoInfo.child("resumo").value}",
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, fontVariations: [FontVariation.weight(450)], fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "${widget.gatoInfo.child("descricao").value}".replaceAll("\\n", "\n"),
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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

/*class ComentariosWiki extends StatefulWidget {
  final DataSnapshot gatoInfo;

  const ComentariosWiki(this.gatoInfo, {super.key});

  @override
  State<ComentariosWiki> createState() => _ComentariosWikiState();
}*/

/*class _ComentariosWikiState extends State<ComentariosWiki> {
  @override
  void initState() {
    super.initState();
    _getData = FirebaseDatabase.instance.ref().child("gatos/${widget.gatoInfo.key}/comentarios").get();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataSnapshot>(
      future: _getData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final comentarioSS = snapshot.data!;
          return Column(
            children: comentarioSS.children
                .map<Widget>(
                  (e) => e.value != "null"
                      ? Comentario(
                          int.parse(e.key!),
                          e.child("user").value as String,
                          e.child("content").value as String,
                          _deletarC,
                          key: Key(e.key!),
                        )
                      : const SizedBox(),
                )
                .toList()
                .reversed
                .toList(),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _deletarC(int index) {
    FirebaseDatabase.instance.ref("gatos/${widget.gatoInfo.key}/comentarios/$index").remove();
    setState(() {
      _getData = FirebaseDatabase.instance.ref("gatos/${widget.gatoInfo.key}/comentarios").get();
    });
  }
}*/
