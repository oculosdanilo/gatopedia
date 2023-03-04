// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

void main() {
  runApp(MainApp());
}

// ignore: must_be_immutable
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(children: [
        TextFormField(
          decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.alternate_email_rounded,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                    width: 2,
                    color: ColorScheme.fromSeed(
                            seedColor: Color(0xff000080),
                            brightness: Brightness.dark)
                        .outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                borderSide: BorderSide(
                    width: 2,
                    color: ColorScheme.fromSeed(
                            seedColor: Color(0xff000080),
                            brightness: Brightness.dark)
                        .primary),
              ),
              label: Text("Login", style: TextStyle(fontFamily: "Jost"))),
        ),
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(
                    width: 2,
                    color: ColorScheme.fromSeed(
                            seedColor: Color(0xff000080),
                            brightness: Brightness.dark)
                        .outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                borderSide: BorderSide(
                    width: 2,
                    color: ColorScheme.fromSeed(
                            seedColor: Color(0xff000080),
                            brightness: Brightness.dark)
                        .primary),
              ),
              label: Text("Senha", style: TextStyle(fontFamily: "Jost"))),
        ),
      ]),
    );
  }
}
