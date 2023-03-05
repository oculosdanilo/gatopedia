// ignore_for_file: prefer_typing_uninitialized_variables, prefer_const_literals_to_create_immutables, prefer_const_constructors, duplicate_ignore

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _urlFlutter = Uri.parse('https://flutter.dev');
final Uri _urlMaterialYou = Uri.parse('https://m3.material.io');

void main() {
  final blueScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff000080), brightness: Brightness.dark);
  runApp(MaterialApp(
    theme: ThemeData(
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

  int txtFieldLenght = 0;
  dynamic counterColor;

  mudarCor(cor) {
    counterColor = cor;
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
            child: TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
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
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('hmmm')),
                    );
                  }
                },
                child: const Text(
                  "Cadastrar",
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
                Navigator.push(context, SlideRightRoute(const Colaboradores()));
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
          child: Card(
            surfaceTintColor: blueScheme.onBackground,
            margin: EdgeInsets.all(20),
            child: Text("aiai"),
          ),
        )
      ]),
    );
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
