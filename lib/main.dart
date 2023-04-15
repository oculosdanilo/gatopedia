// ignore_for_file: use_build_context_synchronously
import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'loginScreen/seminternet.dart';
import 'loginScreen/form.dart';

String urlMeow =
    "https://drive.google.com/uc?export=download&id=1Sn1NxfA5S1_KAwdet5bEf9ocI4qJ4dEy";
final Uri _urlVersao = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/versao.php');
String buttonText = "Cadastrar/Entrar";
bool esconderSenha = true;
Icon iconeOlho = const Icon(Icons.visibility_rounded);
String username = "";
dynamic gatoLista = "";
dynamic cLista;
int indexClicado = 0;
dynamic cListaTamanho;
bool internet = true;
ColorScheme blueScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xff000080),
  brightness: Brightness.dark,
);
ColorScheme blueSchemeL = ColorScheme.fromSeed(
  seedColor: const Color(0xff000080),
  brightness: Brightness.light,
);
dynamic mensagem;
DataSnapshot? snapshot;
Map<String, String> listaDownload = {};

void main() {
  runApp(const App());
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class App extends StatelessWidget {
  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.dark,
  );
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          theme: ThemeData(
            navigationBarTheme: NavigationBarThemeData(
              indicatorColor: blueSchemeL.primary,
            ),
            appBarTheme: AppBarTheme(backgroundColor: blueSchemeL.primary),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  width: 2,
                  color: blueScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                borderSide: BorderSide(
                  width: 2,
                  color: Colors.blue[900]!,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  width: 3,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  width: 3,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            brightness: Brightness.light,
            colorSchemeSeed: const Color(0xff000080),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            navigationBarTheme: NavigationBarThemeData(
              indicatorColor: blueScheme.primary,
            ),
            appBarTheme: AppBarTheme(backgroundColor: blueScheme.background),
            snackBarTheme: const SnackBarThemeData(
              behavior: SnackBarBehavior.floating,
            ),
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                  width: 2,
                  color: blueScheme.outline,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                borderSide: BorderSide(
                  width: 2,
                  color: blueScheme.primary,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  width: 3,
                  color: blueScheme.error,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  width: 3,
                  color: blueScheme.error,
                ),
              ),
            ),
            brightness: Brightness.dark,
            colorSchemeSeed: const Color(0xff000080),
            useMaterial3: true,
          ),
          themeMode: currentMode,
          home: const Gatopedia(),
        );
      },
    );
  }
}

class Gatopedia extends StatefulWidget {
  const Gatopedia({super.key});

  @override
  GatopediaState createState() {
    return GatopediaState();
  }
}

class GatopediaState extends State with SingleTickerProviderStateMixin {
  final miau = AudioPlayer();
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  _read() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? text = prefs.getString("dark");
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

  checarUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;

    final response = await http.post(_urlVersao);
    List versoes = jsonDecode(response.body);
    if (version != versoes.first['VERSAO']) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            icon: const Icon(Icons.info_rounded),
            title: const Text("Nova versão disponível"),
            content: Text(
                "A versão ${versoes.first['VERSAO']} acabou de sair! Quentinha do forno"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("ME LEMBRE DEPOIS"),
              ),
              ElevatedButton(
                onPressed: () {
                  try {
                    OtaUpdate()
                        .execute(
                            'https://github.com/oculosdanilo/gatopedia/releases/latest/download/app-release.apk')
                        .listen(
                      (OtaEvent event) {
                        // ignore: unused_local_variable
                        OtaEvent currentEvent;
                        setState(() => currentEvent = event);
                      },
                    );
                  } catch (e) {
                    debugPrint('Failed to make OTA update. Details: $e');
                  }
                },
                child: const Text("ATUALIZAR"),
              )
            ],
          );
        },
      );
    } else {
      debugPrint("atualizado");
    }
  }

  @override
  void initState() {
    super.initState();
    _play();
    if (!kIsWeb) {
      InternetConnectionChecker().onStatusChange.listen((status) {
        switch (status) {
          case InternetConnectionStatus.disconnected:
            internet = false;
            Navigator.push(context, SlideUpRoute(const SemInternet()));
            break;
          case InternetConnectionStatus.connected:
            break;
        }
      });
    }
    _read();
    if (!kDebugMode) {
      checarUpdate();
    }
  }

  void _play() {
    miau.setAsset("lib/assets/meow.mp3");
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
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                curve: Curves.easeIn,
                duration: const Duration(seconds: 1),
                builder: (BuildContext context, double opacity, Widget? child) {
                  return Opacity(
                    opacity: opacity,
                    child: const Image(
                      image: AssetImage('lib/assets/icon.png'),
                      width: 270,
                    ),
                  );
                },
              ),
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Gatopédia!',
                    textStyle: const TextStyle(
                      fontSize: 35,
                      fontFamily: "Jost",
                      fontWeight: FontWeight.bold,
                    ),
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
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
                reverseCurve: Curves.fastOutSlowIn,
              ),
            ),
            child: child,
          ),
        );
}
