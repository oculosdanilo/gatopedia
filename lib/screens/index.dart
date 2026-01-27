import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gatopedia/animations/routes.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/screens/home/config/config.dart';
import 'package:gatopedia/screens/home/gatos/gatos.dart';
import 'package:gatopedia/screens/home/home.dart';
import 'package:gatopedia/screens/login_screen/colab.dart';
import 'package:gatopedia/screens/login_screen/login/autenticar.dart';
import 'package:gatopedia/screens/login_screen/login/cadastro.dart';
import 'package:gatopedia/screens/login_screen/login/form.dart';
import 'package:gatopedia/screens/seminternet.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grayscale/grayscale.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool full = false;
Offset? pos;
bool iniciouInternet = false;

class Index extends StatefulWidget {
  final bool tocar;

  const Index(this.tocar, {super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool animImg = false;
  bool animText = false;
  final miau = AudioPlayer();

  bool _googleConectando = false;

  late final scW = MediaQuery.sizeOf(context).width;
  late final scH = MediaQuery.sizeOf(context).height;
  late final pd = MediaQuery.paddingOf(context);

  @override
  void initState() {
    super.initState();
    if (!iniciouInternet) {
      FlutterNativeSplash.remove();
      if (!kIsWeb) {
        connecteo.connectionStream.listen((internet) {
          if (!mounted) return;
          if (!internet) Navigator.push(context, SlideUpRoute(const SemInternet()));
        });
      }
      iniciouInternet = true;
    }
    full = false;
    if (widget.tocar) {
      miau.setAsset("assets/meow.mp3").then((value) {
        miau.play();
        Future.delayed(value!, () {
          setState(() => animImg = true);
          Future.delayed(const Duration(milliseconds: 500), () => setState(() => animText = true));
        });
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => animImg = true);
        Future.delayed(const Duration(milliseconds: 500), () => setState(() => animText = true));
      });
    }

    // TODO: testar se funciona o update
    if (Platform.isAndroid) checarUpdate(context);
  }

  Future<dynamic> _existeContaGoogle(GoogleSignInAccount contaG) async {
    final ref = FirebaseDatabase.instance.ref("users");
    final contas = await ref.get();

    for (DataSnapshot conta in contas.children) {
      if (conta.child("google").exists) {
        if (conta.child("google").value == contaG.id) {
          return conta.key!;
        }
      }
    }
    return false;
  }

  Future<void> _entrarGoogle(BuildContext context) async {
    setState(() => _googleConectando = true);
    final conta = await loginGoogle();
    if (conta != null) {
      final existeConta = await _existeContaGoogle(conta);
      if (!context.mounted) return;
      if (existeConta is String) {
        username = existeConta;
        SharedPreferences sp = await SharedPreferences.getInstance();
        await sp.setString("username", username ?? "");
        setState(() => _googleConectando = false);
        if (!context.mounted) return;
        Navigator.pushReplacement(context, SlideUpRoute(const Home()));
      } else {
        await Navigator.push(context, SlideUpRoute(NewCadastro(conta: conta)));
        setState(() => _googleConectando = false);
      }
    } else {
      setState(() => _googleConectando = false);
    }
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: full ? Colors.black : Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(color: full ? Colors.black : Theme.of(context).colorScheme.surface),
        ),
      ),
      leading: AnimatedOpacity(
        opacity: full ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: IconButton(
          onPressed: full
              ? () => setState(() {
                    pos = null;
                    full = false;
                  })
              : null,
          icon: Platform.isAndroid ? const Icon(Symbols.arrow_back) : const Icon(Symbols.arrow_back_ios_new_rounded),
          color: Colors.white,
        ),
      ),
      actions: [
        PopupMenuButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          iconColor: full ? Colors.white : Theme.of(context).colorScheme.onSurface,
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              onTap: () async => await Navigator.push(context, SlideUpRoute(const Colaboradores())),
              child: Row(
                children: [
                  const Icon(Symbols.people_rounded, fill: 1),
                  const SizedBox(width: 15),
                  Text(AppLocalizations.of(context).index_menu_colab),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () => Navigator.push(context, SlideUpRoute(const Scaffold(body: Config(true)))),
              child: Row(
                children: [
                  const Icon(Symbols.settings_rounded, fill: 1),
                  const SizedBox(width: 15),
                  Text(AppLocalizations.of(context).config_title),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !full,
      onPopInvokedWithResult: (poppou, resultado) {
        if (!poppou) {
          setState(() {
            pos = null;
            full = false;
          });
        }
      },
      child: Scaffold(
        appBar: appBar(),
        body: Stack(
          children: [
            Positioned(
              width: scW,
              top: scH * 0.05 + 250,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: animText ? 1 : 0,
                    child: Text(
                      AppLocalizations.of(context).gatopedia,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 75),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: animText ? 1 : 0,
                    curve: const Interval(0.5, 1),
                    child: FilledButton(
                      onPressed: !_googleConectando
                          ? () async {
                              await showModalBottomSheet(
                                showDragHandle: true,
                                isScrollControlled: true,
                                context: context,
                                builder: (c) => Padding(
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
                                  child: FormApp(c),
                                ),
                              );
                            }
                          : null,
                      style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(scW * 0.7, 50))),
                      child: Text(
                        AppLocalizations.of(context).index_login,
                        style: const TextStyle(fontSize: 20, fontVariations: [FontVariation("wght", 500)]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 400),
                    opacity: animText ? 1 : 0,
                    curve: const Interval(0.5, 1),
                    child: OutlinedButton(
                      onPressed: !_googleConectando
                          ? () async {
                              Navigator.push(context, SlideUpRoute(const NewCadastro()));
                            }
                          : null,
                      style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(scW * 0.7, 50))),
                      child: Text(AppLocalizations.of(context).index_signup, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: animText ? 1 : 0,
                    curve: const Interval(0.5, 1),
                    child: SizedBox(
                      width: scW * 0.7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(width: 5),
                          Text(AppLocalizations.of(context).index_loginWith, style: const TextStyle(fontSize: 20)),
                          const Expanded(child: SizedBox()),
                          OutlinedButton.icon(
                            icon: const Icon(Bootstrap.google),
                            onPressed: !_googleConectando ? () => _entrarGoogle(context) : null,
                            style: const ButtonStyle(minimumSize: WidgetStatePropertyAll(Size(50, 45))),
                            label: const Text("Google"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              curve: Curves.ease,
              duration: const Duration(milliseconds: 500),
              left: (scW / 2) - 125,
              top: animImg ? scH * 0.05 : (scH / 2) - 250,
              child: ClipOval(child: Image.asset("assets/icon.webp", width: 250)),
            ),
            SemConta(animText, scH, scW, () => setState(() => full = true), pd),
            Positioned(
              top: full ? 0 : scH,
              width: scW,
              child: AnimatedOpacity(
                duration: full ? const Duration(milliseconds: 500) : Duration.zero,
                curve: const Interval(0.7, 1),
                opacity: full ? 1 : 0,
                child: Container(
                  height: scH,
                  width: scW,
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Theme(
                    data: ThemeData.from(
                      colorScheme: temaBaseBW(App.themeNotifier.value, context).colorScheme,
                      useMaterial3: true,
                      textTheme: temaBaseBW(App.themeNotifier.value, context).textTheme.apply(fontFamily: "Jost"),
                    ),
                    child: Gatos(pd),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ThemeData temaBaseBW(ThemeMode mode, BuildContext context) {
  return ThemeData(
    colorScheme: GrayColorScheme.highContrastGray(
      mode == ThemeMode.system
          ? PlatformDispatcher.instance.platformBrightness
          : mode == ThemeMode.dark
              ? Brightness.dark
              : Brightness.light,
    ),
  );
}

class SemConta extends StatefulWidget {
  final bool animText;
  final double scH;
  final double scW;
  final Function() notifyParent;
  final EdgeInsets pd;

  const SemConta(this.animText, this.scH, this.scW, this.notifyParent, this.pd, {super.key});

  @override
  State<SemConta> createState() => _SemContaState();
}

class _SemContaState extends State<SemConta> {
  bool acabou = true;
  bool acabouAlt = true;
  bool cancelar = false;
  bool deltaZero = true;

  Offset inicial = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: acabou ? const Duration(milliseconds: 300) : Duration.zero,
      curve: Curves.ease,
      left: 0,
      right: 0,
      bottom: pos == null || (inicial.dy - (pos?.dy ?? 0)) < 0
          ? -widget.scH
          : !full
              ? -widget.scH + (inicial.dy - pos!.dy)
              : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 600),
        opacity: widget.animText ? 1 : 0,
        curve: const Interval(0.5, 1),
        child: GestureDetector(
          onTap: () {
            setState(() {
              acabou = true;
              acabouAlt = true;
              pos = Offset.zero;
            });
            widget.notifyParent();
          },
          onVerticalDragStart: (detalhes) {
            setState(() {
              acabou = false;
              acabouAlt = false;
            });
          },
          onVerticalDragUpdate: (detalhes) {
            setState(() {
              pos = detalhes.globalPosition;
              cancelar = (detalhes.primaryDelta! > 0);
              deltaZero = detalhes.delta.dy == 0.0;
            });
          },
          onVerticalDragDown: (detalhes) {
            setState(() {
              acabouAlt = false;
              acabou = true;
              inicial = detalhes.globalPosition;
            });
          },
          onVerticalDragEnd: (detalhes) {
            if (((inicial.dy - pos!.dy) < ((widget.scH / 7)) && deltaZero) || cancelar) {
              setState(() {
                acabouAlt = true;
                acabou = true;
                pos = null;
              });
            } else {
              setState(() {
                acabouAlt = true;
                acabou = true;
                pos = Offset.zero;
              });
              widget.notifyParent();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              color: full || !acabouAlt ? Colors.black : Theme.of(context).colorScheme.surface,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: widget.scW,
              decoration: BoxDecoration(
                gradient: !full && acabouAlt && _isDark(context)
                    ? LinearGradient(
                        begin: const Alignment(0, -0.75),
                        end: const Alignment(0, -0.96),
                        colors: [Colors.black, Theme.of(context).colorScheme.surface],
                      )
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Lottie.asset(
                      "assets/animations/seta${_isDark(context) || !acabouAlt ? '' : '-light'}.json",
                      width: 50,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context).index_anon,
                    style: TextStyle(
                      fontSize: 20,
                      color: _isDark(context)
                          ? Theme.of(context).colorScheme.onSurface
                          : !acabouAlt
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(
                    height: widget.scH + widget.pd.bottom,
                    child: Center(
                      child: AnimatedOpacity(
                        duration: full || pos != null ? const Duration(milliseconds: 400) : Duration.zero,
                        opacity: pos != null ? 1 : 0,
                        child: const Icon(Bootstrap.incognito, size: 150, fill: 0, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
