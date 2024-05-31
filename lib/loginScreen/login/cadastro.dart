// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/home/gatos/forum/imagem_view.dart';
import 'package:gatopedia/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:material_symbols_icons/symbols.dart';

Future<GoogleSignInAccount?> loginGoogle() async {
  try {
    final conta = await GoogleSignIn().signIn();

    return conta;
  } catch (e) {
    debugPrint(e.toString());
    return null;
  }
}

class NewCadastro extends StatefulWidget {
  final GoogleSignInAccount conta;

  const NewCadastro(this.conta, {super.key});

  @override
  State<NewCadastro> createState() => _NewCadastroState();
}

class _NewCadastroState extends State<NewCadastro> {
  final _formKey = GlobalKey<FormState>();
  final txtControllerLogin = TextEditingController();
  final txtControllerBio = TextEditingController();
  int txtFieldLenght = 0;
  Color? counterColor;
  File? novaImagem;
  late Offset posicao;

  final chaves = GlobalKey();

  bool botaoEnabled = true;

  late final scW = MediaQuery.of(context).size.width;
  late final scH = MediaQuery.of(context).size.height;

  @override
  void initState() {
    super.initState();
    if (widget.conta.displayName != null) {
      txtControllerLogin.text = widget.conta.displayName!;
      txtFieldLenght = widget.conta.displayName!.length;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = chaves.currentContext!.findRenderObject() as RenderBox;
      final localToGlobal = box.localToGlobal(Offset.zero);
      posicao = Offset(localToGlobal.dx + 30, localToGlobal.dy + 30);
    });
  }

  mudarCor(cor) {
    setState(() {
      counterColor = cor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (poppou) => GoogleSignIn().signOut(),
      child: GestureDetector(
        onTap: () => setState(() => FocusManager.instance.primaryFocus?.unfocus()),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(automaticallyImplyLeading: false, toolbarHeight: 0),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: botaoEnabled
                        ? () {
                            GoogleSignIn().signOut();
                            Navigator.pop(context, false);
                          }
                        : null,
                    child: Text("Cancelar", style: GoogleFonts.jost(fontSize: 18)),
                  ),
                  const Expanded(child: SizedBox()),
                  FilledButton(
                    onPressed: botaoEnabled
                        ? () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => botaoEnabled = false);

                              final ref = FirebaseDatabase.instance.ref("users/${txtControllerLogin.text}");
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
                                final refUsers = FirebaseDatabase.instance.ref("users");
                                final pic = widget.conta.photoUrl;
                                await refUsers.update({
                                  txtControllerLogin.text: {
                                    "bio": "(vazio)",
                                    "google": widget.conta.id,
                                    "img": pic?.replaceAll("=s96", "=s1080"),
                                  },
                                });
                                setState(() => botaoEnabled = true);
                                if (!context.mounted) return;
                                Navigator.pop(context, true);
                              }
                            }
                          }
                        : null,
                    child: Text("Cadastrar", style: GoogleFonts.jost(fontSize: 18)),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
          body: Center(
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
                      child: widget.conta.photoUrl != null
                          ? Stack(
                              children: [
                                Hero(
                                  tag: "profile",
                                  child: FadeInImage(
                                    image: NetworkImage(widget.conta.photoUrl!.replaceAll("=s96", "=s1080")),
                                    fadeInDuration: const Duration(milliseconds: 150),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.contain,
                                    placeholder: const AssetImage("assets/anim/loading.gif"),
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
                                          builder: (ctx) =>
                                              Imagem(widget.conta.photoUrl!.replaceAll("=s96", "=s1080"), "profile"),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Image.asset(
                              "assets/user.webp",
                              width: 200,
                              height: 200,
                            ),
                    ),
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
                            transitionDuration: Duration(milliseconds: 300),
                            transitionBuilder: (context, a1, a2, widget) {
                              final valueCurva = Curves.ease.transform(a1.value);

                              return Transform.translate(
                                offset: Offset(
                                  (valueCurva * -(posicao.dx - (scW / 2))) + (posicao.dx - (scW / 2)),
                                  (valueCurva * -(posicao.dy - (scH / 2))) + (posicao.dy - (scH / 2)),
                                ),
                                child: Dialog(
                                  insetPadding: EdgeInsets.all(0),
                                  backgroundColor: Colors.transparent,
                                  child: Container(
                                    height: 60 + (120 * valueCurva),
                                    margin: EdgeInsets.symmetric(horizontal: (scW / 2) - (30 + (150 * valueCurva))),
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular((valueCurva * -50) + 70),
                                      color: Theme.of(context).colorScheme.secondaryContainer,
                                    ),
                                    child: Opacity(
                                      opacity: valueCurva,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Flexible(
                                            child: IconButton.outlined(
                                              onPressed: () {},
                                              icon: Icon(Symbols.camera_alt, fill: 1),
                                              iconSize: 60,
                                              style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(120, 120))),
                                            ),
                                          ),
                                          Flexible(
                                            child: IconButton.outlined(
                                              onPressed: () {},
                                              icon: Icon(Symbols.camera_alt, fill: 1),
                                              iconSize: 60,
                                              style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(120, 120))),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            pageBuilder: (context, a1, a2) => SizedBox(),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          maxLength: 25,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          controller: txtControllerLogin,
                          onChanged: (value) {
                            setState(() {
                              txtFieldLenght = value.length;
                              if (value.length <= 3 || value.length > 25) {
                                mudarCor(Theme.of(context).colorScheme.error);
                              } else {
                                mudarCor(Theme.of(context).colorScheme.onSurface);
                              }
                            });
                            _formKey.currentState!.validate();
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Obrigatório';
                            } else if (!value.contains(RegExp(r'^[a-zA-Z0-9._]+$'))) {
                              return 'Caractere(s) inválido(s)!';
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
                              if (states.contains(WidgetState.focused)) return Theme.of(context).colorScheme.primary;
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
                        SizedBox(height: 10),
                        TextFormField(
                          maxLength: 255,
                          textInputAction: TextInputAction.next,
                          controller: txtControllerBio,
                          onChanged: (value) {
                            setState(() {
                              txtFieldLenght = value.length;
                              if (value.length <= 3 || value.length > 25) {
                                mudarCor(Theme.of(context).colorScheme.error);
                              } else {
                                mudarCor(Theme.of(context).colorScheme.onSurface);
                              }
                            });
                            _formKey.currentState!.validate();
                          },
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: "(vazio)",
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
                                  Text("${txtControllerBio.text.length}", style: TextStyle(color: counterColor)),
                                  Text("/255", style: TextStyle(color: blueScheme.outline)),
                                ],
                              ),
                            ),
                            label: const Text("Bio"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}