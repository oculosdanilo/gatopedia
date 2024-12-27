import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/eu/profile.dart';
import 'package:gatopedia/telas/home/home.dart';
import 'package:gatopedia/telas/index.dart';
import 'package:gatopedia/telas/loginScreen/colab.dart';
import 'package:gatopedia/telas/loginScreen/login/autenticar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _urlGatopediaWeb = Uri.parse("https://osprojetos.web.app/2023/gatopedia");
final Uri _urlGatopediaGit = Uri.parse('https://github.com/oculosdanilo/gatopedia');
final Uri _urlGatopediaGitLatest = Uri.parse('https://github.com/oculosdanilo/gatopedia/releases');
String appName = "";
String packageName = "";
String version = "";
String buildNumber = "";
bool dark = App.themeNotifier.value == ThemeMode.dark ? true : false;

bool iniciouUserGoogle = false;
String? userGoogle;

class Config extends StatefulWidget {
  final bool voltar;

  const Config(this.voltar, {super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  late final scW = MediaQuery.sizeOf(context).width;
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
          if (comentario != "null" && comentario != null) {
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
      await atualizarListen?.cancel();
      await FirebaseDatabase.instance.ref("users/$username").remove();
      username = null;
      final pref = await SharedPreferences.getInstance();
      if (pref.containsKey("username")) await pref.remove("username");
      if (pref.containsKey("scrollSalvo")) await pref.remove("scrollSalvo");
      if (pref.containsKey("img") && pref.containsKey("bio")) {
        await pref.remove("bio");
        await pref.remove("img");
      }

      iniciouUserGoogle = false;
      GoogleSignIn().signOut();

      if (!context.mounted) return;
      Navigator.pop(context, true);
    });
  }

  _pegarUserGoogle() async {
    final ref = FirebaseDatabase.instance.ref("users/$username/google");
    final googleID = await ref.get();
    if (googleID.exists) {
      debugPrint(googleID.value as String);
      setState(() {
        userGoogle = googleID.value as String;
      });
    }
  }

