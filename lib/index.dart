// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:gatopedia/loginScreen/colab.dart';
import 'package:gatopedia/main.dart';
import 'package:material_symbols_icons/symbols.dart';

class Index extends StatefulWidget {
  const Index({super.key});

  @override
  State<Index> createState() => _IndexState();
}

class _IndexState extends State<Index> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
