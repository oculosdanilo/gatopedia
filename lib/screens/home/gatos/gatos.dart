import 'dart:io';

import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gatopedia/components/gatos_appbar.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/screens/home/gatos/forum/forum.dart';
import 'package:gatopedia/screens/home/gatos/forum/new/image_post.dart';
import 'package:gatopedia/screens/home/gatos/forum/new/text_post.dart';
import 'package:gatopedia/screens/home/gatos/wiki/wiki.dart';
import 'package:gatopedia/screens/home/home.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool _iniciouValueNotifierForum = false;
bool _initAnimTabBar = false;

class Gatos extends StatefulWidget {
  static final ValueNotifier<int> tabIndex = ValueNotifier(0);
  static late final ValueNotifier<Animation<double>> animTabBar;
  final EdgeInsets pd;

  const Gatos(this.pd, {super.key});

  @override
  State<Gatos> createState() => _GatosState();
}

class _GatosState extends State<Gatos> with TickerProviderStateMixin {
  bool _expandido = true;

  final fagKey = GlobalKey<ExpandableFabState>();

  late final TabController _tabController;

  late AnimationController _animTabBarController;
  late CurvedAnimation _animTabBarCurve;

  late AnimationController _animFAB;

  Future<void> _postarImagem(int post, String filetype) async {
    if (filetype == "img") {
      XFile? result = await FlutterImageCompress.compressAndGetFile(
        imagemCortada?.absolute.path ?? file!.absolute.path,
        "${(await getApplicationDocumentsDirectory()).path}aa.webp",
        quality: 80,
        format: CompressFormat.webp,
      );
      File finalFile = File(result!.path);
      await FirebaseStorage.instance.ref("posts/$post.webp").putFile(finalFile);
    } else {
      await FirebaseStorage.instance.ref("posts/$post.webp").putFile(imagemCortada ?? file!);
    }
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    await ref.update({
      "$post": {
        "username": username,
        "content": legenda,
        "likes": {
          "lenght": 0,
          "users": "",
        },
        "img": true,
        "comentarios": [
          {"a": "a"},
          {"a": "a"}
        ]
      }
    });
    if (!mounted) return;
    Flushbar(
      message: AppLocalizations.of(context).forum_new_flushText,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(50),
    ).show(context);
  }

  late final ScrollController scrollForum;
  late final ScrollController scrollWiki;

