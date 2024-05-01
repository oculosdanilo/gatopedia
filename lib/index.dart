import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/home/config/config.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/loginScreen/colab.dart';
import 'package:gatopedia/loginScreen/login/form.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/update.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool animImg = false;
  bool animText = false;
  final miau = AudioPlayer();

  late final scW = MediaQuery.of(context).size.width;
  late final scH = MediaQuery.of(context).size.height;

  @override
  void initState() {
    super.initState();
    if (!kDebugMode) {
      checarUpdate(context);
    }
    miau.setAsset("assets/meow.mp3").then((value) {
      miau.play();
      Future.delayed(value!, () {
        setState(() {
          animImg = true;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            animText = true;
          });
        });
      });
    });
  }

  checarUpdate(context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;

    final response = await http.get(
      Uri.parse(
        "https://api.github.com/repos/oculosdanilo/gatopedia/releases/latest",
      ),
    );
    Map<String, dynamic> versaoAtt = jsonDecode(response.body);
    if (version != versaoAtt["tag_name"]) {
      Navigator.push(
        context,
        SlideRightRoute(
          Update(
            versaoAtt["tag_name"],
            versaoAtt["body"],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        actions: [
          PopupMenuButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                onTap: () async {
                  await Navigator.push(
                    context,
                    SlideUpRoute(const Colaboradores()),
                  );
                },
                child: const Row(
                  children: [
                    Icon(Symbols.people_rounded),
                    SizedBox(width: 15),
                    Text("Colaboradores"),
                  ],
                ),
              ),
              PopupMenuItem(
                onTap: () => Navigator.push(
                  context,
                  SlideUpRoute(const Scaffold(body: Config(true))),
                ),
                child: const Row(
                  children: [
                    Icon(Symbols.settings_rounded),
                    SizedBox(width: 15),
                    Text("Configurações"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 75,
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: animText ? 1 : 0,
                  curve: const Interval(0.5, 1),
                  child: FilledButton(
                    onPressed: () async {
                      (
                        // $1: credenciais corretas, $2: lembrar de mim
                        bool,
                        bool
                      ) info = await showModalBottomSheet<(bool, bool)>(
                            showDragHandle: true,
                            isScrollControlled: true,
                            context: context,
                            builder: (c) => Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
                              child: const FormApp(Entrada.login),
                            ),
                          ) ??
                          (false, false);
                      if (info.$1) {
                        if (info.$2) {
                          SharedPreferences sp = await SharedPreferences.getInstance();
                          await sp.setString("username", username ?? "");
                        }
                        if (!context.mounted) return;
                        Navigator.pushReplacement(context, SlideRightRoute(const Home()));
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStatePropertyAll(
                        Size(scW * 0.7, 50),
                      ),
                    ),
                    child: const Text(
                      "Entrar",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: animText ? 1 : 0,
                  curve: const Interval(0.5, 1),
                  child: OutlinedButton(
                    onPressed: () async {
                      bool info = await showModalBottomSheet<bool>(
                            showDragHandle: true,
                            isScrollControlled: true,
                            context: context,
                            builder: (c) => Padding(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
                              child: const FormApp(Entrada.cadastro),
                            ),
                          ) ??
                          false;
                      if (info) {
                        if (!context.mounted) return;
                        Flushbar(
                          message: "Cadastrado com sucesso! Agora entre com as mesmas credenciais",
                          duration: const Duration(seconds: 10),
                          margin: const EdgeInsets.all(20),
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                          borderRadius: BorderRadius.circular(50),
                        ).show(context);
                      }
                    },
                    style: ButtonStyle(
                      fixedSize: MaterialStatePropertyAll(
                        Size(scW * 0.7, 50),
                      ),
                    ),
                    child: const Text(
                      "Cadastrar",
                      style: TextStyle(fontSize: 20),
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
            child: ClipOval(
              child: Image.asset(
                "assets/icon.png",
                width: 250,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginInfo {
  final String username;
  final String senha;

  LoginInfo({required this.username, required this.senha});
}
