import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/telas/home/config/config.dart';
import 'package:gatopedia/telas/home/eu/profile.dart';
import 'package:gatopedia/telas/home/gatos/forum/forum.dart';
import 'package:gatopedia/telas/home/gatos/wiki/wiki.dart';
import 'package:gatopedia/telas/home/home.dart';
import 'package:gatopedia/main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gatopedia/telas/index.dart';
import 'dart:math' as math;

int tabIndex = 0;
List<Widget> telasGatos = [const Wiki(), const Forum()];

// tela gatos refeito
class Gatos extends StatefulWidget {
  const Gatos({super.key});

  @override
  State<Gatos> createState() => _GatosState();
}

class _GatosState extends State<Gatos> {
  final miau = AudioPlayer();

  _play() async {
    await miau.setAsset("assets/meow.mp3");
    await miau.play();
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          toolbarHeight: 0,
        ),
        body: Column(
          children: [
            appbar(context),
            Flexible(child: TabBarView(children: telasGatos)),
          ],
        ),
      ),
    );
  }

  Container appbar(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Stack(
        children: [
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
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
                            await atualizarListen?.cancel();
                            final sp = await SharedPreferences.getInstance();
                            if (sp.containsKey("username")) await sp.remove("username");
                            if (sp.containsKey("img") && sp.containsKey("bio")) {
                              await sp.remove("bio");
                              await sp.remove("img");
                            }
                            if (!context.mounted) return;
                            iniciouUserGoogle = false;
                            GoogleSignIn().signOut();
                            username = null;
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (c) => const Index(false)));
                          }
                        },
                        icon: Transform.rotate(
                          angle: math.pi,
                          child: Icon(Symbols.logout, color: Theme.of(context).colorScheme.errorContainer),
                        ),
                      )
                    : null,
              ),
              SizedBox(height: kToolbarHeight),
              /*title: Text(
                  username != null ? "@$username" : "@shhhanônimo",
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 30),
                ),*/
              TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                labelStyle: TextStyle(fontSize: 18, fontFamily: "Jost"),
                unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.70),
                indicatorColor: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                labelColor: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                tabs: const [Tab(text: "Wiki"), Tab(text: "Forum")],
              ),
            ],
          ),
          Positioned(
            right: 20,
            top: kToolbarHeight / 5,
            child: IconButton(
              icon: const Icon(Icons.pets_rounded, color: Color(0xffff9922)),
              iconSize: 110,
              onPressed: () async {
                await _play();
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(15, kToolbarHeight, 10, 0),
            child: Text(
              username != null ? "@$username" : "@shhhanônimo",
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontSize: 28),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}

/*
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
                          await atualizarListen?.cancel();
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
*/
