import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:gatopedia/home/home.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';

final Uri _urlGatopediaGit =
    Uri.parse('https://github.com/oculosdanilo/gatopedia');
final Uri _urlGatopediaGitLatest =
    Uri.parse('https://github.com/oculosdanilo/gatopedia/releases');
String appName = "";
String packageName = "";
String version = "";
String buildNumber = "";
bool dark = App.themeNotifier.value == ThemeMode.dark ? true : false;

class Config extends StatefulWidget {
  const Config({super.key});
  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  _pegarVersao() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  _saveDark() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dark", true);
  }

  _saveLight() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dark", false);
  }

  @override
  void initState() {
    indexAntigo = 2;
    _pegarVersao();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      scrollBehavior: MyBehavior(),
      slivers: [
        SliverAppBar.medium(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.background,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              "Configurações",
              style: TextStyle(
                fontFamily: "Jost",
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            centerTitle: true,
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
            child: ScrollConfiguration(
              behavior: MyBehavior(),
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_rounded),
                    title: const Text(
                      "Modo escuro",
                      style: TextStyle(
                        fontFamily: "Jost",
                        fontSize: 20,
                      ),
                    ),
                    subtitle: const Text(
                      "Lindo como gatos pretos!",
                      style: TextStyle(fontFamily: "Jost"),
                    ),
                    value: dark,
                    onChanged: (bool value) {
                      setState(() {
                        if (value) {
                          App.themeNotifier.value = ThemeMode.dark;
                          _saveDark();
                        } else {
                          App.themeNotifier.value = ThemeMode.light;
                          _saveLight();
                        }

                        dark = value;
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
                          style: TextStyle(fontFamily: "Jost", fontSize: 25),
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
                  Center(
                    child: SizedBox(
                      height: 42,
                      child: ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              _launchUrl(_urlGatopediaGit);
                            },
                            icon: const Icon(AntDesign.github),
                            label: const Text(
                              "Repositório",
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
                              _launchUrl(
                                Uri.parse(
                                  "https://etec199-danilolima.xp3.biz/2023/0318/",
                                ),
                              );
                            },
                            icon: const Icon(Icons.public),
                            label: const Text(
                              "Web",
                              style: TextStyle(fontFamily: "Jost"),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  /* Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      
                    ],
                  ), */
                  const SizedBox(
                    height: 17,
                  ),
                  const Divider(),
                  Center(
                    child: Text(
                      "© ${DateTime.now().year} Danilo Lima",
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontFamily: "monospace"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
