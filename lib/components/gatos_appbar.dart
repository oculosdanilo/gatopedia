import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/screens/home/config/deletar_conta.dart';
import 'package:gatopedia/screens/home/gatos/forum/forum.dart';
import 'package:gatopedia/screens/home/gatos/gatos.dart';
import 'package:gatopedia/screens/home/gatos/wiki/wiki.dart';
import 'package:gatopedia/screens/index.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBarGatos extends StatefulWidget {
  final TabController tabController;
  final ScrollController scrollForum;

  const AppBarGatos(this.tabController, this.scrollForum, {super.key});

  @override
  State<AppBarGatos> createState() => _AppBarGatosState();
}

class _AppBarGatosState extends State<AppBarGatos> {
  final miau = AudioPlayer();

  Future<void> _play() async {
    await miau.setAsset("assets/meow.mp3");
    await miau.play();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: username != null ? Theme.of(context).colorScheme.primary : Colors.black,
      width: MediaQuery.sizeOf(context).width,
      child: ValueListenableBuilder(
          valueListenable: Gatos.animTabBar,
          builder: (context, animation, child) {
            return Stack(
              children: [
                Column(
                  children: [
                    AppBar(
                      backgroundColor: Colors.transparent,
                      centerTitle: false,
                      leading: username != null ? botaoSair(context) : null,
                    ),
                    const SizedBox(height: kToolbarHeight),
                    ValueListenableBuilder(
                        valueListenable: Gatos.tabIndex,
                        builder: (context, tabIndex, child) {
                          return TabBar(
                            tabAlignment: TabAlignment.start,
                            isScrollable: true,
                            controller: widget.tabController,
                            labelStyle: const TextStyle(fontSize: 18, fontFamily: "Jost"),
                            unselectedLabelColor: username != null
                                ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.70)
                                : Colors.white.withValues(alpha: 0.70),
                            indicatorColor: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                            labelColor: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                            tabs: const [Tab(text: "Wiki"), Tab(text: "Feed")],
                            onTap: (index) {
                              if (tabIndex == 1 && index == 1 && widget.scrollForum.hasClients) {
                                setState(() {
                                  widget.scrollForum.animateTo(
                                    0.0,
                                    duration: Duration(microseconds: (300 * widget.scrollForum.offset).toInt()),
                                    curve: Curves.easeOutQuad,
                                  );
                                });
                              }
                            },
                          );
                        }),
                  ],
                ),
                Positioned(
                  right: 20,
                  top: ((kToolbarHeight * 2.86) / 2) - 67,
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(animation.value * 40, animation.value * ((kToolbarHeight * 2.86) / 4)),
                        child: Transform.scale(
                          scale: 1 - (animation.value * 0.5),
                          child: child,
                        ),
                      );
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(IonIcons.paw,
                            color: username != null ? const Color(0xffff9922) : const Color(0xff757575)),
                        iconSize: 110,
                        onPressed: () async => await _play(),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(15, kToolbarHeight, 10, 0),
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, animation.value * 25),
                        child: Text(
                          username != null ? "@$username" : AppLocalizations.of(context).gatos_anon,
                          style: TextStyle(
                            color: username != null ? Theme.of(context).colorScheme.onPrimary : Colors.white,
                            fontSize: 28 + (animation.value * -8),
                            fontVariations: const [FontVariation.weight(500)],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          }),
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
}
