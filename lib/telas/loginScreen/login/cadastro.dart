import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/gatos/forum/view/imagem_view.dart';
import 'package:gatopedia/telas/home/home.dart';
import 'package:gatopedia/telas/loginScreen/login/autenticar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_view/photo_view.dart';

class NewCadastro extends StatefulWidget {
  final GoogleSignInAccount? conta;

  const NewCadastro({this.conta, super.key});

  @override
  State<NewCadastro> createState() => _NewCadastroState();
}

class _NewCadastroState extends State<NewCadastro> {
  final _formKey = GlobalKey<FormState>();
  final _formUsernameKey = GlobalKey<FormFieldState>();
  final _formSenhaKey = GlobalKey<FormFieldState>();
  final _txtControllerLogin = TextEditingController();
  final _txtControllerBio = TextEditingController();
  final _txtControllerSenha = TextEditingController();
  int txtFieldLenght = 0;
  Color? counterColor;
  File? novaImagem;
  late Offset posicao;
  bool esconderSenha = true;
  Icon iconeOlho = const Icon(Icons.visibility_rounded);

  final chaves = GlobalKey();

  bool botaoEnabled = true;

  late final scW = MediaQuery.sizeOf(context).width;
  late final scH = MediaQuery.sizeOf(context).height;
  late final pdB = MediaQuery.paddingOf(context).bottom;

