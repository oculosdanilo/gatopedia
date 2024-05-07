import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatopedia/loginScreen/login/autenticar.dart';
import 'package:gatopedia/main.dart';

enum Entrada { login, cadastro }

class FormApp extends StatefulWidget {
  final Entrada modo;

  const FormApp(this.modo, {super.key});

  @override
  FormAppState createState() => FormAppState();
}

class FormAppState extends State<FormApp> {
  final _formKey = GlobalKey<FormState>();
  final txtControllerLogin = TextEditingController();
  final txtControllerSenha = TextEditingController();
  bool inputLembrar = false;
  int txtFieldLenght = 0;
  Color? counterColor;
  bool conectando = false;
  bool esconderSenha = true;
  Icon iconeOlho = const Icon(Icons.visibility_rounded);

  late final scW = MediaQuery.of(context).size.width;
  late final scH = MediaQuery.of(context).size.height;

  mudarCor(cor) {
    setState(() {
      counterColor = cor;
    });
  }

  mostrarSenha() {
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
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: scW * 0.8,
              child: TextFormField(
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
                      mudarCor(Theme.of(context).colorScheme.onBackground);
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
                  prefixIconColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
                    if (states.contains(MaterialState.error)) {
                      return Theme.of(context).colorScheme.error;
                    }
                    if (states.contains(MaterialState.focused)) {
                      return Theme.of(context).colorScheme.primary;
                    }
                    return blueScheme.outline;
                  }),
                  counter: SizedBox(
                    width: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "$txtFieldLenght",
                          style: TextStyle(color: counterColor),
                        ),
                        Text(
                          "/25",
                          style: TextStyle(color: blueScheme.outline),
                        )
                      ],
                    ),
                  ),
                  prefixIcon: const Icon(
                    Icons.alternate_email_rounded,
                  ),
                  label: const Text(
                    "Nome de usuário",
                    style: TextStyle(fontFamily: "Jost"),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: scW * 0.8,
              height: 65,
              child: TextFormField(
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                controller: txtControllerSenha,
                obscureText: esconderSenha,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  prefix: const SizedBox(
                    width: 10,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: () => mostrarSenha(),
                      icon: iconeOlho,
                    ),
                  ),
                  label: const Text(
                    "Senha",
                    style: TextStyle(fontFamily: "Jost"),
                  ),
                ),
              ),
            ),
            widget.modo == Entrada.login ? const SizedBox(height: 17) : const SizedBox(),
            widget.modo == Entrada.login
                ? Row(
                    children: [
                      SizedBox(width: scW * 0.07),
                      Checkbox(
                        value: inputLembrar,
                        onChanged: (valor) => setState(() => inputLembrar = !inputLembrar),
                      ),
                      InkWell(
                        onTap: () => setState(() => inputLembrar = !inputLembrar),
                        splashFactory: NoSplash.splashFactory,
                        splashColor: Colors.transparent,
                        child: const Text(
                          "Lembre-se de mim!",
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    ],
                  )
                : const SizedBox(),
            const SizedBox(height: 27),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar", style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 10),
                botaoLogin(context),
                SizedBox(width: scW * 0.1),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  FilledButton botaoLogin(BuildContext context) {
    return FilledButton(
      onPressed: !conectando
          ? () async {
              // Validate returns true if the form is valid, or false otherwise.
              if (_formKey.currentState!.validate()) {
                Flushbar flushbar = Flushbar(
                  message: "Conectando...",
                  duration: const Duration(seconds: 3),
                  margin: const EdgeInsets.all(20),
                  borderRadius: BorderRadius.circular(50),
                );
                setState(() {
                  conectando = true;
                });
                flushbar.show(context);
                TextInput.finishAutofillContext();
                var retorno = await autenticar(
                  txtControllerLogin.text,
                  txtControllerSenha.text,
                  widget.modo,
                );
                if (!context.mounted) return;
                if (retorno is String) {
                  Flushbar(
                    duration: const Duration(seconds: 5),
                    margin: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(50),
                    messageText: Row(
                      children: [
                        Icon(
                          Icons.error_rounded,
                          color: blueScheme.onErrorContainer,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          retorno,
                          style: TextStyle(
                            color: blueScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: blueScheme.errorContainer,
                  ).show(context);
                  setState(() {
                    conectando = false;
                  });
                } else {
                  flushbar.dismiss();
                  setState(() {
                    conectando = false;
                    txtControllerSenha.text = "";
                    txtControllerLogin.text = "";
                  });
                  Future.delayed(Duration.zero, () {
                    Navigator.pop(context, widget.modo == Entrada.login ? (true, inputLembrar) : true);
                  });
                }
              }
            }
          : null,
      child: Text(
        widget.modo == Entrada.login ? "Entrar" : "Cadastrar",
        style: const TextStyle(fontSize: 18),
      ),
    );
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;

  SlideRightRoute(this.page)
      : super(
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
              reverseCurve: Curves.fastOutSlowIn,
            )),
            child: child,
          ),
        );
}
