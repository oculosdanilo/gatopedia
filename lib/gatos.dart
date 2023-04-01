import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_cache/just_audio_cache.dart';

import 'main.dart';
import 'forum.dart';
import 'wiki.dart';

int tabIndex = 0;
List<Widget> telasGatos = [const Wiki(), const Forum()];

class GatoLista extends StatefulWidget {
  const GatoLista({super.key});

  @override
  State<GatoLista> createState() => _GatoListaState();
}

class _GatoListaState extends State<GatoLista> {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;

  void _play() async {
    await audioPlayer.dynamicSet(url: urlMeow, preload: true);
    audioPlayer.play();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerCoiso) {
          return [
            SliverAppBar.medium(
              iconTheme:
                  IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
              expandedHeight: 120,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  "@$username",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontFamily: "Jost"),
                ),
                background: Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.pets_rounded,
                      color: Colors.white,
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
                  physics: const AlwaysScrollableScrollPhysics(),
                  onTap: (index) {
                    setState(() {
                      tabIndex = index;
                    });
                  },
                  labelStyle: const TextStyle(fontFamily: "Jost", fontSize: 16),
                  labelColor: Theme.of(context).colorScheme.onPrimary,
                  unselectedLabelColor: Theme.of(context).colorScheme.outline,
                  indicatorColor: Theme.of(context).colorScheme.onPrimary,
                  tabs: const [
                    Tab(text: "Wiki"),
                    Tab(text: "Fórum"),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: PageTransitionSwitcher(
          reverse: tabIndex == 0,
          transitionBuilder: (
            child,
            animation,
            secondAnimation,
          ) =>
              SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          ),
          duration: const Duration(
            milliseconds: 500,
          ),
          child: telasGatos[tabIndex],
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
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
