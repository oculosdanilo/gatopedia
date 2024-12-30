import 'dart:io';
import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/config/deletar_conta.dart';
import 'package:gatopedia/telas/home/eu/profile.dart';
import 'package:gatopedia/telas/home/gatos/forum/forum.dart';
import 'package:gatopedia/telas/home/gatos/forum/new/image_post.dart';
import 'package:gatopedia/telas/home/gatos/forum/new/text_post.dart';
import 'package:gatopedia/telas/home/gatos/wiki/wiki.dart';
import 'package:gatopedia/telas/home/home.dart';
import 'package:gatopedia/telas/index.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

int tabIndex = 0;
bool expandido = true;
bool animReverso = false;

// tela gatos refeito
class Gatos extends StatefulWidget {
  const Gatos({super.key});

  @override
  State<Gatos> createState() => _GatosState();
}

class _GatosState extends State<Gatos> with TickerProviderStateMixin {
  final fagKey = GlobalKey<ExpandableFabState>();

  final miau = AudioPlayer();
  late final TabController _tabController;

  void _setState() {
    return setState(() {
      expandido = expandido;
    });
  }

  _play() async {
    await miau.setAsset("assets/meow.mp3");
    await miau.play();
  }

  late AnimationController _animTabBarController;
  late CurvedAnimation _animTabBarCurve;
  late Animation<double> _animTabBar;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: tabIndex);
    indexAntigo = 0;

    _animTabBarController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 400), reverseDuration: null);
    _animTabBarCurve =
        CurvedAnimation(parent: _animTabBarController, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic);
    _animTabBar = Tween(begin: 0.0, end: 1.0).animate(_animTabBarCurve);

    if (!expandido) {
      _animTabBarController.forward(from: 1.0);
    }
  }

  final ScrollController _scrollForum = ScrollController(initialScrollOffset: scrollSalvo, keepScrollOffset: false);
  final ScrollController _scrollWiki = ScrollController(initialScrollOffset: scrollSalvoWiki, keepScrollOffset: false);
  late List<Widget> telasGatos = <Widget>[
    Wiki(_scrollWiki, _setState, _animTabBarController, _animTabBar),
    Forum(_scrollForum, _setState, _animTabBarController, _animTabBar),
  ];

  _postarImagem(int post, String filetype) async {
    CachedNetworkImage.evictFromCache(
        "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F$post.webp?alt=media");
    if (filetype == "img") {
      XFile? result = await FlutterImageCompress.compressAndGetFile(
        file!.absolute.path,
        "${(await getApplicationDocumentsDirectory()).path}aa.webp",
        quality: 80,
        format: CompressFormat.webp,
      );
      File finalFile = File(result!.path);
      await FirebaseStorage.instance.ref("posts/$post.webp").putFile(finalFile);
    } else {
      await FirebaseStorage.instance.ref("posts/$post.webp").putFile(file!);
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
      message: "Postado com sucesso!",
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(50),
    ).show(context);
  }

  @override
  void dispose() {
    _animTabBarController.dispose();
    _scrollWiki.dispose();
    _scrollForum.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: username != null
          ? ExpandableFab(
              key: fagKey,
              distance: 70,
              overlayStyle: const ExpandableFabOverlayStyle(blur: 4),
              openButtonBuilder: DefaultFloatingActionButtonBuilder(child: const Icon(Icons.edit_rounded)),
              closeButtonBuilder: DefaultFloatingActionButtonBuilder(
                  child: const Icon(Icons.close_rounded), fabSize: ExpandableFabSize.small),
              type: ExpandableFabType.up,
              children: [
                FloatingActionButton.extended(
                  heroTag: null,
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
                  label: const Text("Texto"),
                  icon: const Icon(Icons.text_fields_rounded),
                ),
                OpenContainer(
                  onClosed: (data) {
                    if (postado) {
                      final state = fagKey.currentState;
                      if (state != null) state.toggle();
                      Flushbar(
                        message: "Postando...",
                        duration: const Duration(seconds: 5),
                        margin: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(50),
                      ).show(context);
                      CachedNetworkImage.evictFromCache(
                          "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${int.parse("${snapshotForum!.children.last.key ?? 0}") + 1}.webp?alt=media");
                      _postarImagem(int.parse("${snapshotForum!.children.last.key ?? 0}") + 1, "img");
                    }
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                  closedElevation: 5,
                  openColor: Theme.of(context).colorScheme.surface,
                  openBuilder: (context, action) => const ImagePost("image"),
                  closedColor: Theme.of(context).colorScheme.primaryContainer,
                  closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  closedBuilder: (context, action) => FloatingActionButton.extended(
                    heroTag: null,
                    onPressed: () => action.call(),
                    elevation: 0,
                    label: const Text("Imagem"),
                    icon: const Icon(Icons.image_rounded),
                  ),
                ),
                OpenContainer(
                  onClosed: (data) {
                    if (postado) {
                      final state = fagKey.currentState;
                      if (state != null) state.toggle();
                      Flushbar(
                        message: "Postando...",
                        duration: const Duration(seconds: 5),
                        margin: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(50),
                      ).show(context);
                      CachedNetworkImage.evictFromCache(
                          "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${int.parse("${snapshotForum!.children.last.key ?? 0}") + 1}.webp?alt=media");
                      _postarImagem(int.parse("${snapshotForum!.children.last.key ?? 0}") + 1, "gif");
                    }
                  },
                  transitionDuration: const Duration(milliseconds: 400),
                  closedElevation: 5,
                  openColor: Theme.of(context).colorScheme.surface,
                  openBuilder: (context, action) => const ImagePost("gif"),
                  closedColor: Theme.of(context).colorScheme.primaryContainer,
                  closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  closedBuilder: (context, action) => FloatingActionButton.extended(
                    heroTag: null,
                    onPressed: () => action.call(),
                    elevation: 0,
                    label: const Text("GIF"),
                    icon: const Icon(Icons.gif_rounded),
                  ),
                ),
              ],
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
            child: TabBarView(controller: _tabController, children: telasGatos),
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
      color: username != null ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
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
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.70),
                indicatorColor: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                labelColor: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                tabs: const [Tab(text: "Wiki"), Tab(text: "Feed")],
                onTap: (index) {
                  if (tabIndex == 1 && index == 1) {
                    setState(() {
                      _scrollForum.animateTo(
                        0.0,
                        duration: Duration(microseconds: (300 * _scrollForum.offset).toInt()),
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
                    username != null ? "@$username" : "@shhhanônimo",
                    style: TextStyle(
                      color: username != null
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
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
                  title: const Text(
                    "Já vai? ;(",
                    style: TextStyle(fontVariations: [FontVariation("wght", 500)]),
                    textAlign: TextAlign.center,
                  ),
                  content: const Row(
                      mainAxisAlignment: MainAxisAlignment.center, children: [Text("Tem certeza que deseja sair?")]),
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
          if (sp.containsKey("scrollSalvo")) await sp.remove("scrollSalvo");
          if (sp.containsKey("img") && sp.containsKey("bio")) {
            await sp.remove("bio");
            await sp.remove("img");
          }
          if (!context.mounted) return;
          iniciouUserGoogle = false;
          GoogleSignIn().signOut();
          username = null;
          scrollSalvo = 0;
          scrollSalvoWiki = 0;
          scrollAcumulado = 0;
          iniciouListenForum = false;
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