  @override
  void initState() {
    super.initState();
    if (widget.conta?.displayName != null) {
      _txtControllerLogin.text = widget.conta!.displayName!;
      txtFieldLenght = widget.conta!.displayName!.length;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = chaves.currentContext!.findRenderObject() as RenderBox;
      final localToGlobal = box.localToGlobal(Offset.zero);
      posicao = Offset(localToGlobal.dx + 30, localToGlobal.dy + 30);
    });
  }

  _mudarCor(cor) {
    setState(() {
      counterColor = cor;
    });
  }

  _mostrarSenha() {
    if (esconderSenha) {
      setState(() {
        esconderSenha = false;
        iconeOlho = const Icon(Icons.visibility_off_rounded);
      });
    } else {
      setState(() {
        esconderSenha = true;
        iconeOlho = const Icon(Icons.visibility_rounded);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: botaoEnabled,
      onPopInvokedWithResult: (poppou, result) => GoogleSignIn().signOut(),
      child: GestureDetector(
        onTap: () => setState(() => FocusManager.instance.primaryFocus?.unfocus()),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            toolbarHeight: 0,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: botaoEnabled ? () => Navigator.pop(context) : null,
                    child: Text(AppLocalizations.of(context).cancel),
                  ),
                  const Expanded(child: SizedBox()),
                  FilledButton(
                    onPressed: botaoEnabled
                        ? () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => botaoEnabled = false);

                              final ref = FirebaseDatabase.instance.ref("users/${_txtControllerLogin.text}");
                              final existeUsername = (await ref.get()).exists;
                              if (!context.mounted) return;
                              if (existeUsername) {
                                Flushbar(
                                  duration: const Duration(seconds: 5),
                                  margin: const EdgeInsets.all(20),
                                  borderRadius: BorderRadius.circular(50),
                                  messageText: Row(
                                    children: [
                                      Icon(Icons.error_rounded, color: blueScheme.onErrorContainer),
                                      const SizedBox(width: 10),
                                      Text(
                                        "Usuário com esse nome já existe :/",
                                        style: TextStyle(color: blueScheme.onErrorContainer),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: blueScheme.errorContainer,
                                ).show(context);
                                setState(() => botaoEnabled = true);
                              } else {
                                if (widget.conta == null) {
                                  await cadastrar(
                                    _txtControllerLogin.text,
                                    _txtControllerSenha.text,
                                    _txtControllerBio.text,
                                    imagem: novaImagem,
                                  );
                                } else {
                                  await cadastrarGoogle(
                                    _txtControllerLogin.text,
                                    _txtControllerBio.text,
                                    widget.conta!,
                                    imagem: novaImagem,
                                  );
                                }

                                setState(() {
                                  botaoEnabled = true;
                                  username = _txtControllerLogin.text.toLowerCase();

                                  _txtControllerLogin.text = _txtControllerSenha.text = _txtControllerBio.text = "";
                                });
                                if (!context.mounted) return;
                                Navigator.pop(context);
                                Navigator.pushReplacement(context, SlideRightRoute(const Home()));
                              }
                            }
                          }
                        : null,
                    child: const Text("Cadastrar"),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              SizedBox(height: pdB + 10),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Quase lá!", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: scW * 0.8,
                    child: const Text(
                      "Agora você só precisa escolher uma foto de perfil e um nome de usuário:",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      ClipOval(
                        child: widget.conta?.photoUrl != null || novaImagem != null
                            ? Stack(
                                children: [
                                  SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: Hero(
                                      tag: "profile",
                                      child: FadeInImage(
                                        image: novaImagem == null
                                            ? NetworkImage(widget.conta!.photoUrl!.replaceAll("=s96", "=s1080"))
                                            : FileImage(novaImagem!),
                                        fadeInDuration: const Duration(milliseconds: 150),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.contain,
                                        placeholder: const AssetImage("assets/anim/loading.gif"),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    height: 200,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(999),
                                        splashFactory: InkSparkle.splashFactory,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx) => novaImagem == null
                                                ? Imagem(
                                                    widget.conta!.photoUrl!.replaceAll("=s96", "=s1080"), "profile")
                                                : ImagemLocal(novaImagem!, "profile"),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Image.asset("assets/user.webp", width: 200, height: 200),
                      ),
                      novaImagem != null
                          ? Positioned(
                              child: IconButton.filledTonal(
                                onPressed: () => setState(() => novaImagem = null),
                                icon: const Icon(Symbols.delete_rounded, fill: 1),
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStatePropertyAll(Theme.of(context).colorScheme.tertiaryContainer),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: IconButton.filledTonal(
                          key: chaves,
                          onPressed: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: '',
                              transitionDuration: const Duration(milliseconds: 250),
                              transitionBuilder: (context, a1, a2, widget) {
                                final valueCurva = Curves.ease.transform(a1.value);

                                return Transform.translate(
                                  offset: Offset(
                                    (valueCurva * -(posicao.dx - (scW / 2))) + (posicao.dx - (scW / 2)),
                                    (valueCurva * -(posicao.dy - (scH / 2))) + (posicao.dy - (scH / 2)),
                                  ),
                                  child: Dialog(
                                    insetPadding: const EdgeInsets.all(0),
                                    backgroundColor: Colors.transparent,
                                    child: Container(
                                      height: 60 + (120 * valueCurva),
                                      margin: EdgeInsets.symmetric(horizontal: (scW / 2) - (30 + (150 * valueCurva))),
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular((valueCurva * -50) + 70),
                                        color: Theme.of(context).colorScheme.secondaryContainer,
                                      ),
                                      child: AnimatedOpacity(
                                        duration: const Duration(milliseconds: 150),
                                        opacity: valueCurva >= 0.9 ? 1 : 0,
                                        child: botoes(valueCurva, context),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              pageBuilder: (context, a1, a2) => const SizedBox(),
                            );
                          },
                          icon: const Icon(Symbols.camera_alt_rounded, fill: 1, size: 30),
                          style: const ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(60, 60))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: scW * 0.8,
                    child: AutofillGroup(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              maxLength: 25,
                              key: _formUsernameKey,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.username],
                              controller: _txtControllerLogin,
                              onChanged: (value) {
                                setState(() {
                                  txtFieldLenght = value.length;
                                  if (value.length <= 3 || value.length > 25) {
                                    _mudarCor(Theme.of(context).colorScheme.error);
                                  } else {
                                    _mudarCor(Theme.of(context).colorScheme.onSurface);
                                  }
                                });
                                _formUsernameKey.currentState!.validate();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Obrigatório';
                                } else if (!value.contains(RegExp(r'^[a-zA-Z0-9._]+$'))) {
                                  return 'Caractere(s) inválido(s)! (espaços ou símbolos)';
                                } else if (value.length <= 3) {
                                  return "Nome muito pequeno!";
                                } else if (value.contains(RegExp(r'^[0-9]+$'))) {
                                  return "só números? sério?";
                                } else if (value.length > 25) {
                                  return "Nome de usuário muito grande!";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                prefixIconColor: WidgetStateColor.resolveWith((Set<WidgetState> states) {
                                  if (states.contains(WidgetState.error)) return Theme.of(context).colorScheme.error;
                                  if (states.contains(WidgetState.focused)) {
                                    return Theme.of(context).colorScheme.primary;
                                  }
                                  return blueScheme.outline;
                                }),
                                counter: SizedBox(
                                  width: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text("$txtFieldLenght", style: TextStyle(color: counterColor)),
                                      Text("/25", style: TextStyle(color: blueScheme.outline)),
                                    ],
                                  ),
                                ),
                                prefixIcon: const Icon(Icons.alternate_email_rounded),
                                label: const Text("Nome de usuário"),
                              ),
                            ),
                            const SizedBox(height: 10),
                            widget.conta == null
                                ? SizedBox(
                                    width: scW * 0.8,
                                    child: TextFormField(
                                      key: _formSenhaKey,
                                      textInputAction: TextInputAction.next,
                                      autofillHints: const [AutofillHints.password],
                                      controller: _txtControllerSenha,
                                      obscureText: esconderSenha,
                                      keyboardType: TextInputType.visiblePassword,
                                      onChanged: (valor) {
                                        _formSenhaKey.currentState!.validate();
                                      },
                                      validator: (valor) {
                                        if (valor == null || valor.isEmpty) {
                                          return "Obrigatório";
                                        } else if (valor.length < 8) {
                                          return "Senha muito pequena!";
                                        } else {
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        prefix: const SizedBox(width: 10),
                                        suffixIcon: Padding(
                                          padding: const EdgeInsets.only(right: 5),
                                          child: IconButton(onPressed: () => _mostrarSenha(), icon: iconeOlho),
                                        ),
                                        label: const Text("Senha"),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            SizedBox(height: widget.conta == null ? 20 : 0),
                            TextFormField(
                              maxLength: 255,
                              textInputAction: TextInputAction.next,
                              controller: _txtControllerBio,
                              onChanged: (value) {
                                setState(() {
                                  txtFieldLenght = value.length;
                                  if (value.length <= 3 || value.length > 25) {
                                    _mudarCor(Theme.of(context).colorScheme.error);
                                  } else {
                                    _mudarCor(Theme.of(context).colorScheme.onSurface);
                                  }
                                });
                                _formKey.currentState!.validate();
                              },
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).profile_bio_empty,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outline, width: 2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                counter: SizedBox(
                                  width: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text("${_txtControllerBio.text.length}", style: TextStyle(color: counterColor)),
                                      Text("/255", style: TextStyle(color: blueScheme.outline)),
                                    ],
                                  ),
                                ),
                                label: const Text("Bio (opcional)"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _pegarImagem(ImageSource modo) async {
    final ImagePicker picker = ImagePicker();

    final imagem = await picker.pickImage(source: modo);
    if (!mounted) return;
    if (imagem != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imagem.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '\u2702️Cortando...',
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
          novaImagem = File(croppedFile.path);
        });
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Row botoes(double valueCurva, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        valueCurva >= 0.9
            ? Flexible(
                child: OutlinedButton(
                  onPressed: () async {
                    if (await _pegarImagem(ImageSource.camera)) {
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    }
                  },
                  style: ButtonStyle(
                    fixedSize: const WidgetStatePropertyAll(Size(120, 120)),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.camera_alt,
                        fill: 1,
                        size: 60,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      Text(
                        "Câmera",
                        style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSecondaryContainer),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
        valueCurva >= 0.9
            ? Flexible(
                child: OutlinedButton(
                  onPressed: () async {
                    if (await _pegarImagem(ImageSource.gallery)) {
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    }
                  },
                  style: ButtonStyle(
                    fixedSize: const WidgetStatePropertyAll(Size(120, 120)),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.gallery_thumbnail,
                        fill: 1,
                        size: 60,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      Text(
                        "Galeria",
                        style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.onSecondaryContainer),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

class ImagemLocal extends StatefulWidget {
  final File imagem;
  final String hero;

  const ImagemLocal(this.imagem, this.hero, {super.key});

  @override
  State<ImagemLocal> createState() => _ImagemLocalState();
}

class _ImagemLocalState extends State<ImagemLocal> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(
            imageProvider: FileImage(widget.imagem),
            heroAttributes: PhotoViewHeroAttributes(tag: widget.hero, transitionOnUserGestures: true),
            minScale: PhotoViewComputedScale.contained,
            maxScale: 1.0,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, MediaQuery.paddingOf(context).top + 5, 0, 0),
            child: ClipOval(
              child: Material(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
