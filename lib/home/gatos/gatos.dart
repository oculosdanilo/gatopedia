import 'package:flutter/material.dart';
import 'package:gatopedia/home/home.dart';
import 'package:just_audio/just_audio.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/home/gatos/forum/forum.dart';
import 'package:gatopedia/home/gatos/wiki/wiki.dart';

int tabIndex = 0;
List<Widget> telasGatos = [
  const Wiki(),
  const Forum(),
];
String txtEnviar = "ENVIAR";

class GatoLista extends StatefulWidget {
  const GatoLista({super.key});

  @override
  State<GatoLista> createState() => _GatoListaState();
}

class _GatoListaState extends State<GatoLista> {
  final miau = AudioPlayer();
  bool isPlaying = false;

  void _play() {
    miau.setAsset("lib/assets/meow.mp3");
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
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerCoiso) {
          return [
            SliverAppBar.medium(
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
                      color: App.themeNotifier.value == ThemeMode.light
                          ? Colors.grey
                          : Colors.white,
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
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.5),
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
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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
}
