// ignore_for_file: prefer_typing_uninitialized_variables, prefer_const_literals_to_create_immutables, prefer_const_constructors, duplicate_ignore, unused_import, use_build_context_synchronously, must_be_immutable
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final blueScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xff000080), brightness: Brightness.dark);
final Uri _urlFlutter = Uri.parse('https://flutter.dev');
final Uri _urlMaterialYou = Uri.parse('https://m3.material.io');
final Uri _urlEmailDanilo = Uri.parse('mailto:danilo.lima124@etec.sp.gov.br');
final Uri _urlEmailLucca = Uri.parse('mailto:juliana.barros36@etec.sp.gov.br');
final Uri _urlLogin = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/salvar.php');
final Uri _urlLoginAuth = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/auth.php');
String buttonText = "Cadastrar/Entrar";
bool esconderSenha = true;
Icon iconeOlho = Icon(Icons.visibility_rounded);
String username = "";

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating),
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(width: 2, color: blueScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(width: 2, color: blueScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: blueScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(width: 3, color: blueScheme.error),
        ),
      ),
      brightness: Brightness.dark,
      colorSchemeSeed: const Color(0xff000080),
      useMaterial3: true,
    ),
    home: Gatopedia(),
  ));
}

class Gatopedia extends StatelessWidget {
  Gatopedia({super.key});
  final blueScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff000080), brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Image(
                image: AssetImage('lib/assets/icon.png'),
                width: 270,
              ),
              Text(
                'Gatopédia!',
                style: TextStyle(
                    fontSize: 35,
                    fontFamily: "Jost",
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 60,
              ),
              const SizedBox(
                width: 300,
              ),
              const FormApp()
            ],
          ),
        ),
      ),
    );
  }
}

class FormApp extends StatefulWidget {
  const FormApp({super.key});

  @override
  LoginState createState() {
    return LoginState();
  }
}

class LoginState extends State<FormApp> {
  final _formKey = GlobalKey<FormState>();
  final blueScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff000080), brightness: Brightness.dark);
  final txtControllerLogin = TextEditingController();
  final txtControllerSenha = TextEditingController();

  @override
  void dispose() {
    txtControllerLogin.dispose();
    super.dispose();
  }

  int txtFieldLenght = 0;
  dynamic counterColor;

  mudarCor(cor) {
    counterColor = cor;
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
        iconeOlho = Icon(Icons.visibility_off_rounded);
      });
    } else {
      setState(() {
        esconderSenha = true;
        iconeOlho = Icon(Icons.visibility_rounded);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            width: 300,
            child: TextFormField(
              controller: txtControllerLogin,
              onChanged: (value) {
                setState(() {
                  txtFieldLenght = value.length;
                  if (value.length <= 4 || value.length > 25) {
                    mudarCor(blueScheme.error);
                  } else {
                    mudarCor(blueScheme.primary);
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
                } else if (value.length <= 4) {
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
                      return blueScheme.error;
                    }
                    if (states.contains(MaterialState.focused)) {
                      return blueScheme.primary;
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
                  label: const Text("Login",
                      style: TextStyle(fontFamily: "Jost"))),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 300,
            height: 57,
            child: TextFormField(
              controller: txtControllerSenha,
              obscureText: esconderSenha,
              decoration: InputDecoration(
                  suffix: IconButton(
                    onPressed: () {
                      mostrarSenha();
                    },
                    icon: iconeOlho,
                  ),
                  label: Text("Senha", style: TextStyle(fontFamily: "Jost"))),
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
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    var map = <String, String>{};
                    map['login'] = txtControllerLogin.text;
                    map['senha'] = txtControllerSenha.text;

                    final response = await http.post(_urlLogin, body: map);
                    if (!response.body.contains("true")) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(response.body)),
                      );
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
                        Navigator.push(context, SlideRightRoute(GatoLista()));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            "Senha incorreta/usuário já existe!",
                            style:
                                TextStyle(color: blueScheme.onErrorContainer),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: blueScheme.errorContainer,
                        ));
                      }
                    }
                  }
                },
                child: Text(
                  buttonText,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          OutlinedButton(
              onPressed: () {
                Navigator.push(context, SlideUpRoute(const Colaboradores()));
              },
              child: const Text("COLABORADORES")),
        ],
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

