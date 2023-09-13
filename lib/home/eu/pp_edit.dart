import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gatopedia/main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

File? file, imagemEditada;
bool imagemSelecionada = false;

class PPEdit extends StatefulWidget {
  const PPEdit({super.key});

  @override
  State<PPEdit> createState() => _PPEditState();
}

class _PPEditState extends State<PPEdit> {
  _salvarPP(File? file) async {
    XFile? result = await FlutterImageCompress.compressAndGetFile(
      file!.absolute.path,
      "${(await getApplicationDocumentsDirectory()).path}aa.webp",
      quality: 80,
      format: CompressFormat.webp,
    );
    FirebaseStorage storage = FirebaseStorage.instance;
    final refS = storage.ref("users/$username.webp");
    await refS.putFile(File(result!.path));
    FirebaseDatabase database = FirebaseDatabase.instance;
    final ref = database.ref("users/$username/");
    await ref.update(
      {"img": true},
    );
    CachedNetworkImage.evictFromCache(
      "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media",
    );
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  _pegaImagem() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['jpeg', 'jpg', 'png'],
      type: FileType.custom,
    );
    if (!mounted) return;
    if (result != null) {
      file = File(result.files.single.path!);

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '✂️Cortando...',
            hideBottomControls: true,
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
            initAspectRatio: CropAspectRatioPreset.original,
            activeControlsWidgetColor: Theme.of(context).colorScheme.onPrimary,
            statusBarColor: Theme.of(context).colorScheme.primary,
            lockAspectRatio: true,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          imagemEditada = File(croppedFile.path);
        });
      } else {
        if (!mounted) return;
        Navigator.pop(context, false);
      }
    } else {
      Navigator.pop(context, false);
    }
  }

  _editarImagem(File? file) async {
    if (file != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '✂️Cortando...',
            hideBottomControls: true,
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
            initAspectRatio: CropAspectRatioPreset.original,
            activeControlsWidgetColor: Theme.of(context).colorScheme.onPrimary,
            statusBarColor: Theme.of(context).colorScheme.primary,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          imagemEditada = File(croppedFile.path);
        });
      } else {
        if (!mounted) return;
        Navigator.pop(context, false);
      }
    } else {
      Navigator.pop(context, false);
    }
  }

  @override
  void initState() {
    file = null;
    imagemEditada = null;
    imagemSelecionada = false;
    _pegaImagem();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar.large(
            leading: IconButton(
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close_rounded),
            ),
            title: Center(
              child: Text(
                "Editar foto de perfil",
                style: TextStyle(
                  fontFamily: "Jost",
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
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
                        child: imagemEditada != null
                            ? Stack(
                                fit: StackFit.passthrough,
                                children: [
                                  Image(
                                    image: FileImage(imagemEditada!),
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        color: Color.fromARGB(155, 0, 0, 0),
                                      ),
                                    ),
                                  ),
                                  ClipOval(
                                    child: Image(
                                      image: FileImage(imagemEditada!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
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
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OutlinedButton(
                              onPressed: () {
                                _editarImagem(file);
                              },
                              child: const Text("EDITAR")),
                          ElevatedButton(
                            onPressed: () {
                              _salvarPP(imagemEditada!);
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
      ),
    );
  }
}
