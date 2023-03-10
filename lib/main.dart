// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_cache/just_audio_cache.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final Uri _urlFlutter = Uri.parse('https://flutter.dev');
final Uri _urlMaterialYou = Uri.parse('https://m3.material.io');
final Uri _urlGatopediaGit =
    Uri.parse('https://github.com/oculosdanilo/gatopedia');
final Uri _urlGatopediaGitLatest =
    Uri.parse('https://github.com/oculosdanilo/gatopedia/releases');
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
final Uri _urlCAdd = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/commentAdd.php');
final Uri _urlCDelete = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/commentDelete.php');
String urlMeow =
    "https://drive.google.com/uc?export=download&id=1Sn1NxfA5S1_KAwdet5bEf9ocI4qJ4dEy";
String buttonText = "Cadastrar/Entrar";
bool esconderSenha = true;
Icon iconeOlho = const Icon(Icons.visibility_rounded);
String username = "";
dynamic gatoLista = "";
dynamic cLista;
int indexClicado = 0;
dynamic cListaTamanho;
bool internet = true;
Icon iconeGato = const Icon(Icons.pets_rounded);
Icon iconeConfig = const Icon(Icons.settings_outlined);
ColorScheme blueScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xff000080), brightness: Brightness.dark);

void main() async {
  runApp(const App());
}

class App extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              snackBarTheme:
                  const SnackBarThemeData(behavior: SnackBarBehavior.floating),
              inputDecorationTheme: InputDecorationTheme(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(width: 2, color: blueScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                  borderSide: BorderSide(width: 2, color: Colors.blue[900]!),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      width: 3, color: Theme.of(context).colorScheme.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide(
                      width: 3, color: Theme.of(context).colorScheme.error),
                ),
              ),
              brightness: Brightness.light,
              colorSchemeSeed: const Color(0xff000080),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              snackBarTheme:
                  const SnackBarThemeData(behavior: SnackBarBehavior.floating),
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
            themeMode: currentMode,
            home: const Gatopedia(),
          );
        });
  }
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

  _read() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/dark.txt');
      String text = await file.readAsString();
      if (text == "dark") {
        App.themeNotifier.value = ThemeMode.dark;
      } else {
        App.themeNotifier.value = ThemeMode.light;
      }
      if (kDebugMode) {
        print(text);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Couldn't read file");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _play();
    // ignore: unused_local_variable
    var listener = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.disconnected:
          internet = false;
          Navigator.push(context, SlideUpRoute(const SemInternet()));
          break;
        case InternetConnectionStatus.connected:
          break;
      }
    });
    _read();
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
                    'Gatop??dia!',
                    textStyle: const TextStyle(
                        fontSize: 35,
                        fontFamily: "Jost",
                        fontWeight: FontWeight.bold),
                    speed: const Duration(milliseconds: 70),
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

class SemInternet extends StatefulWidget {
  const SemInternet({super.key});

  @override
  SemInternetState createState() {
    return SemInternetState();
  }
}

class SemInternetState extends State {
  // ignore: prefer_typing_uninitialized_variables
  var listener;

