import 'package:flutter/material.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
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

  late String idiomaAtual = App.localeNotifier.value.languageCode;

  void _pegarVersao() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      appName = packageInfo.appName;
      packageName = packageInfo.packageName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
    });
  }

  void _saveDark() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dark", true);
  }

  void _saveLight() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dark", false);
  }

  void _mudarLingua(String locale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("locale", locale);
    if (!mounted) return;
    setState(() {
      idiomaAtual = locale;
      App.localeNotifier.value = Locale(locale);
    });
  }

  String _nomeLocale(String locale, BuildContext context) {
    String nome;
    switch (locale) {
      case "pt":
        nome = AppLocalizations.of(context).lan_pt;
      case "en":
        nome = AppLocalizations.of(context).lan_en;
      case _:
        nome = "não implementado";
    }
    return nome;
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
      physics: const ClampingScrollPhysics(),
      slivers: [
        SliverAppBar.large(
          backgroundColor: Theme.of(context).colorScheme.surface,
          automaticallyImplyLeading: widget.voltar,
          titleTextStyle: const TextStyle(fontSize: 40),
          flexibleSpace: LayoutBuilder(
            builder: (c, cons) {
              return FlexibleSpaceBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(widget.voltar ? -24 : 0, 0),
                      child: Text(
                        AppLocalizations.of(context).config_title,
                        style: const TextStyle(fontVariations: [FontVariation.weight(500)]),
                      ),
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
              : const [],
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
                          title: Text(
                            AppLocalizations.of(context).config_darkmode_title,
                            style: const TextStyle(fontSize: 20),
                          ),
                          subtitle: Text(AppLocalizations.of(context).config_darkmode_subtitle),
                          contentPadding: const EdgeInsets.fromLTRB(16, 0, 5, 0),
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

                            final listaIdiomas = AppLocalizations.supportedLocales.map((e) => e.languageCode).toList()
                              ..remove(App.localeNotifier.value.languageCode);

                            showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(99999, pos.dy, 0, 99999),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              items: [
                                PopupMenuItem(child: Text(_nomeLocale(idiomaAtual, context))),
                                ...(listaIdiomas.map((e) {
                                  return PopupMenuItem(
                                      onTap: () => _mudarLingua(e), child: Text(_nomeLocale(e, context)));
                                })),
                              ],
                            );
                          },
                          title: Text(AppLocalizations.of(context).config_lan_title),
                          subtitle: Text(AppLocalizations.of(context).config_lan_subtitle),
                          leading: const Icon(Symbols.translate_rounded),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_nomeLocale(idiomaAtual, context), style: const TextStyle(fontSize: 14)),
                              const Icon(Symbols.arrow_drop_down_rounded),
                            ],
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(16, 0, 5, 0),
                          titleTextStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 20,
                            fontFamily: "Jost",
                          ),
                        ),
                        !widget.voltar ? const DeletarConta() : const SizedBox(),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                Container(
                  margin: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).config_about_title,
                        style: const TextStyle(fontFamily: "Jost", fontSize: 25),
                      ),
                      SelectableText(
                        AppLocalizations.of(context).config_about_desc(packageName, version, buildNumber),
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
                    AppLocalizations.of(context).config_copyright(DateTime.now().year),
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
          onPressed: () => abrirUrl(_urlGatopediaPlayStore),
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
          onPressed: () => abrirUrl(_urlGatopediaGit),
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(scW - 40, 50)),
          ),
          child: Row(
            children: [
              const Icon(AntDesign.github_fill),
              Expanded(
                child: Center(
                  child: Text(AppLocalizations.of(context).config_botoes_repo, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => abrirUrl(_urlGatopediaGitLatest),
          style: ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size(scW - 40, 50)),
          ),
          child: Row(
            children: [
              const Icon(AntDesign.github_fill),
              Expanded(
                child: Center(
                  child:
                      Text(AppLocalizations.of(context).config_botoes_versions, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => abrirUrl(_urlGatopediaWeb),
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
          onPressed: () => abrirUrl(_urlGatopediaGit),
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
          onPressed: () => abrirUrl(_urlGatopediaGitLatest),
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
          onPressed: () => abrirUrl(_urlGatopediaWeb),
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

Future<void> abrirUrl(Uri url) async {
  if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
    throw Exception('Could not launch $url');
  }
}
