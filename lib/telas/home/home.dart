import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/components/dan_icons.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/config/config.dart';
import 'package:gatopedia/telas/home/eu/profile.dart';
import 'package:gatopedia/telas/home/gatos/gatos.dart';
import 'package:gatopedia/telas/index.dart';
import 'package:gatopedia/telas/seminternet.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:material_symbols_icons/symbols.dart';

int indexAntigo = 0;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Widget> telasHome = const [Gatos(EdgeInsets.zero), Profile(false), Config(false)];

  @override
  void initState() {
    super.initState();
    if (!iniciouInternet) {
      FlutterNativeSplash.remove();
      if (!kIsWeb) {
        connecteo.connectionStream.listen((internet) {
          if (!mounted) return;
          if (!internet) Navigator.push(context, SlideUpRoute(const SemInternet()));
        });
      }
      iniciouInternet = true;
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
              paginaSelecionada = index;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(DanIcons.pawOutline),
              selectedIcon: Icon(IonIcons.paw, color: Theme.of(context).colorScheme.onPrimary, fill: 1),
              label: AppLocalizations.of(context).gatos_title,
            ),
            NavigationDestination(
              icon: const Icon(Symbols.person_rounded, fill: 0),
              selectedIcon: Icon(Symbols.person_rounded, color: Theme.of(context).colorScheme.onPrimary, fill: 1),
              label: AppLocalizations.of(context).profile_title,
            ),
            NavigationDestination(
              icon: const Icon(Symbols.settings_rounded, fill: 0),
              selectedIcon: Icon(Symbols.settings_rounded, color: Theme.of(context).colorScheme.onPrimary, fill: 1),
              label: AppLocalizations.of(context).config_title,
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
