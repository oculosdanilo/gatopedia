// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _urlGatopediaGit = Uri.parse('https://github.com/oculosdanilo/gatopedia');
final Uri _urlGatopediaGitLatest = Uri.parse('https://github.com/oculosdanilo/gatopedia/releases');
String appName = "";
String packageName = "";
String version = "";
String buildNumber = "";
bool dark = App.themeNotifier.value == ThemeMode.dark ? true : false;

class Config extends StatefulWidget {
  final bool voltar;

  const Config(this.voltar, {super.key});

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
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar.large(
          backgroundColor: Theme.of(context).colorScheme.background,
          automaticallyImplyLeading: widget.voltar,
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Configurações",
                style: TextStyle(
                  fontFamily: "Jost",
                  fontSize: 40,
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(5, 10, 5, 0),
            height: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_rounded),
                  title: const Text(
                    "Modo escuro",
                    style: TextStyle(fontSize: 20),
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
                ListTile(
                  onTap: () async {
                    showCupertinoDialog(
                      context: context,
                      builder: (c) => Theme(
                        data: ThemeData.from(
                          colorScheme: ColorScheme.fromSeed(
                            seedColor: Color(0xffff0000),
                            brightness: dark ? Brightness.dark : Brightness.light,
                          ),
                        ),
                        child: AlertDialog(
                          title: Text("Tem certeza"),
                        ),
                      ),
                    );
                  },
                  title: Text("Deletar conta"),
                  subtitle: Text("Remove seu perfil e seu conteúdo na plataforma"),
                  leading: Icon(Symbols.delete_rounded),
                  iconColor: Theme.of(context).colorScheme.error,
                  titleTextStyle: GoogleFonts.jost(color: Theme.of(context).colorScheme.error, fontSize: 20),
                  subtitleTextStyle: GoogleFonts.jost(color: Theme.of(context).colorScheme.error),
                ),
                const Divider(),
                Container(
                  margin: const EdgeInsets.all(15),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sobre o aplicativo",
                        style: TextStyle(fontFamily: "Jost", fontSize: 25),
                      ),
                      SelectableText(
                        "$packageName\nVersão: $version ($buildNumber)",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: botoes(),
                ),
                const SizedBox(
                  height: 17,
                ),
                const Divider(),
                Center(
                  child: Text(
                    "© ${DateTime.now().year} oculosdanilo\nTodos os direitos reservados",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontFamily: "monospace",
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget botoes() {
    return Row(
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
    );
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
