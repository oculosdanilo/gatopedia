// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:gatopedia/home/config/config.dart';
import 'package:gatopedia/loginScreen/colab.dart';
import 'package:gatopedia/main.dart';
import 'package:just_audio/just_audio.dart';
import 'package:material_symbols_icons/symbols.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  bool animImg = false;
  bool animText = false;
  final miau = AudioPlayer();

  @override
  void initState() {
    super.initState();
    miau.setAsset("assets/meow.mp3").then((value) {
      miau.play();
      Future.delayed(value!, () {
        setState(() {
          animImg = true;
        });
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            animText = true;
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            width: MediaQuery.of(context).size.width,
            top: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedOpacity(
                  duration: Duration(milliseconds: 200),
                  opacity: animText ? 1 : 0,
                  child: Text(
                    "Gatopédia!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 75,
                ),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: animText ? 1 : 0,
                  curve: Interval(0.5, 1),
                  child: FilledButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      fixedSize: MaterialStatePropertyAll(
                        Size(MediaQuery.of(context).size.width * 0.7, 50),
                      ),
                    ),
                    child: Text(
                      "Entrar",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 400),
                  opacity: animText ? 1 : 0,
                  curve: Interval(0.5, 1),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: ButtonStyle(
                      fixedSize: MaterialStatePropertyAll(
                        Size(MediaQuery.of(context).size.width * 0.7, 50),
                      ),
                    ),
                    child: Text(
                      "Cadastrar",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: animText ? 1 : 0,
                  curve: Interval(0.5, 1),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Row(),
                  ),
                ),
              ],
            ),
          ),
          AnimatedPositioned(
            curve: Curves.ease,
            duration: Duration(milliseconds: 500),
            left: (MediaQuery.of(context).size.width / 2) - 125,
            top: animImg ? 150 : (MediaQuery.of(context).size.height / 2) - 125,
            child: ClipOval(
              child: Image.asset(
                "assets/icon.png",
                width: 250,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Align(
              alignment: Alignment.topRight,
              child: PopupMenuButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    onTap: () => Navigator.push(
                      context,
                      SlideUpRoute(Colaboradores()),
                    ),
                    child: Row(
                      children: [
                        Icon(Symbols.people_rounded),
                        SizedBox(width: 15),
                        Text("Colaboradores"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () => Navigator.push(
                      context,
                      SlideUpRoute(Scaffold(body: Config())),
                    ),
                    child: Row(
                      children: [
                        Icon(Symbols.settings_rounded),
                        SizedBox(width: 15),
                        Text("Configurações"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
