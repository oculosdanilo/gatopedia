// ignore_for_file: prefer_typing_uninitialized_variables, prefer_const_literals_to_create_immutables, prefer_const_constructors, duplicate_ignore, unused_import, use_build_context_synchronously, must_be_immutable
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_cache/just_audio_cache.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
final Uri _urlGatoList = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/listar.php');
final Uri _urlCList = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/commentListar.php');
String urlMeow =
    "https://drive.google.com/uc?export=download&id=1Sn1NxfA5S1_KAwdet5bEf9ocI4qJ4dEy";
String buttonText = "Cadastrar/Entrar";
bool esconderSenha = true;
Icon iconeOlho = Icon(Icons.visibility_rounded);
String username = "";
dynamic gatoLista = "";
int indexClicado = 0;

void main() async {
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

class Gatopedia extends StatefulWidget {
  const Gatopedia({super.key});

  @override
  GatopediaState createState() {
    return GatopediaState();
  }
}

class GatopediaState extends State {
  final miau = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _play();
  }

  void _play() async {
    await miau.dynamicSet(url: urlMeow);
    miau.play();
  }

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
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Gatopédia!',
                    textStyle: TextStyle(
                        fontSize: 35,
                        fontFamily: "Jost",
                        fontWeight: FontWeight.bold),
                    speed: Duration(milliseconds: 70),
                  ),
                ],
                totalRepeatCount: 1,
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
  final txtControllerLogin = TextEditingController();
  final txtControllerSenha = TextEditingController();
  String usernameDoDB = "";

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

  _read() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/my_file.txt');
      // ignore: unused_local_variable
      String text = await file.readAsString();
      mudarTextoDoBotao();
    } catch (e) {
      if (kDebugMode) {
        print("Couldn't read file");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _read();
  }

  @override
  Widget build(BuildContext context) {
    save() async {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/my_file.txt');
      final text = username;
      await file.writeAsString(text);
      if (kDebugMode) {
        print('saved');
      }
    }

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          children: [
            SizedBox(
              width: 300,
              child: TextFormField(
                autofillHints: [AutofillHints.username],
                controller: txtControllerLogin,
                onChanged: (value) {
                  setState(() {
                    txtFieldLenght = value.length;
                    if (value.length <= 3 || value.length > 25) {
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
                autofillHints: [AutofillHints.password],
                controller: txtControllerSenha,
                obscureText: esconderSenha,
                decoration: InputDecoration(
                    prefix: SizedBox(
                      width: 10,
                    ),
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
                      TextInput.finishAutofillContext();
                      // If the form is valid, display a snackbar. In the real world,
                      // you'd often call a server or save the information in a database.
                      var map = <String, String>{};
                      map['login'] = txtControllerLogin.text;
                      map['senha'] = txtControllerSenha.text;

                      Flushbar(
                        message: "Conectando...",
                        duration: Duration(seconds: 2),
                        margin: EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(50),
                      ).show(context);
                      final response = await http.post(_urlLogin, body: map);
                      if (!response.body.contains("true")) {
                        Flushbar(
                          message: response.body,
                          duration: Duration(seconds: 2),
                          margin: EdgeInsets.all(20),
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
                          Navigator.push(context, SlideRightRoute(GatoLista()));
                        } else {
                          Flushbar(
                            flushbarStyle: FlushbarStyle.FLOATING,
                            margin: EdgeInsets.all(20),
                            messageText: Row(
                              children: [
                                Icon(
                                  Icons.error_rounded,
                                  color: blueScheme.onErrorContainer,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Senha incorreta: usuário já existe!",
                                  style: TextStyle(
                                      color: blueScheme.onErrorContainer),
                                ),
                              ],
                            ),
                            duration: Duration(seconds: 5),
                            borderRadius: BorderRadius.circular(50),
                            backgroundColor: blueScheme.errorContainer,
                          ).show(context);
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
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(context, SlideUpRoute(const Colaboradores()));
              },
              label: const Text("COLABORADORES"),
              icon: Icon(Icons.people_alt_rounded),
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

class GatoLista extends StatefulWidget {
  const GatoLista({super.key});

  @override
  GatoListaState createState() {
    return GatoListaState();
  }
}

class GatoListaState extends State {
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;

  void _play() async {
    await audioPlayer.dynamicSet(url: urlMeow, preload: true);
    audioPlayer.play();
  }

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
                style:
                    TextStyle(color: blueScheme.onPrimary, fontFamily: "Jost"),
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
                      _play();
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
              return SizedBox(
                height: 140,
                child: Card(
                  margin: EdgeInsets.fromLTRB(15, 10, 15, 5),
                  child: InkWell(
                    onTap: () {
                      indexClicado = index;
                      Navigator.push(context, SlideRightAgainRoute(GatoInfo()));
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: FadeInImage(
                                  placeholder:
                                      AssetImage('lib/assets/loading.gif'),
                                  image: NetworkImage(gatoLista[index]["IMG"]),
                                  fadeInDuration: Duration(milliseconds: 300),
                                  fadeOutDuration: Duration(milliseconds: 300),
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                width: 200,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      gatoLista[index]["NOME"],
                                      style: TextStyle(
                                          fontFamily: "Jost",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25),
                                      softWrap: true,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      gatoLista[index]["RESUMO"],
                                      style: TextStyle(
                                          fontFamily: "Jost", fontSize: 15),
                                      softWrap: true,
                                      maxLines: 2,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: 10),
          )
        ],
      ),
    );
  }
}

class SlideRightAgainRoute extends PageRouteBuilder {
  final Widget page;
  SlideRightAgainRoute(this.page)
      : super(
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionDuration: const Duration(milliseconds: 500),
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

class GatoInfo extends StatelessWidget {
  const GatoInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            iconTheme: IconThemeData(color: Colors.white, shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 1,
              )
            ]),
            expandedHeight: 360,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: [
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
                StretchMode.zoomBackground
              ],
              title: Text(
                gatoLista[indexClicado]["NOME"],
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Jost",
                ),
              ),
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image(
                    image: NetworkImage(gatoLista[indexClicado]["IMG"]),
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0.0, 0.5),
                        end: Alignment.center,
                        colors: <Color>[
                          Color(0x60000000),
                          Color(0x00000000),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: blueScheme.primary,
          ),
          SliverToBoxAdapter(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  gatoLista[indexClicado]["RESUMO"],
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 27,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  gatoLista[indexClicado]["DESC"],
                  style: TextStyle(
                    fontFamily: "Jost",
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  "COMENTÁRIOS",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Jost",
                      fontSize: 25),
                )
              ],
            ),
          ))
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
          title: Row(
            children: [
              Icon(
                Icons.people_alt_rounded,
                color: blueScheme.onPrimary,
                size: 40,
              ),
              SizedBox(
                width: 15,
              ),
              Text(
                "COLABORADORES",
                style:
                    TextStyle(color: blueScheme.onPrimary, fontFamily: "Jost"),
              ),
            ],
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
                                          style:
                                              TextStyle(color: Colors.white)),
                                      TextSpan(
                                          text: "Flutter",
                                          style: TextStyle(
                                              color: blueScheme.primary,
                                              decoration:
                                                  TextDecoration.underline),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              _launchUrl(_urlFlutter);
                                            }),
                                      TextSpan(
                                          text: " e ",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      TextSpan(
                                          text: "Material You",
                                          style: TextStyle(
                                              color: blueScheme.primary,
                                              decoration:
                                                  TextDecoration.underline),
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
                padding: EdgeInsets.fromLTRB(20, 20, 10, 20),
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
                        ElevatedButton.icon(
                          onPressed: () {
                            _launchUrl(_urlEmailDanilo);
                          },
                          icon: Icon(Icons.mail_rounded),
                          label: Text("Email"),
                        )
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
                        ElevatedButton.icon(
                          onPressed: () {
                            _launchUrl(_urlEmailLucca);
                          },
                          icon: Icon(Icons.mail_rounded),
                          label: Text("Email"),
                        )
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
