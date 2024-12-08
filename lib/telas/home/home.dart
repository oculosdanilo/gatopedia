import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/components/dan_icons.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/config/config.dart';
import 'package:gatopedia/telas/home/eu/profile.dart';
import 'package:gatopedia/telas/home/gatos/gatos.dart';
import 'package:gatopedia/telas/index.dart';
import 'package:gatopedia/telas/seminternet.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:material_symbols_icons/symbols.dart';

List<Widget> telasHome = const [Gatos(), Profile(false), Config(false)];
int indexAntigo = 0;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    if (!iniciou) {
      FlutterNativeSplash.remove();
      if (!kIsWeb) {
        connecteo.connectionStream.listen((internet) {
          if (!mounted) return;
          if (!internet) Navigator.push(context, SlideUpRoute(const SemInternet()));
        });
      }
      iniciou = true;
    }
  }

  int paginaSelecionada = 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: paginaSelecionada == 0,
      onPopInvokedWithResult: (poppou, resultado) {
        if (!poppou) {
          setState(() {
            paginaSelecionada = 0;
          });
        }
      },
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: paginaSelecionada,
          onDestinationSelected: (index) {
            setState(() {
              dark = App.themeNotifier.value == ThemeMode.dark;
              paginaSelecionada = index;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: Icon(DanIcons.pawOutline),
              selectedIcon: Icon(IonIcons.paw, color: Theme.of(context).colorScheme.onPrimary, fill: 1),
              label: "Gatos",
            ),
            NavigationDestination(
              icon: const Icon(Symbols.person_rounded, fill: 0),
              selectedIcon: Icon(Symbols.person_rounded, color: Theme.of(context).colorScheme.onPrimary, fill: 1),
              label: "Eu",
            ),
            NavigationDestination(
              icon: const Icon(Symbols.settings_rounded, fill: 0),
              selectedIcon: Icon(Symbols.settings_rounded, color: Theme.of(context).colorScheme.onPrimary, fill: 1),
              label: "Configurações",
            )
          ],
        ),
        body: PageTransitionSwitcher(
          reverse: paginaSelecionada < indexAntigo,
          transitionBuilder: (child, animation, secondAnimation) => SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          ),
          duration: const Duration(milliseconds: 200),
          child: telasHome[paginaSelecionada],
        ),
      ),
    );
  }
}
