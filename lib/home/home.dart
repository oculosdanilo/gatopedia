import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:gatopedia/home/config/config.dart';
import 'package:gatopedia/home/gatos/gatos.dart';
import 'package:gatopedia/home/eu/profile.dart';
import 'package:gatopedia/main.dart';

List<Widget> telasHome = const [GatoLista(), Profile(false), Config()];
int indexAntigo = 0;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  HomeState createState() {
    return HomeState();
  }
}

class HomeState extends State {
  String appName = "";
  String packageName = "";
  String version = "";
  String buildNumber = "";

  @override
  void initState() {
    setState(() {
      tabIndex = 0;
    });
    super.initState();
  }

  int paginaSelecionada = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var dialogo = await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Já vai? ;(",
                      style: TextStyle(
                        fontFamily: "Jost",
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                content: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text("Tem certeza que deseja sair?")]),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        dark = App.themeNotifier.value == ThemeMode.dark;
                      });
                      Navigator.pop(context, false);
                    },
                    child: const Text('CANCELAR'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        dark = App.themeNotifier.value == ThemeMode.dark;
                      });
                      Navigator.pop(context, true);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            });
        if (dialogo) {
          return true;
        } else if (dialogo == null || !dialogo) {
          return false;
        } else {
          return false;
        }
      },
      child: Scaffold(
        bottomNavigationBar: NavigationBar(
          selectedIndex: paginaSelecionada,
          onDestinationSelected: (index) {
            setState(() {
              dark = App.themeNotifier.value == ThemeMode.dark;
              paginaSelecionada = index;
              tabIndex = 0;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Ionicons.paw_outline),
              selectedIcon: Icon(
                Ionicons.paw,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: "Gatos",
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outlined),
              selectedIcon: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: "Eu",
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: "Configurações",
            )
          ],
        ),
        body: PageTransitionSwitcher(
          reverse: paginaSelecionada < indexAntigo,
          transitionBuilder: (child, animation, secondAnimation) =>
              SharedAxisTransition(
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
