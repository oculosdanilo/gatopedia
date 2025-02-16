import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

File? file, imagemEditada;
bool imagemSelecionada = false;

class PPEdit extends StatefulWidget {
  final bool edit;

  const PPEdit(this.edit, {super.key});

  @override
  State<PPEdit> createState() => _PPEditState();
}

class _PPEditState extends State<PPEdit> {
  bool _botaoEnabled = true;

  void _salvarPP(File? file) async {
    XFile? result = await FlutterImageCompress.compressAndGetFile(
      file!.absolute.path,
      "${(await getApplicationDocumentsDirectory()).path}aa.webp",
      quality: 60,
      format: CompressFormat.webp,
    );
    FirebaseStorage storage = FirebaseStorage.instance;
    final refS = storage.ref("users/$username.webp");
    await refS.putFile(File(result!.path));
    FirebaseDatabase database = FirebaseDatabase.instance;
    final ref = database.ref("users/$username/");
    await ref.update({"img": true});
    CachedNetworkImage.evictFromCache(
        "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media");
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  void _pegaImagem() async {
    final picker = ImagePicker();
    XFile? result = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (result != null) {
      file = File(result.path);
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file!.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: AppLocalizations.of(context).ppedit_cut_title,
            hideBottomControls: true,
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
            initAspectRatio: CropAspectRatioPreset.square,
            activeControlsWidgetColor: Theme.of(context).colorScheme.onPrimary,
            statusBarColor: Theme.of(context).colorScheme.primary,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            cancelButtonTitle: AppLocalizations.of(context).cancel,
            doneButtonTitle: AppLocalizations.of(context).ppedit_cut_done,
            title: AppLocalizations.of(context).ppedit_cut_title,
            aspectRatioLockEnabled: true,
            minimumAspectRatio: 1 / 1,
            aspectRatioPickerButtonHidden: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() => imagemEditada = File(croppedFile.path));
      } else {
        if (!mounted) return;
        Navigator.pop(context, false);
      }
    } else {
      Navigator.pop(context, false);
    }
  }

  void _editarImagem(File? file) async {
    if (file != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: AppLocalizations.of(context).ppedit_cut_title,
              hideBottomControls: true,
              toolbarColor: Theme.of(context).colorScheme.primary,
              toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
              initAspectRatio: CropAspectRatioPreset.square,
              activeControlsWidgetColor: Theme.of(context).colorScheme.onPrimary,
              statusBarColor: Theme.of(context).colorScheme.primary,
              lockAspectRatio: true,
              aspectRatioPresets: [CropAspectRatioPreset.square]),
          IOSUiSettings(
              cancelButtonTitle: AppLocalizations.of(context).cancel,
              doneButtonTitle: AppLocalizations.of(context).ppedit_cut_done,
              title: AppLocalizations.of(context).ppedit_cut_title,
              aspectRatioLockEnabled: true,
              minimumAspectRatio: 1 / 1,
              aspectRatioPickerButtonHidden: true,
              resetAspectRatioEnabled: false,
              aspectRatioPresets: [CropAspectRatioPreset.square]),
        ],
      );
      if (croppedFile != null) {
        setState(() => imagemEditada = File(croppedFile.path));
      }
    } else {
      if (imagemEditada == null) Navigator.pop(context, false);
    }
  }

  @override
  void initState() {
    super.initState();
    file = null;
    imagemEditada = null;
    imagemSelecionada = false;
    _pegaImagem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar.large(
            backgroundColor: Theme.of(context).colorScheme.primary,
            leading: IconButton(
              color: Colors.white,
              onPressed: _botaoEnabled ? () => Navigator.pop(context) : null,
              icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onPrimary),
            ),
            title: Center(
              child: Text(
                widget.edit
                    ? AppLocalizations.of(context).ppedit_title
                    : AppLocalizations.of(context).profile_pfp_addPFP,
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
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
                      Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                        clipBehavior: Clip.hardEdge,
                        width: double.infinity,
                        child: imagemEditada != null
                            ? Stack(
                                fit: StackFit.passthrough,
                                children: [
                                  Image(image: FileImage(imagemEditada!), fit: BoxFit.cover),
                                  Positioned.fill(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: const BoxDecoration(color: Color.fromARGB(155, 0, 0, 0)),
                                    ),
                                  ),
                                  ClipOval(child: Image(image: FileImage(imagemEditada!), fit: BoxFit.cover)),
                                  Positioned.fill(
                                    child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 100),
                                      opacity: _botaoEnabled ? 0 : 1,
                                      child: Container(
                                        width: double.infinity,
                                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                                        child: const Center(child: CircularProgressIndicator()),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Text(AppLocalizations.of(context).ppedit_noImage, textAlign: TextAlign.center),
                              ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _botaoEnabled ? () => _editarImagem(file) : null,
                            child: Text(AppLocalizations.of(context).edit),
                          ),
                          FilledButton(
                            onPressed: _botaoEnabled
                                ? () {
                                    setState(() {
                                      _botaoEnabled = false;
                                    });
                                    _salvarPP(imagemEditada!);
                                  }
                                : null,
                            child: Text(AppLocalizations.of(context).save),
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
