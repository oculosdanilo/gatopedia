import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'forum.dart';

bool imagemSelecionada = false;

class ImagePost extends StatefulWidget {
  final String imageType;

  const ImagePost(this.imageType, {super.key});

  @override
  State<ImagePost> createState() => _ImagePostState();
}

class _ImagePostState extends State<ImagePost> {
  final txtLegenda = TextEditingController();

  _pegaImagem() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: widget.imageType == "image"
          ? ['jpeg', 'jpg', 'png', 'webp']
          : ['gif'],
      type: FileType.custom,
    );
    if (result != null) {
      file = File(result.files.single.path!);
      setState(() {
        imagemSelecionada = true;
        imagemTipo = widget.imageType;
      });
    } else {
      postado = false;
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    _pegaImagem();
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
              title: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  widget.imageType == "image"
                      ? "Post com imagem"
                      : "Post com GIF",
                  style: const TextStyle(fontSize: 20),
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
                            SizedBox(
                              width: double.infinity,
                              child: imagemSelecionada
                                  ? Image(
                                      image: FileImage(file!),
                                      fit: BoxFit.cover,
                                    )
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
                            ),
                            TextField(
                              controller: txtLegenda,
                              maxLength: 255,
                              maxLines: 30,
                              minLines: 1,
                              decoration: InputDecoration(
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (txtLegenda.text != "") {
                                      setState(() {
                                        postado = true;
                                        imagemSelecionada = false;
                                      });
                                      legenda = txtLegenda.text;
                                      Navigator.pop(context);
                                    }
                                  },
                                  icon: const Icon(Icons.send_rounded),
                                  label: const Text("ENVIAR"),
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
