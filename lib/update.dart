import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';

bool baixando = false;
double downloadPorcento = 0;
late OtaEvent currentEvent;

class Update extends StatefulWidget {
  final String versao;
  const Update(this.versao, {super.key});

  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  _atualizar() async {
    try {
      OtaUpdate()
          .execute(
              'https://github.com/oculosdanilo/gatopedia/releases/latest/download/app-release.apk')
          .listen(
        (OtaEvent event) {
          setState(() {
            currentEvent = event;
          });
          debugPrint(currentEvent.value);
        },
      );
    } catch (e) {
      debugPrint('Failed to make OTA update. Details: $e');
    }
  }

  @override
  void initState() {
    downloadPorcento = 0;
    baixando = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nova versão disponível",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontFamily: "Jost",
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            children: [
              Text(
                "A versão ${widget.versao} acabou de sair!",
                style: const TextStyle(fontFamily: "Jost", fontSize: 20),
              ),
              const Text(
                "Quentinha do forno",
                style: TextStyle(fontFamily: "Jost", fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              !baixando
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                baixando = true;
                                _atualizar();
                              },
                              icon: const Icon(Icons.download),
                              label: const Text("ATUALIZAR"),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Arquivo apk baixado diretamente do GitHub.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "monospace",
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        LinearProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Arquivo apk baixado diretamente do GitHub.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: "monospace",
                          ),
                        ),
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }
}
