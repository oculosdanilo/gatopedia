import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/config/deletar_conta.dart';
import 'package:gatopedia/telas/home/home.dart';
import 'package:gatopedia/telas/loginScreen/colab.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _urlGatopediaWeb = Uri.parse("https://osprojetos.web.app/2023/gatopedia");
final Uri _urlGatopediaGit = Uri.parse('https://github.com/oculosdanilo/gatopedia');
final Uri _urlGatopediaGitLatest = Uri.parse('https://github.com/oculosdanilo/gatopedia/releases');
final Uri _urlGatopediaPlayStore = Uri.parse('https://play.google.com/store/apps/details?id=io.oculosdanilo.gatopedia');
String appName = "";
String packageName = "";
String version = "";
String buildNumber = "";

class Config extends StatefulWidget {
  final bool voltar;

  const Config(this.voltar, {super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  final chaveIdioma = GlobalKey<_ConfigState>();

  late final scW = MediaQuery.sizeOf(context).width;
  late final alturaLimite = MediaQuery.paddingOf(context).top + kToolbarHeight;

  late String idiomaAtual = App.localeNotifier.value.languageCode == "pt"
      ? AppLocalizations.of(context)!.lan_pt
      : AppLocalizations.of(context)!.lan_en;

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
    super.initState();
    indexAntigo = 2;
    _pegarVersao();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: ClampingScrollPhysics(),
      slivers: [
        SliverAppBar.large(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: widget.voltar,
          titleTextStyle: const TextStyle(fontSize: 40),
          flexibleSpace: LayoutBuilder(
            builder: (c, cons) {
              return FlexibleSpaceBar(
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Configurações",
                      style: TextStyle(fontVariations: [FontVariation.weight(500)]),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: !widget.voltar
              ? [
                  IconButton(
                    onPressed: () {
                      Navigator.push(context, SlideUpRoute(const Colaboradores()));
                    },
                    icon: const Icon(Symbols.people, fill: 1),
                  ),
                ]
              : [],
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SwitchListTile(
                          secondary: const Icon(Icons.dark_mode_rounded),
                          title: const Text("Modo escuro", style: TextStyle(fontSize: 20)),
                          subtitle: const Text("Lindo como gatos pretos!"),
                          contentPadding: EdgeInsets.fromLTRB(16, 0, 5, 0),
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
                          key: chaveIdioma,
                          onTap: () {
                            final box = chaveIdioma.currentContext!.findRenderObject() as RenderBox;
                            final local = box.localToGlobal(Offset.zero);
                            final pos = Offset(local.dx, local.dy + 5);

                            final listaIdiomas = [
                              AppLocalizations.of(context)!.lan_pt,
                              AppLocalizations.of(context)!.lan_en
                            ]..remove(idiomaAtual);

                            showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(99999, pos.dy, 0, 99999),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              items: [
                                PopupMenuItem(child: Text(idiomaAtual)),
                                ...(listaIdiomas.map((e) {
                                  return PopupMenuItem(child: Text(e));
                                })),
                              ],
                            );
                          },
                          title: const Text("Idioma do app"),
                          subtitle: const Text("miau miau miau miau miau?"),
                          leading: const Icon(Symbols.translate_rounded),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(idiomaAtual, style: TextStyle(fontSize: 14)),
                              Icon(Symbols.arrow_drop_down_rounded),
                            ],
                          ),
                          contentPadding: EdgeInsets.fromLTRB(16, 0, 5, 0),
                          titleTextStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 20,
                            fontFamily: "Jost",
                          ),
                        ),
                        !widget.voltar ? DeletarConta() : const SizedBox(),
                      ],
                    ),
                  ),
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
                const SizedBox(height: 10),
                botoes(),
                const SizedBox(height: 17),
                const Divider(),
                Center(
                  child: Text(
                    "\u00a9 ${DateTime.now().year} oculosdanilo\nTodos os direitos reservados\n\nFeito com \u2764 por Danilo Lima",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontFamily: "monospace",
                    ),
                  ),
                ),
                SizedBox(
                  height: !widget.voltar ? kBottomNavigationBarHeight : 0,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget botoes() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton(
          onPressed: () => _launchUrl(_urlGatopediaPlayStore),
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(scW - 40, 50)),
          ),
          child: Row(
            children: [
              Transform.scale(
                scale: 0.9,
                child: const Icon(Bootstrap.google_play),
              ),
              const Expanded(
                child: Center(
                  child: Text("Play Store", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _launchUrl(_urlGatopediaGit),
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(scW - 40, 50)),
          ),
          child: Row(
            children: [
              const Icon(AntDesign.github_fill),
              Expanded(
                child: Center(
                  child: Text("Repositório", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _launchUrl(_urlGatopediaGitLatest),
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(scW - 40, 50)),
          ),
          child: const Row(
            children: [
              Icon(AntDesign.github_fill),
              Expanded(
                child: Center(
                  child: Text("Versões", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _launchUrl(_urlGatopediaWeb),
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(scW - 40, 50)),
          ),
          child: const Row(
            children: [
              Icon(Symbols.public_rounded),
              Expanded(
                child: Center(
                  child: Text("Site", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        /*ElevatedButton.icon(
          onPressed: () => _launchUrl(_urlGatopediaGit),
          icon: const Icon(AntDesign.github_fill),
          label: const Text(
            "Repositório",
            style: TextStyle(fontSize: 18),
          ),
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width - 50, 50)),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _launchUrl(_urlGatopediaGitLatest),
          icon: const Icon(AntDesign.github_fill),
          label: const Text(
            "Versões",
            style: TextStyle(fontSize: 18),
          ),
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width - 50, 50)),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () => _launchUrl(_urlGatopediaWeb),
          icon: const Icon(Icons.public_rounded),
          label: const Text(
            "Site",
            style: TextStyle(fontSize: 18),
          ),
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(MediaQuery.sizeOf(context).width - 50, 50)),
          ),
        )*/
      ],
    );
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
    throw Exception('Could not launch $url');
  }
}
