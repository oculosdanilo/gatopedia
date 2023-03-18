// ignore_for_file: import_of_legacy_library_into_null_safe, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_cache/just_audio_cache.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:gatopedia/main.dart';
import 'package:gatopedia/info.dart';

final Uri _urlCList = Uri.parse(
    'http://etec199-2023-danilolima.atwebpages.com/2022/1103/commentListar.php');
final Uri _urlGatopediaGit =
    Uri.parse('https://github.com/oculosdanilo/gatopedia');
final Uri _urlGatopediaGitLatest =
    Uri.parse('https://github.com/oculosdanilo/gatopedia/releases');

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
                      "Já vai? ;(",
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
              NavigationDestination(icon: iconeConfig, label: "Configurações")
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
                  backgroundColor: Theme.of(context).colorScheme.background,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      "Configurações",
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
                                "Versão: $version ($buildNumber)",
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
                                "Versões",
                                style: TextStyle(fontFamily: "Jost"),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                _launchUrl(Uri.parse(
                                    "https://etec199-danilolima.epizy.com/2023/0318/"));
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

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
