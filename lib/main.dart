import 'package:connecteo/connecteo.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_size/flutter_keyboard_size.dart';
import 'package:gatopedia/firebase_options.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/index.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? username;
bool internet = true;
final blueScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xff000080),
  brightness: Brightness.dark,
);
final blueSchemeL = ColorScheme.fromSeed(
  seedColor: const Color(0xff000080),
  brightness: Brightness.light,
);
dynamic mensagem;
DataSnapshot? snapshotForum;

final connecteo = ConnectionChecker();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  final SharedPreferences pref = await SharedPreferences.getInstance();
  final salvo = pref.getString("username") != null;
  if (salvo) username = pref.getString("username");
  if (pref.getBool("dark") ?? PlatformDispatcher.instance.platformBrightness == Brightness.dark) {
    runApp(App(ThemeMode.dark, !salvo ? const Index(true) : const Home()));
  } else {
    runApp(App(ThemeMode.light, !salvo ? const Index(true) : const Home()));
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
  final Widget inicio;

  const App(this.temaInicial, this.inicio, {super.key});

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
      builder: (c, currentMode, w) {
        return KeyboardSizeProvider(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: temaLight(),
            darkTheme: temaDark(),
            themeMode: currentMode,
            home: widget.inicio,
          ),
        );
      },
    );
  }

  ThemeData temaLight() {
    return ThemeData(
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: blueSchemeL.primary,
      ),
      appBarTheme: AppBarTheme(backgroundColor: blueSchemeL.primary),
      inputDecorationTheme: InputDecorationTheme(
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 2,
            color: blueScheme.outline,
          ),
        ),
      ),
      brightness: Brightness.light,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      colorSchemeSeed: const Color(0xff000080),
      useMaterial3: true,
      textTheme: GoogleFonts.jostTextTheme(temaBase(ThemeMode.light).textTheme),
    );
  }

  ThemeData temaDark() {
    return ThemeData(
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: blueScheme.primary,
      ),
      appBarTheme: AppBarTheme(backgroundColor: blueScheme.surface),
      inputDecorationTheme: InputDecorationTheme(
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            width: 2,
            color: blueScheme.outline,
          ),
        ),
      ),
      brightness: Brightness.dark,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      colorSchemeSeed: const Color(0xff000080),
      useMaterial3: true,
      textTheme: GoogleFonts.jostTextTheme(temaBase(ThemeMode.dark).textTheme),
    );
  }
}

ThemeData temaBase(ThemeMode mode) {
  return ThemeData(
    colorScheme: mode == ThemeMode.dark ? blueScheme : blueSchemeL,
  );
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
          transitionsBuilder:
              (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) =>
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
