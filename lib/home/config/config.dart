// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/index.dart';
import 'package:gatopedia/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _urlGatopediaGit = Uri.parse('https://github.com/oculosdanilo/gatopedia');
final Uri _urlGatopediaGitLatest = Uri.parse('https://github.com/oculosdanilo/gatopedia/releases');
String appName = "";
String packageName = "";
String version = "";
String buildNumber = "";
bool dark = App.themeNotifier.value == ThemeMode.dark ? true : false;

class Config extends StatefulWidget {
  final bool voltar;

  const Config(this.voltar, {super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  late final scW = MediaQuery.of(context).size.width;
  bool esconderSenha = true;
  Icon iconeOlho = const Icon(Icons.visibility_rounded);
  final txtControllerSenha = TextEditingController();
  bool conectando = false;

  mostrarSenha(setState) {
    if (esconderSenha) {
      setState(() {
        esconderSenha = false;
        iconeOlho = const Icon(Icons.visibility_off_rounded);
      });
    } else {
      setState(() {
        esconderSenha = true;
        iconeOlho = const Icon(Icons.visibility_rounded);
      });
    }
  }

  _pegarVersao() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  _saveDark() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dark", true);
  }

  _saveLight() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dark", false);
  }

  Future<bool> _autenticarSenha(senhaDigitada) async {
    final ref = FirebaseDatabase.instance.ref("users/$username/senha");
    final userSenha = utf8.decode(base64Decode((await ref.get()).value as String));
    return senhaDigitada == userSenha;
  }

  _deletarConta(BuildContext context) async {
    final posts = await FirebaseDatabase.instance.ref("posts").get();
    for (final post in posts.children) {
      final comentarios = post.child("comentarios").value as List;
      if (comentarios.length > 2) {
        for (final comentario in comentarios) {
          if ((comentario ?? {"username": ""})["username"] == username) {
            final refRemoveComm =
                FirebaseDatabase.instance.ref("posts/${post.key}/comentarios/${comentarios.indexOf(comentario)}");
            await refRemoveComm.remove();
          }
        }
      }

      if (post.child("username").value == username) {
        final refRemove = FirebaseDatabase.instance.ref("posts/${post.key}");
        await refRemove.remove();
      }
    }

    final wiki = await FirebaseDatabase.instance.ref("gatos").get();
    for (final gato in wiki.children) {
      final comentarios = gato.child("comentarios").value as List;
      if (comentarios.length > 2) {
        for (final comentario in comentarios) {
          if (comentario != "null") {
            if (comentario["user"] == username) {
              final refRemove =
                  FirebaseDatabase.instance.ref("gatos/${gato.key}/comentarios/${comentarios.indexOf(comentario)}");
              await refRemove.remove();
            }
          }
        }
      }
    }

    Future.delayed(Duration.zero, () async {
      await FirebaseDatabase.instance.ref("users/$username").remove();
      username = "";
      final pref = await SharedPreferences.getInstance();
      if (pref.containsKey("username")) {
        await pref.remove("username");
      }

      if (!context.mounted) return;
      Navigator.pop(context, true);
    });
  }

