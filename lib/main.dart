// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';

void main() {
  final blueScheme = ColorScheme.fromSeed(
      seedColor: Color(0xff000080), brightness: Brightness.dark);
  runApp(MaterialApp(
    theme: ThemeData(
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(width: 2, color: blueScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          borderSide: BorderSide(width: 2, color: blueScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(width: 3, color: blueScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(width: 3, color: blueScheme.error),
        ),
      ),
      brightness: Brightness.dark,
      colorSchemeSeed: Color(0xff000080),
      useMaterial3: true,
    ),
    home: Gatopedia(),
  ));
}

class Gatopedia extends StatelessWidget {
  const Gatopedia({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              Image(
                image: const AssetImage('lib/assets/icon.png'),
                width: 270,
              ),
              Text(
                'Gatopédia!',
                style: TextStyle(
                    fontSize: 35,
                    fontFamily: "Jost",
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 60,
              ),
              SizedBox(
                width: 300,
              ),
              const FormApp()
            ],
          ),
        ),
      ),
    );
  }
}

class FormApp extends StatefulWidget {
  const FormApp({super.key});

  @override
  LoginState createState() {
    return LoginState();
  }
}

class LoginState extends State<FormApp> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            width: 300,
            child: TextFormField(
              onChanged: (value) {
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Obrigatório';
                } else if (!value.contains(RegExp(r'^[a-zA-Z0-9]+$'))) {
                  return 'Caractere(s) inválido(s)!';
                }
                return null;
              },
              decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.alternate_email_rounded,
                  ),
                  label: Text("Login", style: TextStyle(fontFamily: "Jost"))),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 300,
            child: TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                  label: Text("Senha", style: TextStyle(fontFamily: "Jost"))),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // SystemNavigator.pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('saindo...')),
                  );
                },
                child: Text(
                  "Sair",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              FilledButton(
                onPressed: () {
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('hmmm')),
                    );
                  }
                },
                child: Text(
                  "Cadastrar",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          OutlinedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Colaboradores()));
              },
              child: Text("COLABORADORES")),
        ],
      ),
    );
  }
}

class Colaboradores extends StatelessWidget {
  Colaboradores({super.key});
  final blueScheme = ColorScheme.fromSeed(
      seedColor: Color(0xff000080), brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: prefer_const_literals_to_create_immutables
      body: CustomScrollView(slivers: [
        SliverAppBar.large(
          iconTheme: IconThemeData(color: blueScheme.onPrimary),
          title: Text(
            "COLABORADORES",
            style: TextStyle(color: blueScheme.onPrimary),
          ),
          backgroundColor: blueScheme.primary,
        ),
      ]),
    );
  }
}