  @override
  void initState() {
    super.initState();
    scrollForum = ScrollController(
      initialScrollOffset: scrollSalvo,
      keepScrollOffset: false,
      onAttach: (pos) {
        double offsetInicial = scrollForum.offset;

        listenerStopScroll() {
          double off = scrollForum.offset;
          scrollSalvo = off;
          scrollAcumulado = offsetInicial - off;

          if (scrollAcumulado > (kToolbarHeight * 2.86) / 2 && !_expandido) {
            setState(() {
              _expandido = true;
              offsetInicial = off;

              _animTabBarController.reverse();
            });
          } else if (scrollAcumulado < (-(kToolbarHeight * 2.86) / 2) && _expandido) {
            setState(() {
              _expandido = false;
              offsetInicial = off;

              _animTabBarController.forward();
            });
          }
          SharedPreferences.getInstance().then((sp) {
            sp.setDouble("scrollSalvo", off);
          });
        }

        listenerScroll() {
          double off = scrollForum.offset;
          if (!scrollForum.position.isScrollingNotifier.value) {
            if ((scrollAcumulado < 0 && !_expandido) || (scrollAcumulado > 0 && _expandido)) {
              offsetInicial = off;
            }
          }
        }

        scrollAcumulado = 0;

        scrollForum.position.isScrollingNotifier.addListener(listenerScroll);

        scrollForum.position.addListener(listenerStopScroll);
      },
    );
    scrollWiki = ScrollController(
      initialScrollOffset: scrollSalvoWiki,
      keepScrollOffset: false,
      onAttach: (pos) {
        double offsetInicial = scrollWiki.offset;

        listenerStopScroll() {
          double off = scrollWiki.offset;
          if (!scrollWiki.position.isScrollingNotifier.value) {
            if ((scrollAcumuladoWiki < 0 && !_expandido) || (scrollAcumuladoWiki > 0 && _expandido)) {
              setState(() {
                offsetInicial = off;
              });
            }
          }
        }

        listenerScroll() {
          double off = scrollWiki.offset;
          scrollSalvoWiki = off;
          scrollAcumuladoWiki = offsetInicial - off;

          if (scrollAcumuladoWiki > (kToolbarHeight * 2.86) / 2 && !_expandido) {
            setState(() {
              _expandido = true;
              offsetInicial = off;

              _animTabBarController.reverse();
            });
          } else if (scrollAcumuladoWiki < -(kToolbarHeight * 2.86) / 2 && _expandido) {
            setState(() {
              _expandido = false;
              offsetInicial = off;

              _animTabBarController.forward();
            });
          }
        }

        scrollAcumuladoWiki = 0;

        scrollWiki.position.isScrollingNotifier.addListener(listenerStopScroll);

        scrollWiki.position.addListener(listenerScroll);
      },
    );

    if (!_iniciouValueNotifierForum) {
      Forum.snapshotForum = ValueNotifier<DataSnapshot?>(null);
      _iniciouValueNotifierForum = true;
    }

    _tabController = TabController(length: 2, vsync: this, initialIndex: Gatos.tabIndex.value)
      ..animation?.addListener(() {
        if ((_tabController.animation?.value ?? 1) > 0.5) {
          if (!_expandido && scrollSalvo < ((kToolbarHeight * 2.86) / 2)) {
            setState(() {
              _expandido = true;

              _animTabBarController.reverse();
            });
          }
          _animFAB.forward();
          scrollAcumulado = 0;
        } else {
          if (!_expandido && scrollSalvoWiki < ((kToolbarHeight * 2.86) / 2)) {
            setState(() {
              _expandido = true;

              _animTabBarController.reverse();
            });
          }
          _animFAB.reverse();
          scrollAcumuladoWiki = 0;
        }
      });
    indexAntigo = 0;

    _animTabBarController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animTabBarCurve =
        CurvedAnimation(parent: _animTabBarController, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic);
    if (_initAnimTabBar) {
      Gatos.animTabBar.value = Tween(begin: 0.0, end: 1.0).animate(_animTabBarCurve);
    } else {
      Gatos.animTabBar = ValueNotifier(Tween(begin: 0.0, end: 1.0).animate(_animTabBarCurve));
      _initAnimTabBar = true;
    }

    _animFAB = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));

    if (!_expandido) {
      _animTabBarController.forward(from: 1.0);
    }

    if (Gatos.tabIndex.value == 1) {
      _animFAB.forward(from: 1.0);
    }
  }

  @override
  void dispose() {
    scrollForum.dispose();
    scrollWiki.dispose();
    super.dispose();
  }

  final Offset _offset = const Offset(-4, -4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: username != null
          ? AnimatedBuilder(
              animation: _animFAB,
              builder: (c, child) {
                return Opacity(opacity: _animFAB.value, child: child);
              },
              child: ExpandableFab(
                key: fagKey,
                distance: 70,
                overlayStyle: ExpandableFabOverlayStyle(
                  color: Theme.of(context)
                      .cardColor
                      .withValues(alpha: App.themeNotifier.value == ThemeMode.light ? 0.8 : 0.5),
                ),
                openButtonBuilder: DefaultFloatingActionButtonBuilder(child: const Icon(Icons.edit_rounded)),
                closeButtonBuilder: DefaultFloatingActionButtonBuilder(child: const Icon(Icons.close_rounded)),
                childrenAnimation: ExpandableFabAnimation.none,
                childrenOffset: const Offset(5, 0),
                type: ExpandableFabType.up,
                children: [
                  Row(
                    children: [
                      Text(
                        AppLocalizations.of(context).forum_fab_text,
                        style: TextStyle(
                          fontVariations: const [FontVariation.weight(500)],
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          shadows: _isDark(context)
                              ? [
                                  Shadow(
                                    offset: const Offset(0, 2),
                                    blurRadius: 10,
                                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.75),
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton.small(
                        heroTag: null,
                        elevation: 5,
                        onPressed: () async {
                          final state = fagKey.currentState;
                          if (state != null) state.toggle();
                          await showModalBottomSheet(
                            context: context,
                            showDragHandle: true,
                            useSafeArea: true,
                            isScrollControlled: true,
                            builder: (ctx) => const TextPost(),
                          );
                          txtPost.text = "";
                        },
                        child: const Icon(Icons.text_fields_rounded),
                      ),
                    ],
                  ),
                  Transform.translate(
                    offset: _offset,
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context).forum_fab_img,
                          style: TextStyle(
                            fontVariations: const [FontVariation.weight(500)],
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            shadows: _isDark(context)
                                ? [
                                    Shadow(
                                      offset: const Offset(0, 2),
                                      blurRadius: 10,
                                      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.75),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: OpenContainer(
                            tappable: false,
                            onClosed: (data) {
                              if (postado) {
                                final state = fagKey.currentState;
                                if (state != null) state.toggle();
                                Flushbar(
                                  message: AppLocalizations.of(context).forum_posting,
                                  duration: const Duration(seconds: 5),
                                  margin: const EdgeInsets.all(20),
                                  borderRadius: BorderRadius.circular(50),
                                ).show(context);
                                CachedNetworkImage.evictFromCache(
                                    "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${int.parse("${Forum.snapshotForum.value!.children.last.key ?? 0}") + 1}.webp?alt=media");
                                _postarImagem(
                                    int.parse("${Forum.snapshotForum.value!.children.last.key ?? 0}") + 1, "img");
                              }
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                            closedElevation: 5,
                            openColor: Theme.of(context).colorScheme.surface,
                            openBuilder: (context, action) => const ImagePost("image"),
                            closedColor: Theme.of(context).colorScheme.primary,
                            closedShape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide.none),
                            closedBuilder: (context, action) {
                              return FloatingActionButton.small(
                                heroTag: null,
                                onPressed: () => action.call(),
                                elevation: 0,
                                child: const Icon(Icons.image_rounded),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: _offset,
                    child: Row(
                      children: [
                        Text(
                          "GIF",
                          style: TextStyle(
                            fontVariations: const [FontVariation.weight(500)],
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            shadows: _isDark(context)
                                ? [
                                    Shadow(
                                      offset: const Offset(0, 2),
                                      blurRadius: 10,
                                      color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.75),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(width: 20),
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: OpenContainer(
                            tappable: false,
                            onClosed: (data) {
                              if (postado) {
                                final state = fagKey.currentState;
                                if (state != null) state.toggle();
                                Flushbar(
                                  message: AppLocalizations.of(context).forum_posting,
                                  duration: const Duration(seconds: 5),
                                  margin: const EdgeInsets.all(20),
                                  borderRadius: BorderRadius.circular(50),
                                ).show(context);
                                CachedNetworkImage.evictFromCache(
                                    "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${int.parse("${Forum.snapshotForum.value!.children.last.key ?? 0}") + 1}.webp?alt=media");
                                _postarImagem(
                                    int.parse("${Forum.snapshotForum.value!.children.last.key ?? 0}") + 1, "gif");
                              }
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                            closedElevation: 5,
                            openColor: Theme.of(context).colorScheme.surface,
                            openBuilder: (context, action) => const ImagePost("gif"),
                            closedColor: Theme.of(context).colorScheme.primaryContainer,
                            closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            closedBuilder: (context, action) {
                              return FloatingActionButton.small(
                                heroTag: null,
                                onPressed: () => action.call(),
                                elevation: 0,
                                child: const Icon(Icons.gif_rounded),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : null,
      floatingActionButtonLocation: ExpandableFab.location,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: TabBarView(
              controller: _tabController,
              dragStartBehavior: DragStartBehavior.down,
              children: [
                Wiki(scrollWiki, _animTabBarController, widget.pd),
                Forum(scrollForum, _animTabBarController, widget.pd),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: AnimatedBuilder(
              animation: Gatos.animTabBar.value,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, Gatos.animTabBar.value.value * (-(kToolbarHeight * 2.86) / 2)),
                  child: child,
                );
              },
              child: SizedBox(
                height: kToolbarHeight * 2.86,
                child: AppBarGatos(_tabController, scrollForum),
              ),
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
