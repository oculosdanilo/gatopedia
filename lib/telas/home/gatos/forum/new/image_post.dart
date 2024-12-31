import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/gatos/forum/forum.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

bool imagemSelecionada = false;
File? imagemCortada;

class ImagePost extends StatefulWidget {
  final String imageType;

  const ImagePost(this.imageType, {super.key});

  @override
  State<ImagePost> createState() => _ImagePostState();
}

class _ImagePostState extends State<ImagePost> {
  final txtLegenda = TextEditingController();
  final ImagePicker picker = ImagePicker();

  _pegaImagem() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: widget.imageType == "image" ? ['jpeg', 'jpg', 'png', 'webp'] : ['gif'],
      type: FileType.custom,
    );
    if (result != null) {
      file = File(result.paths.first!);
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

  Future<File?> _editarImagem() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: file!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppLocalizations.of(context).forum_editPost_crop_title,
          toolbarColor: Theme.of(context).colorScheme.primary,
          toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
          initAspectRatio: CropAspectRatioPreset.original,
          activeControlsWidgetColor: Theme.of(context).colorScheme.primary,
          statusBarColor: Theme.of(context).colorScheme.primary,
        ),
        IOSUiSettings(
          cancelButtonTitle: AppLocalizations.of(context).cancel,
          doneButtonTitle: AppLocalizations.of(context).ppedit_cut_done,
          title: AppLocalizations.of(context).forum_editPost_crop_title,
          aspectRatioLockEnabled: true,
          minimumAspectRatio: 1 / 1,
          aspectRatioPickerButtonHidden: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    return croppedFile != null ? File(croppedFile.path) : null;
  }

  @override
  void initState() {
    _pegaImagem();
    super.initState();
  }

  late final pdB = MediaQuery.paddingOf(context).bottom;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (poppou, result) => imagemSelecionada = false,
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
                    imagemCortada = null;
                  });
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onPrimary),
              ),
              title: Center(
                child: Text(
                  widget.imageType == "image" ? "Post com imagem" : "Post com GIF",
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + pdB),
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
                                  image: FileImage(imagemCortada ?? file!),
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
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            widget.imageType == "image"
                                ? ElevatedButton.icon(
                                    onPressed: () async {
                                      final imgEditada = await _editarImagem();
                                      if (imgEditada != null) {
                                        setState(() {
                                          imagemCortada = imgEditada;
                                        });
                                      }
                                    },
                                    icon: const Icon(Symbols.tune_rounded),
                                    label: Text(AppLocalizations.of(context).edit),
                                  )
                                : const SizedBox(),
                            const Expanded(child: SizedBox()),
                            FilledButton.icon(
                              onPressed: () {
                                setState(() {
                                  postado = true;
                                  imagemSelecionada = false;
                                });
                                legenda = txtLegenda.text;
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.send_rounded),
                              label: Text(AppLocalizations.of(context).post),
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
