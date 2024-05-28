// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:gatopedia/home/gatos/forum/imagem_view.dart';
import 'package:gatopedia/main.dart';
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

class GoogleCadastro extends StatefulWidget {
  final GoogleSignInAccount conta;

  const GoogleCadastro(this.conta, {super.key});

  @override
  State<GoogleCadastro> createState() => _GoogleCadastroState();
}

class _GoogleCadastroState extends State<GoogleCadastro> {
  final _formKey = GlobalKey<FormState>();
  final txtControllerLogin = TextEditingController();
  int txtFieldLenght = 0;
  Color? counterColor;

  late final scW = MediaQuery.of(context).size.width;
  late final scH = MediaQuery.of(context).size.height;

  mudarCor(cor) {
    setState(() {
      counterColor = cor;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.conta.displayName != null) {
      txtControllerLogin.text = widget.conta.displayName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => FocusManager.instance.primaryFocus?.unfocus()),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(width: 15),
                OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancelar")),
                Expanded(child: SizedBox()),
                FilledButton(onPressed: () {}, child: Text("Cadastrar")),
                SizedBox(width: 15),
              ],
            ),
            SizedBox(height: 20)
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Quase lá!",
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: scW * 0.8,
                child: Text(
                  "Agora você só precisa escolher uma foto de perfil e um nome de usuário:",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Stack(
                children: [
                  ClipOval(
                    child: widget.conta.photoUrl != null
                        ? Stack(
                            children: [
                              Hero(
                                tag: "profile",
                                child: FadeInImage(
                                  image: NetworkImage(widget.conta.photoUrl!),
                                  fadeInDuration: Duration(milliseconds: 150),
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                  placeholder: AssetImage("assets/anim/loading.gif"),
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
                                      MaterialPageRoute(builder: (ctx) => Imagem(widget.conta.photoUrl!, "profile")),
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
                      onPressed: () {},
                      icon: Icon(Symbols.camera_alt_rounded, fill: 1, size: 30),
                      style: ButtonStyle(fixedSize: WidgetStatePropertyAll(Size(60, 60))),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: scW * 0.8,
                child: TextFormField(
                  key: _formKey,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
