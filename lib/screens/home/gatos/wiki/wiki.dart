import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/components/gato_card.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/screens/home/gatos/gatos.dart';

class Wiki extends StatefulWidget {
  final ScrollController scrollWiki;
  final AnimationController animController;
  final EdgeInsets pd;

  const Wiki(this.scrollWiki, this.animController, this.pd, {super.key});

  @override
  State<Wiki> createState() => _WikiState();
}

double scrollSalvoWiki = 0;
double scrollAcumuladoWiki = 0;

class _WikiState extends State<Wiki> with AutomaticKeepAliveClientMixin {
  late Future<DataSnapshot> _getData;
  bool pegouInfo = false;

  String _pegarIdioma() {
    return App.localeNotifier.value.languageCode;
  }

  void _pegarInfo() {
    _getData = FirebaseDatabase.instance.ref().child("gatos_${_pegarIdioma()}").get();
  }

  @override
  void initState() {
    super.initState();
    tabIndex = 0;
    if (!pegouInfo) {
      _pegarInfo();
      pegouInfo = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: FutureBuilder<DataSnapshot>(
        future: _getData,
        builder: (context, snapshot) {
          Widget child;
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            child = ListView.builder(
              controller: widget.scrollWiki,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: username == null && index == 9 ? (80 + MediaQuery.paddingOf(context).bottom) : 0),
                  child: GatoCard(index, snapshot.data!.children.toList()[index], widget.pd),
                );
              },
              itemCount: snapshot.data!.children.length,
            );
          } else {
            child = const Center(child: CircularProgressIndicator());
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: child,
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