  @override
  void initState() {
    super.initState();
    listener = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.disconnected:
          break;
        case InternetConnectionStatus.connected:
          internet = true;
          Navigator.of(context, rootNavigator: true).pop();
          break;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Container(
            margin: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 170,
                ),
                Text(
                  "Sem internet",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Jost",
                      fontSize: 30),
                ),
                Text("Aguardando conex??o"),
                SizedBox(
                  height: 30,
                ),
                CircularProgressIndicator(
                  value: null,
                )
              ],
            ),
          ),
        ),
        onWillPop: () async {
          if (internet) {
            return true;
          } else {
            return false;
          }
        });
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
    }

    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          children: [
            SizedBox(
              width: 300,
              child: TextFormField(
                autofillHints: const [AutofillHints.username],
                controller: txtControllerLogin,
                onChanged: (value) {
                  setState(() {
                    txtFieldLenght = value.length;
                    if (value.length <= 3 || value.length > 25) {
                      mudarCor(Theme.of(context).colorScheme.error);
                    } else {
                      mudarCor(Theme.of(context).colorScheme.primary);
                    }
                  });
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Obrigat??rio';
                  } else if (!value.contains(RegExp(r'^[a-zA-Z0-9._]+$'))) {
                    return 'Caractere(s) inv??lido(s)!';
                  } else if (value.length <= 3) {
                    return "Nome muito pequeno!";
                  } else if (value.contains(RegExp(r'^[0-9]+$'))) {
                    return "s?? n??meros? s??rio?";
                  } else if (value.length > 25) {
                    return "Nome de usu??rio muito grande!";
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
                          Navigator.push(
                              context, SlideRightRoute(const GatoLista()));
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
                                  "Senha incorreta: usu??rio j?? existe!",
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
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  saveDark() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/dark.txt');
    const text = "dark";
    await file.writeAsString(text);
    if (kDebugMode) {
      print(text);
    }
  }

  saveLight() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/dark.txt');
    const text = "light";
    await file.writeAsString(text);
    if (kDebugMode) {
      print(text);
    }
  }

  _pegarVersao() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  void _play() async {
    await audioPlayer.dynamicSet(url: urlMeow, preload: true);
    audioPlayer.play();
  }

  Future<void> _navigateAndDisplaySelection(BuildContext context, index) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      SlideRightAgainRoute(const GatoInfo()),
    );

    // When a BuildContext is used from a StatefulWidget, the mounted property
    // must be checked after an asynchronous gap.
    if (!mounted) return;

    // After the Selection Screen returns a result, hide any previous snackbars
    // and show the new result.
    if (result != null) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text('$result'), behavior: SnackBarBehavior.floating));

      indexClicado = index;
      var map = <String, String>{};
      int indexMais1 = indexClicado + 1;
      map['id'] = "$indexMais1";
      final response = await http.post(_urlCList, body: map);
      cLista = jsonDecode(response.body);
      cListaTamanho = cLista.length;

      _navigateAndDisplaySelection(context, index);
    }
  }

  @override
  void initState() {
    _pegarVersao();
    super.initState();
  }

  int paginaSelecionada = 0;
  bool _dark = App.themeNotifier.value == ThemeMode.dark ? true : false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var dialogo = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "J?? vai? ;(",
                      style: TextStyle(
                          fontFamily: "Jost", fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                content: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Text("Tem certeza que deseja sair?")]),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('CANCELAR'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('OK'),
                  ),
                ],
              );
            });
        if (dialogo) {
          return true;
        } else {
          return false;
        }
      },
      child: Scaffold(
          bottomNavigationBar: NavigationBar(
            selectedIndex: paginaSelecionada,
            onDestinationSelected: (index) {
              setState(() {
                if (index == 0) {
                  iconeGato = const Icon(Icons.pets_rounded);
                  iconeConfig = const Icon(Icons.settings_outlined);
                } else {
                  iconeConfig = const Icon(Icons.settings_rounded);
                  iconeGato = const Icon(Icons.pets_outlined);
                }
                paginaSelecionada = index;
              });
            },
            destinations: <NavigationDestination>[
              NavigationDestination(icon: iconeGato, label: "Gatos"),
              NavigationDestination(icon: iconeConfig, label: "Configura????es")
            ],
          ),
          body: [
            CustomScrollView(
              slivers: [
                SliverAppBar.medium(
                  iconTheme: IconThemeData(
                      color: Theme.of(context).colorScheme.onPrimary),
                  expandedHeight: 120,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      "@$username",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontFamily: "Jost"),
                    ),
                    background: Container(
                      alignment: Alignment.centerRight,
                      margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: IconButton(
                        icon: const Icon(
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return SizedBox(
                      height: 140,
                      child: Card(
                        margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
                        child: InkWell(
                          onTap: () async {
                            indexClicado = index;
                            var map = <String, String>{};
                            int indexMais1 = indexClicado + 1;
                            map['id'] = "$indexMais1";
                            final response =
                                await http.post(_urlCList, body: map);
                            cLista = jsonDecode(response.body);
                            cListaTamanho = cLista.length;

                            _navigateAndDisplaySelection(context, index);
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: FadeInImage(
                                        placeholder: const AssetImage(
                                            'lib/assets/loading.gif'),
                                        image: NetworkImage(
                                            gatoLista[index]["IMG"]),
                                        fadeInDuration:
                                            const Duration(milliseconds: 300),
                                        fadeOutDuration:
                                            const Duration(milliseconds: 300),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            gatoLista[index]["NOME"],
                                            style: const TextStyle(
                                                fontFamily: "Jost",
                                                fontWeight: FontWeight.bold,
                                                fontSize: 25),
                                            softWrap: true,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            gatoLista[index]["RESUMO"],
                                            style: const TextStyle(
                                                fontFamily: "Jost",
                                                fontSize: 15),
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
            CustomScrollView(
              slivers: [
                SliverAppBar.medium(
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      "Configura????es",
                      style: TextStyle(
                          fontFamily: "Jost",
                          color: Theme.of(context).colorScheme.onBackground),
                    ),
                    centerTitle: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: [
                        SwitchListTile(
                          secondary: const Icon(Icons.dark_mode_rounded),
                          title: const Text(
                            "Modo escuro",
                            style: TextStyle(fontFamily: "Jost", fontSize: 20),
                          ),
                          subtitle: const Text(
                            "Lindo como gatos pretos!",
                            style: TextStyle(fontFamily: "Jost"),
                          ),
                          value: _dark,
                          onChanged: (bool value) {
                            if (value) {
                              App.themeNotifier.value = ThemeMode.dark;
                              saveDark();
                            } else {
                              App.themeNotifier.value = ThemeMode.light;
                              saveLight();
                            }
                            setState(() {
                              _dark = value;
                            });
                          },
                        ),
                        const Divider(),
                        Container(
                          margin: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Sobre o aplicativo",
                                style:
                                    TextStyle(fontFamily: "Jost", fontSize: 25),
                              ),
                              Text(
                                packageName,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                "Vers??o: $version ($buildNumber)",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                _launchUrl(_urlGatopediaGit);
                              },
                              icon: const Icon(AntDesign.github),
                              label: const Text(
                                "Github",
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
                                "Vers??es",
                                style: TextStyle(fontFamily: "Jost"),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                _launchUrl(Uri.parse("https://example.com"));
                              },
                              icon: const Icon(Icons.public),
                              label: const Text(
                                "Web",
                                style: TextStyle(fontFamily: "Jost"),
                              ),
                            )
                            /* IconButton(
                                onPressed: () {
                                  _launchUrl(_urlGatopediaGit);
                                },
                                icon: const Icon(AntDesign.github)),
                            IconButton(
                                onPressed: () {
                                  _launchUrl(_urlGatopediaGitLatest);
                                },
                                icon: const Icon(Icons.file_download)) */
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          ][paginaSelecionada]),
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

class GatoInfo extends StatefulWidget {
  const GatoInfo({super.key});

  @override
  GatoInfoState createState() {
    return GatoInfoState();
  }
}

class GatoInfoState extends State {
  final txtControllerC = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (cLista.isNotEmpty) {
      return Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar.large(
            iconTheme: const IconThemeData(color: Colors.white, shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 1,
              )
            ]),
            expandedHeight: 360,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                gatoLista[indexClicado]["NOME"],
                style: const TextStyle(
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    gatoLista[indexClicado]["RESUMO"],
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 27,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    gatoLista[indexClicado]["DESC"],
                    style: const TextStyle(
                      fontFamily: "Jost",
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "COMENT??RIOS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Jost",
                        fontSize: 25),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 7,
                          child: TextField(
                            controller: txtControllerC,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          flex: 5,
                          child: FilledButton(
                            onPressed: () async {
                              if (txtControllerC.text != "") {
                                var map = <String, String>{};
                                map['id'] = "${indexClicado + 1}";
                                map['username'] = username;
                                map['comentario'] = txtControllerC.text;
                                final response =
                                    await http.post(_urlCAdd, body: map);
                                /* Flushbar(
                                message: response.body,
                                duration: Duration(seconds: 2),
                                margin: EdgeInsets.all(20),
                                flushbarStyle: FlushbarStyle.FLOATING,
                                borderRadius: BorderRadius.circular(50),
                              ).show(context); */
                                Navigator.pop(context, response.body);
                              }
                            },
                            child: const Text("COMENTAR"),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              return SizedBox(
                height: 130,
                child: Card(
                  margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: const Image(
                            image: AssetImage("lib/assets/user.webp"),
                            width: 50,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          flex: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                '@${cLista[index]["USERNAME"]}',
                                style: const TextStyle(
                                    fontFamily: "Jost",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                                softWrap: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                cLista[index]["COMENTARIO"],
                                style: const TextStyle(
                                    fontFamily: "Jost", fontSize: 15),
                                softWrap: true,
                                maxLines: 3,
                              )
                            ],
                          ),
                        ),
                        cLista[index]["USERNAME"] == username
                            ? Ink(
                                decoration: ShapeDecoration(
                                  color: blueScheme.errorContainer,
                                  shape: const CircleBorder(),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.white,
                                  onPressed: () async {
                                    var dialogo = await showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Flexible(
                                                    child: Text(
                                                      "Tem certeza que deseja deletar esse coment??rio? Ele sumir?? para sempre! (muito tempo)",
                                                      style: TextStyle(
                                                          fontSize: 15),
                                                    ),
                                                  )
                                                ]),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text('CANCELAR'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          );
                                        });
                                    if (dialogo) {
                                      final map = <String, String>{};
                                      map['id'] = cLista[index]["ID"];
                                      final response = await http
                                          .post(_urlCDelete, body: map);
                                      Navigator.pop(context, response.body);
                                    }
                                  },
                                ))
                            : const Text("")
                      ],
                    ),
                  ),
                ),
              );
            }, childCount: cListaTamanho),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 25,
            ),
          )
        ]),
      );
    } else {
      return Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar.large(
            iconTheme: const IconThemeData(color: Colors.white, shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 1,
              )
            ]),
            expandedHeight: 360,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                gatoLista[indexClicado]["NOME"],
                style: const TextStyle(
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    gatoLista[indexClicado]["RESUMO"],
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 27,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    gatoLista[indexClicado]["DESC"],
                    style: const TextStyle(
                      fontFamily: "Jost",
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text(
                    "COMENT??RIOS",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "Jost",
                        fontSize: 25),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 7,
                          child: TextField(
                            controller: txtControllerC,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          flex: 5,
                          child: FilledButton(
                            onPressed: () async {
                              if (txtControllerC.text != "") {
                                var map = <String, String>{};
                                map['id'] = "${indexClicado + 1}";
                                map['username'] = username;
                                map['comentario'] = txtControllerC.text;
                                final response =
                                    await http.post(_urlCAdd, body: map);
                                /* Flushbar(
                                message: response.body,
                                duration: Duration(seconds: 2),
                                margin: EdgeInsets.all(20),
                                flushbarStyle: FlushbarStyle.FLOATING,
                                borderRadius: BorderRadius.circular(50),
                              ).show(context); */
                                Navigator.pop(context, response.body);
                              }
                            },
                            child: const Text("COMENTAR"),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        "Nenhum coment??rio (ainda...)",
                        style: TextStyle(fontFamily: "Jost"),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
              ],
            ),
          ),
        ]),
      );
    }
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
              const SizedBox(
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "Sobre o projeto",
                                    style: TextStyle(
                                        fontFamily: "Jost",
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              content: RichText(
                                text: TextSpan(
                                    style: const TextStyle(
                                        fontFamily: "Jost", fontSize: 17),
                                    children: [
                                      TextSpan(
                                          text: "Produzido com ",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground)),
                                      TextSpan(
                                          text: "Flutter",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              decoration:
                                                  TextDecoration.underline),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              _launchUrl(_urlFlutter);
                                            }),
                                      TextSpan(
                                          text: " e ",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground)),
                                      TextSpan(
                                          text: "Material You",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
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
              surfaceTintColor: Theme.of(context).colorScheme.onBackground,
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const Image(
                        image: AssetImage('lib/assets/danilo.jpg'),
                        width: 130,
                      ),
                    ),
                    const SizedBox(
                      width: 17,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Danilo Lima",
                            style: TextStyle(
                                fontFamily: "Jost",
                                fontWeight: FontWeight.bold,
                                fontSize: 25),
                          ),
                          const SizedBox(
                            height: 17,
                          ),
                          const Text(
                            "??? Design e programa????o",
                            style: TextStyle(fontFamily: "Jost"),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _launchUrl(_urlEmailDanilo);
                            },
                            icon: const Icon(Icons.mail_rounded),
                            label: const Text("Email"),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              surfaceTintColor: Theme.of(context).colorScheme.onBackground,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const Image(
                        image: AssetImage('lib/assets/lucca.png'),
                        width: 130,
                      ),
                    ),
                    const SizedBox(
                      width: 17,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Juliana Leal \n(Lucca)",
                            style: TextStyle(
                                fontFamily: "Jost",
                                fontWeight: FontWeight.bold,
                                fontSize: 25),
                          ),
                          const SizedBox(
                            height: 17,
                          ),
                          const Text(
                            "??? Idealiza????o e pesquisas",
                            style: TextStyle(fontFamily: "Jost"),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _launchUrl(_urlEmailLucca);
                            },
                            icon: const Icon(Icons.mail_rounded),
                            label: const Text("Email"),
                          )
                        ],
                      ),
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