  @override
  void initState() {
    indexAntigo = 2;
    _pegarVersao();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar.large(
          backgroundColor: Theme.of(context).colorScheme.background,
          automaticallyImplyLeading: widget.voltar,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Configurações",
                style: TextStyle(
                  fontFamily: "Jost",
                  fontSize: 40,
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
            height: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_rounded),
                  title: const Text(
                    "Modo escuro",
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: const Text(
                    "Lindo como gatos pretos!",
                    style: TextStyle(fontFamily: "Jost"),
                  ),
                  value: dark,
                  onChanged: (bool value) {
                    setState(() {
                      if (value) {
                        App.themeNotifier.value = ThemeMode.dark;
                        _saveDark();
                      } else {
                        App.themeNotifier.value = ThemeMode.light;
                        _saveLight();
                      }

                      dark = value;
                    });
                  },
                ),
                !widget.voltar
                    ? ListTile(
                        onTap: () async {
                          final dialogo = await showCupertinoDialog<bool>(
                            barrierDismissible: true,
                            context: context,
                            builder: (c) => Theme(
                              data: ThemeData.from(
                                textTheme: GoogleFonts.jostTextTheme(
                                  temaBase(dark ? ThemeMode.dark : ThemeMode.light).textTheme,
                                ),
                                colorScheme: ColorScheme.fromSeed(
                                  seedColor: const Color(0xffff0000),
                                  brightness: dark ? Brightness.dark : Brightness.light,
                                ),
                              ),
                              child: StatefulBuilder(builder: (context, setStateB) {
                                return alertaDeletar(setStateB, context);
                              }),
                            ),
                          );
                          if (!context.mounted) return;
                          if (dialogo != null) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => Index()));
                          }
                        },
                        title: const Text("Deletar conta"),
                        subtitle: const Text("Remove seu perfil e seu conteúdo na plataforma"),
                        leading: const Icon(Symbols.delete_rounded),
                        iconColor: Theme.of(context).colorScheme.error,
                        titleTextStyle: GoogleFonts.jost(color: Theme.of(context).colorScheme.error, fontSize: 20),
                        subtitleTextStyle: GoogleFonts.jost(color: Theme.of(context).colorScheme.error),
                      )
                    : const SizedBox(),
                const Divider(),
                Container(
                  margin: const EdgeInsets.all(15),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sobre o aplicativo",
                        style: TextStyle(fontFamily: "Jost", fontSize: 25),
                      ),
                      SelectableText(
                        "$packageName\nVersão: $version ($buildNumber)",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: botoes(),
                ),
                const SizedBox(
                  height: 17,
                ),
                const Divider(),
                Center(
                  child: Text(
                    "© ${DateTime.now().year} oculosdanilo\nTodos os direitos reservados",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontFamily: "monospace",
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  AlertDialog alertaDeletar(StateSetter setStateB, BuildContext context) {
    return AlertDialog(
      title: Text("Sentirei saudades :,("),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quando sua conta for deletada, suas postagens e comentários também serão removidos da plataforma.\n",
          ),
          Text("Para continuar, insira abaixo sua senha:", textAlign: TextAlign.start),
          SizedBox(
            width: scW * 0.8,
            height: 65,
            child: TextFormField(
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              controller: txtControllerSenha,
              obscureText: esconderSenha,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                prefix: const SizedBox(width: 10),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    onPressed: () => mostrarSenha(setStateB),
                    icon: iconeOlho,
                  ),
                ),
                label: Text("Senha", style: GoogleFonts.jost()),
              ),
            ),
          ),
        ],
      ),
      actions: [
        OutlinedButton(onPressed: () => Navigator.pop(context), child: Text("CANCELAR")),
        FilledButton(
          onPressed: !conectando
              ? () async {
                  setStateB(() {
                    conectando = true;
                  });
                  final senhaCorreta = await _autenticarSenha(txtControllerSenha.text);
                  if (!context.mounted) return;
                  if (senhaCorreta) {
                    await _deletarConta(context);
                    setStateB(() {
                      conectando = false;
                    });
                  } else {
                    Flushbar(
                      duration: const Duration(seconds: 5),
                      margin: const EdgeInsets.all(20),
                      borderRadius: BorderRadius.circular(50),
                      messageText: Row(
                        children: [
                          Icon(Icons.error_rounded, color: blueScheme.onErrorContainer),
                          const SizedBox(width: 10),
                          Text("Senha incorreta :/", style: TextStyle(color: blueScheme.onErrorContainer)),
                        ],
                      ),
                      backgroundColor: blueScheme.errorContainer,
                    ).show(context);
                    setStateB(() {
                      conectando = false;
                    });
                  }
                }
              : null,
          child: Text("APAGAR MINHA CONTA"),
        ),
      ],
    );
  }

  Widget botoes() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            _launchUrl(_urlGatopediaGit);
          },
          icon: const Icon(AntDesign.github),
          label: const Text(
            "Repositório",
            style: TextStyle(fontFamily: "Jost"),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton.icon(
          onPressed: () {
            _launchUrl(_urlGatopediaGitLatest);
          },
          icon: const Icon(AntDesign.github),
          label: const Text(
            "Versões",
            style: TextStyle(fontFamily: "Jost"),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton.icon(
          onPressed: () {
            _launchUrl(
              Uri.parse(
                "https://etec199-danilolima.xp3.biz/2023/0318/",
              ),
            );
          },
          icon: const Icon(Icons.public),
          label: const Text(
            "Web",
            style: TextStyle(fontFamily: "Jost"),
          ),
        )
      ],
    );
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
