import 'dart:async';
import 'dart:io';

import 'package:connecteo/connecteo.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gatopedia/firebase_options.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/screens/home/config/config.dart';
import 'package:gatopedia/screens/home/gatos/forum/forum.dart';
import 'package:gatopedia/screens/home/home.dart';
import 'package:gatopedia/screens/index.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? username;
bool internet = true;
final blueScheme = ColorScheme.fromSeed(seedColor: const Color(0xff000080), brightness: Brightness.dark);
final blueSchemeL = ColorScheme.fromSeed(seedColor: const Color(0xff000080), brightness: Brightness.light);
dynamic mensagem;

final connecteo = ConnectionChecker();

void main() async {
  bool br() {
    final a = Locale(Platform.localeName.split("_")[0]);
    return a.languageCode == "pt";
  }

  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  await FirebaseAppCheck.instance.activate();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await ignoreException(ArgumentError);
  await ignoreException(NetworkImageLoadException);

  final SharedPreferences pref = await SharedPreferences.getInstance();
  final userSalvo = pref.getString("username") != null;
  if (userSalvo) username = pref.getString("username");

  scrollSalvo = pref.getDouble("scrollSalvo") ?? 0;

  final startsDark = pref.getString("tema") ?? "sis";

  Locale localeInicial; // = Locale(pref.getString("locale") ?? (br() ? "pt" : "en"));

  if (Platform.isIOS) {
    localeInicial = Locale(Platform.localeName.split("_")[0]);
  } else {
    localeInicial = Locale(pref.getString("locale") ?? (br() ? "pt" : "en"));
  }

  runApp(
    App(
      stringToTemas[startsDark]!,
      localeInicial,
      !userSalvo ? const Index(true) : const Home(),
    ),
  );
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}

class App extends StatefulWidget {
  static late final ValueNotifier<ThemeMode> themeNotifier;
  static late final ValueNotifier<Locale> localeNotifier;
  final ThemeMode temaInicial;
  final Locale localeInicial;
  final Widget inicio;

  const App(this.temaInicial, this.localeInicial, this.inicio, {super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    App.themeNotifier = ValueNotifier(widget.temaInicial);
    App.localeNotifier = ValueNotifier(widget.localeInicial);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: App.themeNotifier,
      builder: (c, currentMode, w) {
        return ValueListenableBuilder<Locale>(
            valueListenable: App.localeNotifier,
            builder: (c, currentLocale, w) {
              return MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: currentLocale,
                debugShowCheckedModeBanner: false,
                theme: temaLight(),
                darkTheme: temaDark(),
                themeMode: currentMode,
                home: widget.inicio,
                builder: (c, w) {
                  return Banner(
                    message: AppLocalizations.of(c).internal,
                    location: BannerLocation.bottomEnd,
                    color: Theme.of(c).colorScheme.primary,
                    textStyle:
                        TextStyle(color: Theme.of(c).colorScheme.onPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                    child: w,
                  );
                },
              );
            });
      },
    );
  }

  ThemeData temaLight() {
    return ThemeData(
      navigationBarTheme: NavigationBarThemeData(indicatorColor: blueSchemeL.primary),
      appBarTheme: AppBarTheme(backgroundColor: blueSchemeL.primary),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(width: 2, color: Colors.blue[900]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: blueSchemeL.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(width: 3, color: blueSchemeL.error),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(width: 2, color: blueScheme.outline),
        ),
      ),
      brightness: Brightness.light,
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      colorSchemeSeed: const Color(0xff000080),
      useMaterial3: true,
      textTheme: temaBase(ThemeMode.light, context).textTheme.apply(fontFamily: "Jost"),
    );
  }

  ThemeData temaDark() {
    return ThemeData(
      navigationBarTheme: NavigationBarThemeData(indicatorColor: blueScheme.primary),
      appBarTheme: AppBarTheme(backgroundColor: blueScheme.surface),
      sliderTheme: const SliderThemeData(year2023: false),
      progressIndicatorTheme: const ProgressIndicatorThemeData(year2023: false),
      inputDecorationTheme: InputDecorationTheme(
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(width: 2, color: blueScheme.outline),
        ),
      ),
      brightness: Brightness.dark,
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      colorSchemeSeed: const Color(0xff000080),
      useMaterial3: true,
      textTheme: temaBase(ThemeMode.dark, context).textTheme.apply(fontFamily: "Jost"),
    );
  }
}

ThemeData temaBase(ThemeMode mode, BuildContext context) {
  return ThemeData(
      colorScheme: mode == ThemeMode.system
          ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
              ? blueScheme
              : blueSchemeL
          : mode == ThemeMode.dark
              ? blueScheme
              : blueSchemeL);
}

void checarUpdate(BuildContext context) {
  InAppUpdate.checkForUpdate().then((val) async {
    if (val.updateAvailability == UpdateAvailability.updateAvailable) {
      if (val.updatePriority > 3) {
        await InAppUpdate.performImmediateUpdate();
      } else if (val.updatePriority > 0) {
        try {
          await InAppUpdate.startFlexibleUpdate();
          InAppUpdate.completeFlexibleUpdate();
        } on PlatformException catch (e) {
          Fluttertoast.showToast(msg: "Atualização falhou! Código de erro: ${e.code}");
        }
      }
    } else {
      Fluttertoast.showToast(msg: "Atualizado!");
    }
  });
}

Future<void> ignoreException(Type exceptionType) async {
  final originalOnError = FlutterError.onError!;
  FlutterError.onError = (FlutterErrorDetails details) {
    final currentError = details.exception.runtimeType;
    if (currentError == exceptionType) {
      return;
    }
    originalOnError(details);
  };
}
