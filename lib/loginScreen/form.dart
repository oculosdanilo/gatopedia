// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../loginScreen/colab.dart';
import '../firebase_options.dart';
import '../home/home.dart';
import '../update.dart';

final Uri _urlLogin = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/salvar.php');
final Uri _urlLoginAuth = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/auth.php');
final Uri _urlGatoList = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/listar.php');

class FormApp extends StatefulWidget {
  const FormApp({super.key});

  @override
  LoginState createState() {
    return LoginState();
  }
}

class LoginState extends State<FormApp> {
  final _formKey = GlobalKey<FormState>();
  final txtControllerLogin = TextEditingController();
  final txtControllerSenha = TextEditingController();
  String usernameDoDB = "";

  int txtFieldLenght = 0;
  dynamic counterColor;

  checarUpdate(context) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;

    final response = await http.post(urlVersao);
    List versoes = jsonDecode(response.body);
    if (version != versoes.first['VERSAO']) {
      Navigator.push(context, SlideRightRoute(Update(versoes.first["VERSAO"])));
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

    mudarCor(Theme.of(context).colorScheme.primary);
  }

  _firebaseStart() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    snapshot = await ref.get();
    debugPrint("${snapshot?.value}");
  }

  mudarCor(cor) {
    setState(() {
      counterColor = cor;
    });
  }

  mudarTextoDoBotao() {
    setState(() {
      buttonText = "Entrar";
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

  _read() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? user = prefs.getString("user");
    if (user != null) {
      mudarTextoDoBotao();
    }
  }

  @override
  void initState() {
    super.initState();
    _read();
    _firebaseStart();
  }

  @override
  Widget build(BuildContext context) {
    save() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("user", username);
    }

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
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
                        Text("$txtFieldLenght",
                            style: TextStyle(color: counterColor)),
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
                  label:
                      const Text("Login", style: TextStyle(fontFamily: "Jost")),
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
                onFieldSubmitted: (value) async {
                  if (_formKey.currentState!.validate()) {
                    TextInput.finishAutofillContext();
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    var map = <String, String>{};
                    map['login'] = txtControllerLogin.text;
                    map['senha'] = txtControllerSenha.text;

                    Flushbar(
                      message: "Conectando...",
                      duration: const Duration(seconds: 2),
                      margin: const EdgeInsets.all(20),
                      borderRadius: BorderRadius.circular(50),
                    ).show(context);
                    final response = await http.post(_urlLogin, body: map);
                    if (!response.body.contains("true")) {
                      Flushbar(
                        message: response.body,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(20),
                        flushbarStyle: FlushbarStyle.FLOATING,
                        borderRadius: BorderRadius.circular(50),
                      ).show(context);
                      txtControllerLogin.text = "";
                      txtControllerSenha.text = "";
                      mudarTextoDoBotao();
                    } else {
                      var mapAuth = <String, String>{};
                      mapAuth['login'] = txtControllerLogin.text;
                      final responseAuth =
                          await http.post(_urlLoginAuth, body: mapAuth);
                      if (jsonDecode(responseAuth.body)[0]["SENHA"] ==
                          txtControllerSenha.text) {
                        username = txtControllerLogin.text;
                        final responseList = await http.post(_urlGatoList);
                        gatoLista = jsonDecode(responseList.body);
                        save();
                        mudarTextoDoBotao();
                        _firebaseStart();
                        _navegarAtt(context);
                      } else {
                        Flushbar(
                          flushbarStyle: FlushbarStyle.FLOATING,
                          margin: const EdgeInsets.all(20),
                          messageText: Row(
                            children: [
                              Icon(
                                Icons.error_rounded,
                                color: blueScheme.onErrorContainer,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Senha incorreta: usuário já existe!",
                                style: TextStyle(
                                    color: blueScheme.onErrorContainer),
                              ),
                            ],
                          ),
                          duration: const Duration(seconds: 5),
                          borderRadius: BorderRadius.circular(50),
                          backgroundColor: blueScheme.errorContainer,
                        ).show(context);
                      }
                    }
                  }
                },
                autofillHints: const [AutofillHints.password],
                controller: txtControllerSenha,
                obscureText: esconderSenha,
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
                    label: const Text("Senha",
                        style: TextStyle(fontFamily: "Jost"))),
              ),
            ),
            const SizedBox(
              height: 27,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: const Text(
                    "Sair",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                FilledButton(
                  onPressed: () async {
                    // Validate returns true if the form is valid, or false otherwise.
                    if (_formKey.currentState!.validate()) {
                      TextInput.finishAutofillContext();
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      var map = <String, String>{};
                      map['login'] = txtControllerLogin.text;
                      map['senha'] = txtControllerSenha.text;

                      Flushbar(
                        message: "Conectando...",
                        duration: const Duration(seconds: 10),
                        margin: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(50),
                      ).show(context);
                      final response = await http.post(_urlLogin, body: map);
                      if (!response.body.contains("true")) {
                        Flushbar(
                          message: response.body,
                          duration: const Duration(seconds: 5),
                          margin: const EdgeInsets.all(20),
                          flushbarStyle: FlushbarStyle.FLOATING,
                          borderRadius: BorderRadius.circular(50),
                        ).show(context);
                        txtControllerLogin.text = "";
                        txtControllerSenha.text = "";
                        mudarTextoDoBotao();
                      } else {
                        var mapAuth = <String, String>{};
                        mapAuth['login'] = txtControllerLogin.text;
                        final responseAuth =
                            await http.post(_urlLoginAuth, body: mapAuth);
                        if (jsonDecode(responseAuth.body)[0]["SENHA"] ==
                            txtControllerSenha.text) {
                          username = txtControllerLogin.text;
                          final responseList = await http.post(_urlGatoList);
                          gatoLista = jsonDecode(responseList.body);
                          save();
                          mudarTextoDoBotao();
                          _firebaseStart();
                          _navegarAtt(context);
                        } else {
                          Flushbar(
                            flushbarStyle: FlushbarStyle.FLOATING,
                            margin: const EdgeInsets.all(20),
                            messageText: Row(
                              children: [
                                Icon(
                                  Icons.error_rounded,
                                  color: blueScheme.onErrorContainer,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Senha incorreta: usuário já existe!",
                                  style: TextStyle(
                                      color: blueScheme.onErrorContainer),
                                ),
                              ],
                            ),
                            duration: const Duration(seconds: 5),
                            borderRadius: BorderRadius.circular(50),
                            backgroundColor: blueScheme.errorContainer,
                          ).show(context);
                        }
                      }
                    }
                  },
                  child: Text(
                    buttonText,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(context, SlideUpRoute(const Colaboradores()));
              },
              label: const Text("COLABORADORES"),
              icon: const Icon(Icons.people_alt_rounded),
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
