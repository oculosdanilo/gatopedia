import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/gatos/forum/forum.dart';
import 'package:gatopedia/telas/home/gatos/wiki/wiki.dart';
import 'package:gatopedia/telas/index.dart';
import 'package:gatopedia/telas/login_screen/login/autenticar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool iniciouUserGoogle = false;

class DeletarConta extends StatefulWidget {
  const DeletarConta({super.key});

  @override
  State<DeletarConta> createState() => _DeletarContaState();
}

class _DeletarContaState extends State<DeletarConta> {
  late final scW = MediaQuery.sizeOf(context).width;
  bool esconderSenha = true;
  Icon iconeOlho = const Icon(Icons.visibility_rounded);
  final txtControllerSenha = TextEditingController();

  String? userGoogle;
  bool confirmado = false;
  GoogleSignInAccount? conta;
  bool conectando = false;

  @override
  void initState() {
    super.initState();
    if (!iniciouUserGoogle) {
      _pegarUserGoogle();
      iniciouUserGoogle = true;
    }
  }

  AlertDialog alertaDeletar(StateSetter setStateB) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).delete_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${AppLocalizations.of(context).delete_subtitle1}\n"),
          userGoogle != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).delete_subtitle2_google, textAlign: TextAlign.start),
                    const SizedBox(height: 15),
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
                        label: Text(
                          !confirmado
                              ? AppLocalizations.of(context).delete_googleConfirm
                              : AppLocalizations.of(context).delete_googleConfirmed,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).delete_subtitle2_password, textAlign: TextAlign.start),
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
                            child: IconButton(onPressed: () => _mostrarSenha(setStateB), icon: iconeOlho),
                          ),
                          label: Text(AppLocalizations.of(context).login_password),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: !conectando
              ? () {
                  Navigator.pop(context);
                  confirmado = false;
                }
              : null,
          child: Text(AppLocalizations.of(context).cancel),
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
                            Text(
                              AppLocalizations.of(context).login_errPassword,
                              style: TextStyle(color: blueScheme.onErrorContainer),
                            ),
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
          child: Text(AppLocalizations.of(context).delete_erase),
        ),
      ],
    );
  }

  void _mostrarSenha(void Function(void Function()) setState) {
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

  Future<void> _pegarUserGoogle() async {
    final ref = FirebaseDatabase.instance.ref("users/$username/google");
    final googleID = await ref.get();
    if (googleID.exists) {
      setState(() {
        userGoogle = googleID.value as String;
      });
    }
  }

  Future<bool> _autenticarSenha(String senhaDigitada) async {
    final ref = FirebaseDatabase.instance.ref("users/$username/senha");
    final userSenha = utf8.decode(base64Decode((await ref.get()).value as String));
    return senhaDigitada == userSenha;
  }

  Future<void> _deletarConta(BuildContext context) async {
    final posts = (await FirebaseDatabase.instance.ref("posts").get()).children.toList();
    for (int j = 0; j < posts.length; j++) {
      final comentarios = posts[j].child("comentarios").children.toList();
      if (comentarios.length > 2) {
        for (int i = 0; i < comentarios.length; i++) {
          if (comentarios[i].child("username").value == username) {
            await comentarios[i].ref.remove();
          }
        }
      }

      if (posts[j].child("username").value == username) {
        await posts[j].ref.remove();
      }
    }

    final wiki = await FirebaseDatabase.instance.ref("gatos").get();
    for (final gato in wiki.children) {
      final comentarios = gato.child("comentarios").children.toList();
      if (comentarios.length > 2) {
        for (int i = 0; i < comentarios.length; i++) {
          if (comentarios[i].value != "null" && comentarios[i].value != null) {
            if (comentarios[i].child("user").value == username) {
              await comentarios[i].ref.remove();
            }
          }
        }
      }
    }

    Future.delayed(Duration.zero, () async {
      await FirebaseStorage.instance.ref("users/$username").delete();
      await FirebaseDatabase.instance.ref("users/$username").remove();
      username = null;
      final pref = await SharedPreferences.getInstance();
      if (pref.containsKey("username")) await pref.remove("username");
      if (pref.containsKey("scrollSalvo")) await pref.remove("scrollSalvo");
      if (pref.containsKey("img") && pref.containsKey("bio")) {
        await pref.remove("bio");
        await pref.remove("img");
      }
      scrollSalvo = 0;
      scrollSalvoWiki = 0;
      scrollAcumulado = 0;
      scrollAcumuladoWiki = 0;

      iniciouUserGoogle = false;
      GoogleSignIn().signOut();

      if (!context.mounted) return;
      Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () async {
        final dialogo = await showCupertinoDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (context) => Theme(
            data: ThemeData.from(
              textTheme: temaBase(ThemeMode.dark, context).textTheme.apply(fontFamily: "Jost"),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xffff0000),
                brightness: _isDark(context) ? Brightness.dark : Brightness.light,
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
      title: Text(AppLocalizations.of(context).config_deleteAcc_title),
      subtitle: Text(AppLocalizations.of(context).config_deleteAcc_subtitle),
      leading: const Icon(Symbols.delete_rounded),
      iconColor: Theme.of(context).colorScheme.error,
      titleTextStyle: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 20, fontFamily: "Jost"),
      subtitleTextStyle: TextStyle(color: Theme.of(context).colorScheme.error, fontFamily: "Jost"),
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
