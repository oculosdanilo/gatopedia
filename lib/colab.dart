import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _urlFlutter = Uri.parse('https://flutter.dev');
final Uri _urlMaterialYou = Uri.parse('https://m3.material.io');
final Uri _urlEmailDanilo = Uri.parse('mailto:danilo.lima124@etec.sp.gov.br');
final Uri _urlEmailLucca = Uri.parse('mailto:juliana.barros36@etec.sp.gov.br');

class Colaboradores extends StatefulWidget {
  const Colaboradores({super.key});

  @override
  ColaboradoresState createState() {
    return ColaboradoresState();
  }
}

enum MenuItens { itemUm }

class ColaboradoresState extends State {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: prefer_const_literals_to_create_immutables
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar.large(
          iconTheme:
              IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          title: Row(
            children: [
              Icon(
                Icons.people_alt_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 40,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                "COLABORADORES",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontFamily: "Jost"),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<MenuItens>(
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<MenuItens>>[
                PopupMenuItem(
                  onTap: () {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.info_rounded,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "Sobre o projeto",
                                    style: TextStyle(
                                        fontFamily: "Jost",
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              content: RichText(
                                text: TextSpan(
                                    style: const TextStyle(
                                        fontFamily: "Jost", fontSize: 17),
                                    children: [
                                      TextSpan(
                                          text: "Produzido com ",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground)),
                                      TextSpan(
                                          text: "Flutter",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              decoration:
                                                  TextDecoration.underline),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              _launchUrl(_urlFlutter);
                                            }),
                                      TextSpan(
                                          text: " e ",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground)),
                                      TextSpan(
                                          text: "Material You",
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                              decoration:
                                                  TextDecoration.underline),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              _launchUrl(_urlMaterialYou);
                                            })
                                    ]),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          });
                    });
                  },
                  child: const Text("Sobre o projeto",
                      style: TextStyle(fontFamily: "Jost", fontSize: 17)),
                )
              ],
            )
          ],
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        SliverToBoxAdapter(
            child: Column(
          children: [
            Card(
              surfaceTintColor: Theme.of(context).colorScheme.onBackground,
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 10, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const Image(
                        image: AssetImage('lib/assets/danilo.jpg'),
                        width: 130,
                      ),
                    ),
                    const SizedBox(
                      width: 17,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Danilo Lima",
                            style: TextStyle(
                                fontFamily: "Jost",
                                fontWeight: FontWeight.bold,
                                fontSize: 25),
                          ),
                          const SizedBox(
                            height: 17,
                          ),
                          const Text(
                            "• Design e programação",
                            style: TextStyle(fontFamily: "Jost"),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _launchUrl(_urlEmailDanilo);
                            },
                            icon: const Icon(Icons.mail_rounded),
                            label: const Text("Email"),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              surfaceTintColor: Theme.of(context).colorScheme.onBackground,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const Image(
                        image: AssetImage('lib/assets/lucca.png'),
                        width: 130,
                      ),
                    ),
                    const SizedBox(
                      width: 17,
                    ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Juliana Leal \n(Lucca)",
                            style: TextStyle(
                                fontFamily: "Jost",
                                fontWeight: FontWeight.bold,
                                fontSize: 25),
                          ),
                          const SizedBox(
                            height: 17,
                          ),
                          const Text(
                            "• Idealização e pesquisas",
                            style: TextStyle(fontFamily: "Jost"),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              _launchUrl(_urlEmailLucca);
                            },
                            icon: const Icon(Icons.mail_rounded),
                            label: const Text("Email"),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ))
      ]),
    );
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
