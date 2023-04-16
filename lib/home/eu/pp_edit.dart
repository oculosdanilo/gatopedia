// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

File? file;
bool imagemSelecionada = false, postado = false;

class PPEdit extends StatefulWidget {
  const PPEdit({super.key});

  @override
  State<PPEdit> createState() => _PPEditState();
}

class _PPEditState extends State<PPEdit> {
  _pegaImagem() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['jpeg', 'jpg', 'png'],
      type: FileType.custom,
    );
    if (result != null) {
      file = File(result.files.single.path!);
      setState(() {
        imagemSelecionada = true;
      });
    } else {
      postado = false;
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    imagemSelecionada = false;
    /* _pegaImagem(); */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        physics: const NeverScrollableScrollPhysics(),
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar.large(
              leading: IconButton(
                onPressed: () {
                  setState(() {
                    postado = false;
                    imagemSelecionada = false;
                  });
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close_rounded),
              ),
              automaticallyImplyLeading: false,
              title: const FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  "Editar foto de perfil",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
        ],
        body: Builder(
          builder: (context) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverOverlapInjector(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            /* SizedBox(
                              width: double.infinity,
                              child: imagemSelecionada
                                  ? Text("aafolou")
                                  : const Padding(
                                      padding: EdgeInsets.fromLTRB(
                                        0,
                                        10,
                                        0,
                                        0,
                                      ),
                                      child: Text(
                                        "Nenhuma imagem selecionada",
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                            ), */
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _pegaImagem();
                                  },
                                  child: const Text("SALVAR"),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
