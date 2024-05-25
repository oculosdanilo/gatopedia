import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:gatopedia/home/gatos/forum/forum.dart';

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
      allowedExtensions: widget.imageType == "image" ? ['jpeg', 'jpg', 'png', 'webp'] : ['gif'],
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

  Future<File?> _editarImagem(File img) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file!.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio16x9,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '✏️Editando...',
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
          initAspectRatio: CropAspectRatioPreset.original,
          activeControlsWidgetColor: Theme.of(context).colorScheme.primary,
          statusBarColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
    if (croppedFile != null) {
      return File(croppedFile.path);
    } else {
      return null;
    }
  }

  @override
  void initState() {
    _pegaImagem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (poppou) => imagemSelecionada = false,
      child: Scaffold(
        body: CustomScrollView(
          scrollBehavior: MyBehavior(),
          slivers: <Widget>[
            SliverAppBar.large(
              backgroundColor: Theme.of(context).colorScheme.primary,
              leading: IconButton(
                onPressed: () {
                  setState(() {
                    postado = false;
                    imagemSelecionada = false;
                  });
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onPrimary),
              ),
              title: Center(
                child: Text(
                  widget.imageType == "image" ? "Post com imagem" : "Post com GIF",
                  style: GoogleFonts.jost(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.onSurface,
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
                              : const Center(child: CircularProgressIndicator()),
                        ),
                        TextField(
                          controller: txtLegenda,
                          maxLength: 255,
                          maxLines: 30,
                          minLines: 1,
                          decoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            widget.imageType == "image"
                                ? ElevatedButton(
                                    onPressed: () async {
                                      final imgEditada = await _editarImagem(file!);
                                      if (imgEditada != null) {
                                        setState(() {
                                          file = imgEditada;
                                        });
                                      }
                                    },
                                    child: const Text("EDITAR"),
                                  )
                                : const SizedBox(),
                            const Expanded(child: SizedBox()),
                            FilledButton.icon(
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
        ),
      ),
    );
  }
}
