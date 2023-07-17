import 'package:flutter/material.dart';
import 'package:gatopedia/home/home.dart';
import 'package:just_audio/just_audio.dart';

import '../../main.dart';
import 'forum/forum.dart';
import 'wiki/wiki.dart';

int tabIndex = 0;
List<Widget> telasGatos = [const Wiki(), const Forum()];

class GatoLista extends StatefulWidget {
  const GatoLista({super.key});

  @override
  State<GatoLista> createState() => _GatoListaState();
}

class _GatoListaState extends State<GatoLista>
    with AutomaticKeepAliveClientMixin {
  final miau = AudioPlayer();
  bool isPlaying = false;

  void _play() {
    miau.setAsset("lib/assets/meow.mp3");
    miau.play();
  }

  @override
  void initState() {
    indexAntigo = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScrollConfiguration(
      behavior: const ScrollBehavior().copyWith(overscroll: false),
      child: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerCoiso) {
            return [
              SliverAppBar.medium(
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                expandedHeight: 120,
                pinned: true,
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
              SliverToBoxAdapter(
                child: PreferredSize(
                  preferredSize: _tabbar.preferredSize,
                  child: Material(
                    color: Theme.of(context).colorScheme.primary,
                    child: _tabbar,
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              telasGatos[0],
              telasGatos[1],
            ],
          ),
        ),
      ),
    );
  }

  TabBar get _tabbar {
    return TabBar(
      physics: const AlwaysScrollableScrollPhysics(),
      onTap: (index) {
        setState(() {
          tabIndex = index;
        });
      },
      labelColor: Theme.of(context).colorScheme.onPrimary,
      unselectedLabelColor: Theme.of(context).colorScheme.outline,
      indicatorColor: Theme.of(context).colorScheme.onPrimary,
      labelStyle: const TextStyle(
        fontFamily: "Jost",
        fontSize: 19,
      ),
      tabs: const [
        Tab(text: "Wiki"),
        Tab(text: "Fórum"),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
