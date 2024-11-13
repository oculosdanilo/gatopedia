import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _urlFlutter = Uri.parse('https://flutter.dev');
final Uri _urlMaterialYou = Uri.parse('https://m3.material.io');
final Uri _urlEmailDanilo = Uri.parse('mailto:danilo.lima124@etec.sp.gov.br');
final Uri _urlEmailLucca = Uri.parse('mailto:juliana.barros36@etec.sp.gov.br');

class Asim extends StatelessWidget {
  const Asim({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class Colaboradores extends StatefulWidget {
  const Colaboradores({super.key});

  @override
  State<Colaboradores> createState() => _ColaboradoresState();
}

class _ColaboradoresState extends State<Colaboradores> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            actionsIconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            title: Row(
              children: [
                Icon(Icons.people_alt_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 40),
                const SizedBox(width: 15),
                Text("COLABORADORES", style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Symbols.info_rounded, fill: 1),
                onPressed: () => showCupertinoDialog(
                  context: context,
                  builder: (context) => alertaSobre(context),
                ),
              ),
            ],
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ClipRRect(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                        child: Image(image: AssetImage('assets/danilo.jpg'), width: 150),
                      ),
                      const SizedBox(width: 17),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Danilo Lima",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                            ),
                            const SizedBox(height: 10),
                            const Text("\u2022 Design e programação"),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () => _launchUrl(_urlEmailDanilo),
                              icon: const Icon(Icons.mail_rounded),
                              label: const Text("Email"),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ClipRRect(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                        child: Image(image: AssetImage('assets/lucca.png'), width: 150),
                      ),
                      const SizedBox(width: 17),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Lucca Leal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
                          const SizedBox(height: 10),
                          const Text("\u2022 Idealização e pesquisas"),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () => _launchUrl(_urlEmailLucca),
                            icon: const Icon(Icons.mail_rounded),
                            label: const Text("Email"),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Color fundoTexto1 = Colors.transparent;
  Color fundoTexto2 = Colors.transparent;

  Widget alertaSobre(BuildContext context) {
    return StatefulBuilder(builder: (context, setStateLocal) {
      return AlertDialog(
        icon: const Icon(Icons.info_rounded),
        title: const Text(
          "Sobre o projeto",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.onSurface, fontFamily: "Jost"),
            children: [
              TextSpan(text: "Produzido com "),
              TextSpan(
                  text: "Flutter",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                    backgroundColor: fundoTexto1,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchUrl(_urlFlutter);
                    }
                    ..onTapDown = (d) {
                      setStateLocal(() {
                        fundoTexto1 = Theme.of(context).colorScheme.primary.withOpacity(0.20);
                      });
                    }
                    ..onTapUp = (d) {
                      setStateLocal(() {
                        fundoTexto1 = Colors.transparent;
                      });
                    }
                    ..onTapCancel = () {
                      setStateLocal(() {
                        fundoTexto1 = Colors.transparent;
                      });
                    }),
              TextSpan(text: " e "),
              TextSpan(
                  text: "Material You",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                    backgroundColor: fundoTexto2,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _launchUrl(_urlMaterialYou);
                    }
                    ..onTapDown = (d) {
                      setStateLocal(() {
                        fundoTexto2 = Theme.of(context).colorScheme.primary.withOpacity(0.20);
                      });
                    }
                    ..onTapUp = (d) {
                      setStateLocal(() {
                        fundoTexto2 = Colors.transparent;
                      });
                    }
                    ..onTapCancel = () {
                      setStateLocal(() {
                        fundoTexto2 = Colors.transparent;
                      });
                    })
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      );
    });
  }
}

Future<void> _launchUrl(url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
