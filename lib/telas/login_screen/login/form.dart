import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/gatos/forum/forum.dart';
import 'package:gatopedia/telas/home/gatos/wiki/wiki.dart';
import 'package:gatopedia/telas/home/home.dart';
import 'package:gatopedia/telas/login_screen/login/autenticar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormApp extends StatefulWidget {
  final BuildContext modalContext;

  const FormApp(this.modalContext, {super.key});

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

  late final scW = MediaQuery.sizeOf(context).width;
  late final scH = MediaQuery.sizeOf(context).height;

  void mudarCor(Color cor) {
    setState(() {
      counterColor = cor;
    });
  }

  void mostrarSenha() {
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
    return AutofillGroup(
      child: Form(
        key: _formKey,
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
                      mudarCor(Theme.of(context).colorScheme.onSurface);
                    }
                  });
                  _formKey.currentState!.validate();
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppLocalizations.of(context).login_err1;
                  } else if (!value.contains(RegExp(r'^[a-zA-Z0-9._]+$'))) {
                    return AppLocalizations.of(context).login_err2;
                  } else if (value.length <= 3) {
                    return AppLocalizations.of(context).login_err3;
                  } else if (value.contains(RegExp(r'^[0-9]+$'))) {
                    return AppLocalizations.of(context).login_err4;
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
                        Text("/25", style: TextStyle(color: blueScheme.outline))
                      ],
                    ),
                  ),
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  label: Text(AppLocalizations.of(context).login_username),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
                  prefix: const SizedBox(width: 10),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: IconButton(onPressed: () => mostrarSenha(), icon: iconeOlho),
                  ),
                  label: Text(AppLocalizations.of(context).login_password),
                ),
              ),
            ),
            const SizedBox(height: 17),
            Row(
              children: [
                SizedBox(width: scW * 0.07),
                Checkbox(
                  value: inputLembrar,
                  onChanged: (valor) => setState(() => inputLembrar = !inputLembrar),
                ),
                GestureDetector(
                  onTap: () => setState(() => inputLembrar = !inputLembrar),
                  child: Text(
                    AppLocalizations.of(context).login_remindMe,
                    style: const TextStyle(fontSize: 18),
                  ),
                )
              ],
            ),
            const SizedBox(height: 27),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).cancel),
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
              if (_formKey.currentState!.validate()) {
                setState(() => conectando = true);
                TextInput.finishAutofillContext();
                var retorno = await entrar(context, txtControllerLogin.text, txtControllerSenha.text);
                if (!context.mounted) return;
                if (retorno is String) {
                  Flushbar(
                    duration: const Duration(seconds: 5),
                    margin: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(50),
                    messageText: Row(
                      children: [
                        Icon(Icons.error_rounded, color: blueScheme.onErrorContainer),
                        const SizedBox(width: 10),
                        Text(retorno, style: TextStyle(color: blueScheme.onErrorContainer)),
                      ],
                    ),
                    backgroundColor: blueScheme.errorContainer,
                  ).show(context);
                  setState(() {
                    conectando = false;
                  });
                } else {
                  if (inputLembrar) {
                    SharedPreferences sp = await SharedPreferences.getInstance();
                    await sp.setString("username", username ?? "");
                  }
                  setState(() {
                    conectando = false;
                    scrollSalvoWiki = 0;
                    scrollSalvo = 0;
                    scrollAcumulado = 0;
                    txtControllerSenha.text = txtControllerLogin.text = "";
                  });
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  Navigator.pushReplacement(context, SlideUpRoute(const Home()));
                }
              }
            }
          : null,
      child: Text(AppLocalizations.of(context).login),
    );
  }
}