  @override
  void initState() {
    indexAntigo = 2;
    _pegarVersao();
    if (!iniciouUserGoogle) {
      _pegarUserGoogle();
      iniciouUserGoogle = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar.large(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: widget.voltar,
          actions: !widget.voltar
              ? [
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, SlideUpRoute(const Colaboradores()));
                    },
                    icon: const Icon(Symbols.people, fill: 1),
                  ),
                ]
              : [],
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Configurações",
                style: TextStyle(fontSize: 40, fontVariations: [FontVariation.weight(500)]),
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
                  title: const Text("Modo escuro", style: TextStyle(fontSize: 20)),
                  subtitle: const Text("Lindo como gatos pretos!"),
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
                            barrierDismissible: false,
                            context: context,
                            builder: (c) => Theme(
                              data: ThemeData.from(
                                textTheme: temaBase(ThemeMode.dark).textTheme.apply(fontFamily: "Jost"),
                                colorScheme: ColorScheme.fromSeed(
                                  seedColor: const Color(0xffff0000),
                                  brightness: dark ? Brightness.dark : Brightness.light,
                                ),
                              ),
                              child: StatefulBuilder(builder: (context, setStateB) => alertaDeletar(setStateB)),
                            ),
                          );
                          if (!context.mounted) return;
                          if (dialogo != null) {
                            final sp = await SharedPreferences.getInstance();
                            if (sp.containsKey("username")) await sp.remove("username");
                            if (!context.mounted) return;
                            username = null;
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const Index(false)));
                          }
                        },
                        title: const Text("Deletar conta"),
                        subtitle: const Text("Remove seu perfil e seu conteúdo na plataforma"),
                        leading: const Icon(Symbols.delete_rounded),
                        iconColor: Theme.of(context).colorScheme.error,
                        splashColor: Theme.of(context).colorScheme.onSurface,
                        titleTextStyle:
                            TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 20, fontFamily: "Jost"),
                        subtitleTextStyle: TextStyle(color: Theme.of(context).colorScheme.error, fontFamily: "Jost"),
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
                botoes(),
                const SizedBox(height: 17),
                const Divider(),
                Center(
                  child: Text(
                    "\u00a9 ${DateTime.now().year} oculosdanilo\nTodos os direitos reservados",
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

  bool confirmado = false;
  GoogleSignInAccount? conta;

  AlertDialog alertaDeletar(StateSetter setStateB) {
    return AlertDialog(
      title: const Text("Sentirei saudades :,("),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              "Quando sua conta for deletada, suas postagens e comentários também serão removidos da plataforma.\n"),
          userGoogle != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Para continuar, confirme sua conta do Google abaixo:", textAlign: TextAlign.start),
                    SizedBox(height: 15),
                    SizedBox(
                      width: scW * 0.8,
                      child: FilledButton.icon(
                        onPressed: !confirmado
                            ? () async {
                                conta = await loginGoogle();
                                if (conta != null && conta?.id == userGoogle) {
                                  setStateB(() {
                                    confirmado = true;
                                  });
                                }
                              }
                            : () {},
                        icon: Icon(!confirmado ? AntDesign.google_outline : Symbols.done_rounded),
                        label: Text(!confirmado ? "Confirmar" : "Confirmado!", style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Para continuar, insira abaixo sua senha:", textAlign: TextAlign.start),
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
                            child: IconButton(onPressed: () => mostrarSenha(setStateB), icon: iconeOlho),
                          ),
                          label: Text("Senha"),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            confirmado = false;
          },
          child: const Text("CANCELAR"),
        ),
        FilledButton(
          onPressed: (userGoogle == null && !conectando) || (userGoogle != null && confirmado && !conectando)
              ? () async {
                  setStateB(() {
                    conectando = true;
                  });
                  if (userGoogle == null) {
                    final senhaCorreta = await _autenticarSenha(txtControllerSenha.text);
                    if (!mounted) return;
                    if (senhaCorreta) {
                      await _deletarConta(context);
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
                    }
                    setStateB(() {
                      conectando = false;
                    });
                  } else {
                    await _deletarConta(context);
                  }
                }
              : null,
          child: const Text("APAGAR MINHA CONTA"),
        ),
      ],
    );
  }

  Widget botoes() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: () => _launchUrl(_urlGatopediaGit),
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width - 40, 50)),
          ),
          child: Row(
            children: [
              const Icon(AntDesign.github_fill),
              Expanded(
                child: Center(
                  child: Text("Repositório", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _launchUrl(_urlGatopediaGitLatest),
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width - 40, 50)),
          ),
          child: const Row(
            children: [
              Icon(AntDesign.github_fill),
              Expanded(
                child: Center(
                  child: Text("Versões", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _launchUrl(_urlGatopediaWeb),
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width - 40, 50)),
          ),
          child: const Row(
            children: [
              Icon(Symbols.public_rounded),
              Expanded(
                child: Center(
                  child: Text("Site", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        /*ElevatedButton.icon(
          onPressed: () => _launchUrl(_urlGatopediaGit),
          icon: const Icon(AntDesign.github_fill),
          label: const Text(
            "Repositório",
            style: TextStyle(fontSize: 18),
          ),
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width - 50, 50)),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _launchUrl(_urlGatopediaGitLatest),
          icon: const Icon(AntDesign.github_fill),
          label: const Text(
            "Versões",
            style: TextStyle(fontSize: 18),
          ),
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width - 50, 50)),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _launchUrl(_urlGatopediaWeb),
          icon: const Icon(Icons.public_rounded),
          label: const Text(
            "Site",
            style: TextStyle(fontSize: 18),
          ),
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width - 50, 50)),
          ),
        )*/
      ],
    );
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
    throw Exception('Could not launch $url');
  }
}
