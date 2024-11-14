import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/home/config/config.dart';
import 'package:gatopedia/home/gatos/forum/forum.dart';
import 'package:gatopedia/home/gatos/wiki/wiki.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/main.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gatopedia/index.dart';
import 'dart:math' as math;
import 'package:gatopedia/home/eu/profile.dart';

int tabIndex = 0;
List<Widget> telasGatos = [const Wiki(), const Forum()];

class GatoLista extends StatefulWidget {
  const GatoLista({super.key});

  @override
  State<GatoLista> createState() => _GatoListaState();
}

class _GatoListaState extends State<GatoLista> {
  final miau = AudioPlayer();
  bool isPlaying = false;

  void _play() {
    miau.setAsset("assets/meow.mp3");
    miau.play();
  }

  @override
  void initState() {
    super.initState();
    indexAntigo = 0;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: CustomScrollView(
          scrollBehavior: MyBehavior(),
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              floating: false,
              backgroundColor: username != null ? Theme.of(context).colorScheme.primary : Colors.black,
              expandedHeight: username == null ? 70 : null,
              centerTitle: false,
              leading: username != null
                  ? IconButton(
                      onPressed: () async {
                        bool dialogo = await showCupertinoDialog<bool>(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "Já vai? ;(",
                                    style: TextStyle(fontVariations: [FontVariation("wght", 500)]),
                                    textAlign: TextAlign.center,
                                  ),
                                  content: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [Text("Tem certeza que deseja sair?")]),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          dark = App.themeNotifier.value == ThemeMode.dark;
                                        });
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text('CANCELAR'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          dark = App.themeNotifier.value == ThemeMode.dark;
                                        });
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;
                        if (dialogo) {
                          await atualizarListen.cancel();
                          final sp = await SharedPreferences.getInstance();
                          if (sp.containsKey("username")) await sp.remove("username");
                          if (sp.containsKey("img") && sp.containsKey("bio")) {
                            await sp.remove("bio");
                            await sp.remove("img");
                          }
                          if (!context.mounted) return;
                          username = null;
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (c) => const Index(false)));
                        }
                      },
                      icon: Transform.rotate(
                        angle: math.pi,
                        child: Icon(Symbols.logout, color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    )
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(bottom: 60, left: 50),
                centerTitle: false,
                title: Text(
                  username != null ? "@$username" : "@shhhanônimo",
                  style: TextStyle(color: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white),
                ),
                background: Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: IconButton(
                    icon: const Icon(Icons.pets_rounded, color: Color(0xffff9922)),
                    iconSize: 100,
                    onPressed: () async {
                      if (!isPlaying) _play();
                    },
                  ),
                ),
              ),
              bottom: TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                labelStyle: TextStyle(fontSize: 18, fontFamily: "Jost"),
                unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.70),
                indicatorColor: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                labelColor: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                tabs: const [Tab(text: "Wiki"), Tab(text: "Forum")],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(children: telasGatos),
            ),
          ],
        ),
      ),
    );
  }
}