class GatoLista extends StatelessWidget {
  GatoLista({super.key});
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            iconTheme: IconThemeData(color: blueScheme.onPrimary),
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "@$username",
                style: TextStyle(color: blueScheme.onPrimary),
              ),
              background: Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: IconButton(
                  icon: Icon(
                    Icons.pets_rounded,
                    color: Colors.white,
                  ),
                  iconSize: 100,
                  onPressed: () async {
                    if (!isPlaying) {
                      await audioPlayer
                          .play(AssetSource('meow.m4a'));
                    }
                  },
                ),
              ),
            ),
            backgroundColor: blueScheme.primary,
          ),
          SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return Container(
                color: index.isOdd
                    ? blueScheme.surfaceVariant
                    : blueScheme.surface,
                height: 100,
              );
            }, childCount: 20),
          )
        ],
      ),
    );
  }
}

class SlideUpRoute extends PageRouteBuilder {
  final Widget page;
  SlideUpRoute(this.page)
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
              begin: const Offset(0, 1),
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

class Colaboradores extends StatefulWidget {
  const Colaboradores({super.key});

  @override
  ColaboradoresState createState() {
    return ColaboradoresState();
  }
}

enum MenuItens { itemUm }

class ColaboradoresState extends State {
  final blueScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff000080), brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: prefer_const_literals_to_create_immutables
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar.large(
          iconTheme: IconThemeData(color: blueScheme.onPrimary),
          title: Text(
            "COLABORADORES",
            style: TextStyle(color: blueScheme.onPrimary, fontFamily: "Jost"),
          ),
          actions: [
            PopupMenuButton<MenuItens>(
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<MenuItens>>[
                PopupMenuItem(
                  onTap: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.info_rounded,
                                    color: blueScheme.onBackground,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Sobre o projeto",
                                    style: TextStyle(
                                        fontFamily: "Jost",
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              content: RichText(
                                text: TextSpan(
                                    style: TextStyle(
                                        fontFamily: "Jost", fontSize: 17),
                                    children: [
                                      TextSpan(
                                        text: "Produzido com ",
                                      ),
                                      TextSpan(
                                          text: "Flutter",
                                          style: TextStyle(
                                              color: blueScheme.primary),
                                          children: [
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.open_in_new_rounded,
                                                color: blueScheme.primary,
                                              ),
                                            )
                                          ],
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              _launchUrl(_urlFlutter);
                                            }),
                                      TextSpan(text: " e "),
                                      TextSpan(
                                          text: "Material You",
                                          style: TextStyle(
                                              color: blueScheme.primary),
                                          children: [
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.open_in_new_rounded,
                                                color: blueScheme.primary,
                                              ),
                                            )
                                          ],
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              _launchUrl(_urlMaterialYou);
                                            })
                                    ]),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          });
                    });
                  },
                  child: const Text("Sobre o projeto",
                      style: TextStyle(fontFamily: "Jost", fontSize: 17)),
                )
              ],
            )
          ],
          backgroundColor: blueScheme.primary,
        ),
        SliverToBoxAdapter(
            child: Column(
          children: [
            Card(
              surfaceTintColor: blueScheme.onBackground,
              margin: EdgeInsets.all(20),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(
                        image: AssetImage('lib/assets/danilo.jpg'),
                        width: 130,
                      ),
                    ),
                    SizedBox(
                      width: 17,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Danilo Lima",
                          style: TextStyle(
                              fontFamily: "Jost",
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                        ),
                        SizedBox(
                          height: 17,
                        ),
                        Text(
                          "• Design e programação",
                          style: TextStyle(fontFamily: "Jost"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              launchUrl(_urlEmailDanilo);
                            },
                            child: Text("Email"))
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              surfaceTintColor: blueScheme.onBackground,
              margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image(
                        image: AssetImage('lib/assets/lucca.png'),
                        width: 130,
                      ),
                    ),
                    SizedBox(
                      width: 17,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Juliana Leal \n(Lucca)",
                          style: TextStyle(
                              fontFamily: "Jost",
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                        ),
                        SizedBox(
                          height: 17,
                        ),
                        Text(
                          "• Idealização e pesquisas",
                          style: TextStyle(fontFamily: "Jost"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                            onPressed: () {
                              launchUrl(_urlEmailLucca);
                            },
                            child: Text("Email"))
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ))
      ]),
    );
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
