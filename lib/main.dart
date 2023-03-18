// ignore_for_file: use_build_context_synchronously, import_of_legacy_library_into_null_safe
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_cache/just_audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:gatopedia/seminternet.dart';
import 'package:gatopedia/form.dart';

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
                    'Gatopédia!',
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
