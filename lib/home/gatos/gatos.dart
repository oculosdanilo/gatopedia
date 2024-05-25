import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/home/config/config.dart';
import 'package:gatopedia/home/gatos/forum/forum.dart';
import 'package:gatopedia/home/gatos/wiki/wiki.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gatopedia/index.dart';
import 'dart:math' as math;

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
              leading: username != null
                  ? IconButton(
                      onPressed: () async {
                        bool dialogo = await showCupertinoDialog<bool>(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const SizedBox(width: 10),
                                      Text("Já vai? ;(", style: GoogleFonts.jost(fontWeight: FontWeight.bold))
                                    ],
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
                          final sp = await SharedPreferences.getInstance();
                          if (sp.containsKey("username")) await sp.remove("username");
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
                title: Text(
                  username != null ? "@$username" : "@shhhanônimo",
                  style: GoogleFonts.jost(
                      color: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white),
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
                labelStyle: GoogleFonts.jost(fontSize: 18),
                unselectedLabelColor: Colors.grey,
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
        /*NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerCoiso) {
            return [
              SliverAppBar.medium(
                leading: IconButton(
                  onPressed: () async {
                    bool dialogo = await showCupertinoDialog<bool>(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Já vai? ;(",
                                    style: TextStyle(
                                      fontFamily: "Jost",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                ],
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
                      final sp = await SharedPreferences.getInstance();
                      if (sp.getString("username") != null) await sp.remove("username");
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const Index()));
                    }
                  },
                  icon: Transform.rotate(
                    angle: math.pi,
                    child: const Icon(Symbols.logout),
                  ),
                ),
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                expandedHeight: 120,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    "@$username",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontFamily: "Jost",
                    ),
                  ),
                  background: Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                    child: IconButton(
                      icon: Icon(
                        Icons.pets_rounded,
                        color: App.themeNotifier.value == ThemeMode.light ? Colors.grey : Colors.white,
                      ),
                      iconSize: 100,
                      onPressed: () async {
                        if (!isPlaying) {
                          _play();
                        }
                      },
                    ),
                  ),
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    onTap: (index) {
                      setState(() {
                        tabIndex = index;
                      });
                    },
                    labelStyle: const TextStyle(
                      fontFamily: "Jost",
                      fontSize: 19,
                    ),
                    labelColor: Theme.of(context).colorScheme.onPrimary,
                    unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
                    indicatorColor: Theme.of(context).colorScheme.onPrimary,
                    tabs: const [
                      InkWell(
                        child: Tab(
                          text: "Wiki",
                        ),
                      ),
                      InkWell(
                        child: Tab(
                          text: "Fórum",
                        ),
                      ),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: ScrollConfiguration(
            behavior: MyBehavior(),
            child: TabBarView(
              children: telasGatos,
            ),
          ),
        ),*/
      ),
    );
  }
}

/*class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      width: double.infinity,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}*/
