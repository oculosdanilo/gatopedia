import 'dart:io';
import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/screens/home/config/deletar_conta.dart';
import 'package:gatopedia/screens/home/gatos/forum/forum.dart';
import 'package:gatopedia/screens/home/gatos/forum/new/image_post.dart';
import 'package:gatopedia/screens/home/gatos/forum/new/text_post.dart';
import 'package:gatopedia/screens/home/gatos/wiki/wiki.dart';
import 'package:gatopedia/screens/home/home.dart';
import 'package:gatopedia/screens/index.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

int tabIndex = 0;
bool expandido = true;
bool animReverso = false;

bool _iniciouValueNotifierForum = false;

class Gatos extends StatefulWidget {
  final EdgeInsets pd;

  const Gatos(this.pd, {super.key});

  @override
  State<Gatos> createState() => _GatosState();
}

class _GatosState extends State<Gatos> with TickerProviderStateMixin {
  final fagKey = GlobalKey<ExpandableFabState>();

  final miau = AudioPlayer();
  late final TabController _tabController;

  Future<void> _play() async {
    await miau.setAsset("assets/meow.mp3");
    await miau.play();
  }

  late AnimationController _animTabBarController;
  late CurvedAnimation _animTabBarCurve;
  late Animation<double> _animTabBar;

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

          if (scrollAcumulado > (kToolbarHeight * 2.86) / 2 && !expandido) {
            setState(() {
              expandido = true;
              offsetInicial = off;

              _animTabBarController.reverse();
            });
          } else if (scrollAcumulado < (-(kToolbarHeight * 2.86) / 2) && expandido) {
            setState(() {
              expandido = false;
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
            if ((scrollAcumulado < 0 && !expandido) || (scrollAcumulado > 0 && expandido)) {
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
            if ((scrollAcumuladoWiki < 0 && !expandido) || (scrollAcumuladoWiki > 0 && expandido)) {
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

          if (scrollAcumuladoWiki > (kToolbarHeight * 2.86) / 2 && !expandido) {
            setState(() {
              expandido = true;
              offsetInicial = off;

              _animTabBarController.reverse();
            });
          } else if (scrollAcumuladoWiki < -(kToolbarHeight * 2.86) / 2 && expandido) {
            setState(() {
              expandido = false;
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
      Forum.snapshotForum = ValueNotifier(null);
      _iniciouValueNotifierForum = true;
    }

    _tabController = TabController(length: 2, vsync: this, initialIndex: tabIndex)
      ..animation?.addListener(() {
        if ((_tabController.animation?.value ?? 1) > 0.5) {
          if (!expandido && scrollSalvo < ((kToolbarHeight * 2.86) / 2)) {
            setState(() {
              expandido = true;

              _animTabBarController.reverse();
            });
          }
          _animFAB.forward();
          scrollAcumulado = 0;
        } else {
          if (!expandido && scrollSalvoWiki < ((kToolbarHeight * 2.86) / 2)) {
            setState(() {
              expandido = true;

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
    _animTabBar = Tween(begin: 0.0, end: 1.0).animate(_animTabBarCurve);

    _animFAB = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));

    if (!expandido) {
      _animTabBarController.forward(from: 1.0);
    }

    if (tabIndex == 1) {
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
              animation: _animTabBar,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animTabBar.value * (-(kToolbarHeight * 2.86) / 2)),
                  child: child,
                );
              },
              child: SizedBox(
                height: kToolbarHeight * 2.86,
                child: appbar(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget appbar(BuildContext context) {
    return Container(
      color: username != null ? Theme.of(context).colorScheme.primary : Colors.black,
      width: MediaQuery.sizeOf(context).width,
      child: Stack(
        children: [
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                centerTitle: false,
                leading: username != null ? botaoSair(context) : null,
              ),
              const SizedBox(height: kToolbarHeight),
              TabBar(
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                controller: _tabController,
                labelStyle: const TextStyle(fontSize: 18, fontFamily: "Jost"),
                unselectedLabelColor: username != null
                    ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.70)
                    : Colors.white.withValues(alpha: 0.70),
                indicatorColor: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                labelColor: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                tabs: const [Tab(text: "Wiki"), Tab(text: "Feed")],
                onTap: (index) {
                  if (tabIndex == 1 && index == 1 && scrollForum.hasClients) {
                    setState(() {
                      scrollForum.animateTo(
                        0.0,
                        duration: Duration(microseconds: (300 * scrollForum.offset).toInt()),
                        curve: Curves.easeOutQuad,
                      );
                    });
                  }
                },
              ),
            ],
          ),
          Positioned(
            right: 20,
            top: ((kToolbarHeight * 2.86) / 2) - 67,
            child: AnimatedBuilder(
              animation: _animTabBar,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_animTabBar.value * 40, _animTabBar.value * ((kToolbarHeight * 2.86) / 4)),
                  child: Transform.scale(
                    scale: 1 - (_animTabBar.value * 0.5),
                    child: child,
                  ),
                );
              },
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Icon(IonIcons.paw, color: username != null ? const Color(0xffff9922) : const Color(0xff757575)),
                  iconSize: 110,
                  onPressed: () async => await _play(),
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(15, kToolbarHeight, 10, 0),
            child: AnimatedBuilder(
              animation: _animTabBar,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _animTabBar.value * 25),
                  child: Text(
                    username != null ? "@$username" : AppLocalizations.of(context).gatos_anon,
                    style: TextStyle(
                      color: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                      fontSize: 28 + (_animTabBar.value * -8),
                      fontVariations: const [FontVariation.weight(500)],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  IconButton botaoSair(BuildContext context) {
    return IconButton(
      onPressed: () async {
        bool dialogo = await showCupertinoDialog<bool>(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  icon: Transform.rotate(
                    angle: math.pi,
                    child: Icon(Symbols.logout, color: Theme.of(context).colorScheme.error),
                  ),
                  title: Text(
                    AppLocalizations.of(context).gatos_exit_title,
                    style: const TextStyle(fontVariations: [FontVariation("wght", 500)]),
                    textAlign: TextAlign.center,
                  ),
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text(AppLocalizations.of(context).gatos_exit_desc)],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(AppLocalizations.of(context).cancel),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
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
          if (sp.containsKey("scrollSalvo")) await sp.remove("scrollSalvo");
          if (sp.containsKey("img") && sp.containsKey("bio")) {
            await sp.remove("bio");
            await sp.remove("img");
          }
          if (!context.mounted) return;
          iniciouUserGoogle = false;
          GoogleSignIn.instance.signOut();
          username = null;
          scrollSalvo = 0;
          scrollSalvoWiki = 0;
          scrollAcumulado = 0;
          scrollAcumuladoWiki = 0;
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(builder: (c) => const Index(false)));
        }
      },
      icon: Transform.rotate(
        angle: math.pi,
        child: Icon(Symbols.logout, color: Theme.of(context).colorScheme.errorContainer),
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
