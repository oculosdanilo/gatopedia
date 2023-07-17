import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gatopedia/loginScreen/seminternet.dart';
import 'package:gatopedia/loginScreen/login/form.dart';
import 'package:gatopedia/update.dart';

List listaTemImagem = [];
late String username;
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  final SharedPreferences pref = await SharedPreferences.getInstance();
  if (pref.getBool("dark") ??
      PlatformDispatcher.instance.platformBrightness == Brightness.dark) {
    runApp(const App(ThemeMode.dark));
  } else {
    runApp(const App(ThemeMode.light));
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class App extends StatefulWidget {
  static late final ValueNotifier<ThemeMode> themeNotifier;
  final ThemeMode temaInicial;
  const App(this.temaInicial, {super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    App.themeNotifier = ValueNotifier(widget.temaInicial);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: App.themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: temaLight(context),
          darkTheme: temaDark(),
          themeMode: currentMode,
          home: const Gatopedia(),
        );
      },
    );
  }

  ThemeData temaLight(BuildContext context) {
    return ThemeData(
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
            color: blueSchemeL.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            width: 3,
            color: blueSchemeL.error,
          ),
        ),
      ),
      brightness: Brightness.light,
      colorSchemeSeed: const Color(0xff000080),
      useMaterial3: true,
    );
  }

  ThemeData temaDark() {
    return ThemeData(
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
    );
  }
}

class Gatopedia extends StatefulWidget {
  const Gatopedia({super.key});

  @override
  State<Gatopedia> createState() {
    return _GatopediaState();
  }
}

class _GatopediaState extends State<Gatopedia>
    with SingleTickerProviderStateMixin {
  final miau = AudioPlayer();
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  pegarImagens() async {
    await Firebase.initializeApp();
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users/");
    DataSnapshot userinfo = await ref.get();
    int i = 0;
    while (i < userinfo.children.length) {
      if (((userinfo.children).toList()[i].value as Map)["img"] != null) {
        setState(() {
          listaTemImagem.add(
            "${(userinfo.children.map((i) => i)).toList()[i].key}",
          );
        });
      }
      i++;
    }
  }

  _adaptarTema() async {}

  checarUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;

    final response = await http.get(
      Uri.parse(
        "https://api.github.com/repos/oculosdanilo/gatopedia/releases/latest",
      ),
    );
    Map<String, dynamic> versaoAtt = jsonDecode(response.body);
    debugPrint(versaoAtt["tag_name"]);
    if (!mounted) return;
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

  @override
  void initState() {
    super.initState();
    pegarImagens();
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
    if (!kDebugMode) {
      checarUpdate();
    }
    _adaptarTema();
  }

  void _play() {
    miau.setAsset("lib/assets/meow.mp3");
    miau.play();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.easeIn,
                  duration: const Duration(seconds: 1),
                  builder:
                      (BuildContext context, double opacity, Widget? child) {
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
