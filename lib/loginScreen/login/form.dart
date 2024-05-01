import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatopedia/firebase_options.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/loginScreen/login/autenticar.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/update.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class FormApp extends StatefulWidget {
  const FormApp({super.key});

  @override
  FormAppState createState() => FormAppState();
}

class FormAppState extends State<FormApp> {
  final _formKey = GlobalKey<FormState>();
  final txtControllerLogin = TextEditingController();
  final txtControllerSenha = TextEditingController();
  int txtFieldLenght = 0;
  Color? counterColor;
  bool conectando = false;
  bool esconderSenha = true;
  Icon iconeOlho = const Icon(Icons.visibility_rounded);

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
    } else {
      debugPrint("atualizado");
    }
  }

  Future<void> _navegarAtt(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      SlideRightRoute(const Home()),
    );
    if (!context.mounted) return;
    mudarCor(Theme.of(context).colorScheme.primary);
  }

  _firebaseStart() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  mudarCor(cor) {
    setState(() {
      counterColor = cor;
    });
  }

  mostrarSenha() {
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

  @override
  void initState() {
    super.initState();
    _firebaseStart();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 300,
              child: TextFormField(
                maxLength: 25,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                controller: txtControllerLogin,
                onChanged: (value) {
                  setState(() {
                    txtFieldLenght = value.length;
                    if (value.length <= 3 || value.length > 25) {
                      mudarCor(Theme.of(context).colorScheme.error);
                    } else {
                      mudarCor(Theme.of(context).colorScheme.onBackground);
                    }
                  });
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obrigatório';
                  } else if (!value.contains(RegExp(r'^[a-zA-Z0-9._]+$'))) {
                    return 'Caractere(s) inválido(s)!';
                  } else if (value.length <= 3) {
                    return "Nome muito pequeno!";
                  } else if (value.contains(RegExp(r'^[0-9]+$'))) {
                    return "só números? sério?";
                  } else if (value.length > 25) {
                    return "Nome de usuário muito grande!";
                  }
                  return null;
                },
                decoration: InputDecoration(
                  prefixIconColor: MaterialStateColor.resolveWith(
                      (Set<MaterialState> states) {
                    if (states.contains(MaterialState.error)) {
                      return Theme.of(context).colorScheme.error;
                    }
                    if (states.contains(MaterialState.focused)) {
                      return Theme.of(context).colorScheme.primary;
                    }
                    return blueScheme.outline;
                  }),
                  counter: SizedBox(
                    width: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "$txtFieldLenght",
                          style: TextStyle(color: counterColor),
                        ),
                        Text(
                          "/25",
                          style: TextStyle(color: blueScheme.outline),
                        )
                      ],
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.alternate_email_rounded,
                  ),
                  label: const Text(
                    "Login",
                    style: TextStyle(fontFamily: "Jost"),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 300,
              height: 65,
              child: TextFormField(
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                controller: txtControllerSenha,
                obscureText: esconderSenha,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  prefix: const SizedBox(
                    width: 10,
                  ),
                  suffix: IconButton(
                    onPressed: () {
                      mostrarSenha();
                    },
                    icon: iconeOlho,
                  ),
                  label: const Text(
                    "Senha",
                    style: TextStyle(fontFamily: "Jost"),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 27,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton(
                  onPressed: !conectando
                      ? () async {
                          // Validate returns true if the form is valid, or false otherwise.
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              conectando = true;
                            });
                            Flushbar(
                              message: "Conectando...",
                              duration: const Duration(seconds: 3),
                              margin: const EdgeInsets.all(20),
                              borderRadius: BorderRadius.circular(50),
                            ).show(context);
                            TextInput.finishAutofillContext();
                            (bool, String?) resposta = await autenticar(
                              txtControllerLogin.text,
                              txtControllerSenha.text,
                            );
                            if (!context.mounted) return;
                            if (!resposta.$1) {
                              Flushbar(
                                duration: const Duration(seconds: 10),
                                margin: const EdgeInsets.all(20),
                                borderRadius: BorderRadius.circular(50),
                                backgroundColor:
                                    (resposta.$2?.contains("incorreta") ??
                                            false)
                                        ? Theme.of(context)
                                            .colorScheme
                                            .errorContainer
                                        : const Color(0xFF303030),
                                messageText: (resposta.$2
                                            ?.contains("incorreta") ??
                                        false)
                                    ? Row(
                                        children: [
                                          Icon(
                                            Icons.error_rounded,
                                            color: blueScheme.onErrorContainer,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            resposta.$2 ?? "",
                                            style: TextStyle(
                                              color:
                                                  blueScheme.onErrorContainer,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(resposta.$2 ?? ""),
                              ).show(context);
                              if (!(resposta.$2?.contains("incorreta") ??
                                  false)) {
                                txtControllerLogin.text = "";
                                txtControllerSenha.text = "";
                              }
                            } else {
                              setState(() {
                                username =
                                    txtControllerLogin.text.toLowerCase();
                              });
                              _navegarAtt(context);
                            }
                            setState(() {
                              conectando = false;
                            });
                          }
                        }
                      : null,
                  child: const Text(
                    "Cadastrar/Entrar",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;

  SlideRightRoute(this.page)
      : super(
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
              reverseCurve: Curves.fastOutSlowIn,
            )),
            child: child,
          ),
        );
}
