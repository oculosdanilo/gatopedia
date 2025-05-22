import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/components/gato_card.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/gatos/gatos.dart';

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

  @override
  void initState() {
    super.initState();
    tabIndex = 0;
    if (!pegouInfo) {
      _getData = FirebaseDatabase.instance.ref().child("gatos").get();
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
          Widget filho;
          if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
            filho = ListView.builder(
              controller: widget.scrollWiki,
              itemBuilder: (context, index) {
                return username == null && index == 10
                    ? SizedBox(height: 80 + MediaQuery.paddingOf(context).bottom)
                    : GatoCard(index, snapshot.data!.children.toList()[index], widget.pd);
              },
              itemCount: snapshot.data!.children.length + (username != null ? 0 : 1),
            );
          } else {
            filho = const Center(child: CircularProgressIndicator());
          }

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: filho,
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
