import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gatopedia/home/config/config.dart';
import 'package:gatopedia/home/gatos/gatos.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/loginScreen/colab.dart';
import 'package:gatopedia/loginScreen/login/form.dart';
import 'package:gatopedia/loginScreen/seminternet.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/update.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:grayscale/grayscale.dart';
import 'package:http/http.dart' as http;
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gatopedia/loginScreen/login/cadastro.dart';

bool full = false;
Offset? pos;
bool iniciou = false;

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

  late final scW = MediaQuery.of(context).size.width;
  late final scH = MediaQuery.of(context).size.height;

  @override
  void initState() {
    super.initState();
    if (!iniciou) {
      FlutterNativeSplash.remove();
      iniciou = true;
    }
    full = false;
    if (!kIsWeb) {
      connecteo.connectionStream.listen((internet) {
        if (!internet) Navigator.push(context, SlideUpRoute(const SemInternet()));
      });
    }
    if (!kDebugMode && !kProfileMode && !kIsWeb) {
      _checarUpdate();
    }
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
  }

  _checarUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;

    final response = await http.get(Uri.parse("https://api.github.com/repos/oculosdanilo/gatopedia/releases/latest"));
    Map<String, dynamic> versaoAtt = jsonDecode(response.body);
    if (version != versaoAtt["tag_name"]) {
      if (!mounted) return;
      Navigator.push(context, SlideRightRoute(Update(versaoAtt["tag_name"], versaoAtt["body"])));
    }
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

  _entrarGoogle(BuildContext context) async {
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
          icon: const Icon(Symbols.arrow_back),
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
              child: const Row(
                children: [Icon(Symbols.people_rounded, fill: 1), SizedBox(width: 15), Text("Colaboradores")],
              ),
            ),
            PopupMenuItem(
              onTap: () => Navigator.push(context, SlideUpRoute(const Scaffold(body: Config(true)))),
              child: const Row(
                children: [Icon(Symbols.settings_rounded, fill: 1), SizedBox(width: 15), Text("Configurações")],
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
      onPopInvoked: (poppou) {
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
                    child: const Text(
                      "Gatopédia!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
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
                      child: Text("Entrar", style: GoogleFonts.jost(fontSize: 20)),
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
                      child: Text("Cadastrar", style: GoogleFonts.jost(fontSize: 20)),
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
                          Text("Entrar com:", style: GoogleFonts.jost(fontSize: 20)),
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
              child: ClipOval(child: Image.asset("assets/icon.png", width: 250)),
            ),
            SemConta(animText, scH, scW, () => setState(() => full = true)),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: const Interval(0.99, 1),
              top: full ? 0 : scH,
              width: scW,
              child: AnimatedOpacity(
                duration: full ? const Duration(milliseconds: 500) : Duration.zero,
                curve: const Interval((500 / 300) * 0.01, 1),
                opacity: full ? 1 : 0,
                child: Container(
                  height: scH,
                  width: scW,
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Theme(
                    data: ThemeData.from(
                      colorScheme: GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light),
                      useMaterial3: true,
                    ),
                    child: const GatoLista(),
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

class SemConta extends StatefulWidget {
  final bool animText;
  final double scH;
  final double scW;
  final Function() notifyParent;

  const SemConta(this.animText, this.scH, this.scW, this.notifyParent, {super.key});

  @override
  State<SemConta> createState() => _SemContaState();
}

class _SemContaState extends State<SemConta> {
  bool acabou = true;
  bool acabouAlt = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: acabou ? const Duration(milliseconds: 300) : Duration.zero,
      curve: Curves.ease,
      left: 0,
      right: 0,
      bottom: pos == null
          ? -widget.scH
          : !full
              ? -pos!.dy
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
          onHorizontalDragStart: (detalhes) {
            setState(() {
              acabou = false;
              acabouAlt = false;
            });
          },
          onHorizontalDragUpdate: (detalhes) => setState(() => pos = detalhes.globalPosition),
          onHorizontalDragDown: (detalhes) {
            setState(() {
              acabouAlt = false;
              acabou = true;
              pos = detalhes.globalPosition;
            });
          },
          onHorizontalDragEnd: (detalhes) {
            if ((pos?.dy ?? 0) > ((widget.scH / 4) * 3)) {
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
                gradient: !full && acabouAlt && dark
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
                  Center(child: Lottie.asset("assets/anim/seta${dark || !acabouAlt ? '' : '-light'}.json", width: 50)),
                  Text(
                    "Entrar sem conta",
                    style: GoogleFonts.jost(
                        fontSize: 20,
                        color: dark
                            ? Theme.of(context).colorScheme.onSurface
                            : !acabouAlt
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface),
                  ),
                  SizedBox(height: 20 + widget.scH),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomNavRoute<T> extends MaterialPageRoute<T> {
  CustomNavRoute({required super.builder});

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}
