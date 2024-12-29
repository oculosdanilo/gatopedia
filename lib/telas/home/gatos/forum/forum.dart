import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:gatopedia/components/post.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/gatos/gatos.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool postado = false;
String imagemTipo = "";
String legenda = "";
File? file; /* arquivo pra comprimir a imagem de upload do post */
final txtPost = TextEditingController();
final fagKey = GlobalKey<ExpandableFabState>();

class Forum extends StatefulWidget {
  final ScrollController scrollForum;
  final void Function() setStateGatos;

  const Forum(this.scrollForum, this.setStateGatos, {super.key});

  @override
  State<Forum> createState() => _ForumState();
}

enum MenuItems { editar, deletar }

bool iniciouListenForum = false;
double scrollSalvo = 0;
double scrollAcumulado = 0;
bool pasosu = false;

class _ForumState extends State<Forum> {
  _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    ref.onValue.listen((event) {
      setState(() {
        snapshotForum = event.snapshot;
      });
    });
  }

  void _barHideListen() {
    expandido = true;
    scrollAcumulado = 0;
    widget.setStateGatos();

    widget.scrollForum.position.isScrollingNotifier.addListener(() {
      double off = widget.scrollForum.offset;
      if (!widget.scrollForum.position.isScrollingNotifier.value) {
        if ((scrollAcumulado < 0 && !expandido) || (scrollAcumulado > 0 && expandido)) {
          offsetInicial = off;
        }
      }
    });

    widget.scrollForum.addListener(() {
      double off = widget.scrollForum.offset;
      scrollSalvo = off;
      scrollAcumulado = offsetInicial - off;

      if (scrollAcumulado > kToolbarHeight * 2.86 && !expandido) {
        if (!mounted) return;
        setState(() {
          expandido = true;
          offsetInicial = off;
        });
        widget.setStateGatos();
      } else if (scrollAcumulado < -(kToolbarHeight * 2.86) && expandido) {
        if (!mounted) return;
        setState(() {
          expandido = false;
          offsetInicial = off;
        });
        widget.setStateGatos();
      }
      SharedPreferences.getInstance().then((sp) {
        sp.setDouble("scrollSalvo", off);
      });
    });
  }

  @override
  void initState() {
    // TODO: fazer o appbar() encolher beijos :*
    super.initState();
    tabIndex = 1;
    if (!iniciouListenForum) {
      _atualizar();
      iniciouListenForum = true;
    }
  }

  late double offsetInicial = widget.scrollForum.offset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.fromLTRB(10, !expandido ? 0 : kToolbarHeight * 2.86, 10, 0),
        child: snapshotForum != null
            ? StretchingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                child: ListView.builder(
                  controller: widget.scrollForum,
                  itemCount: int.parse(snapshotForum!.children.last.key!) + 1,
                  itemBuilder: (context, i) {
                    if (!_comecouListen) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _barHideListen();
                        _comecouListen = true;
                      });
                    }
                    return snapshotForum!.child("${int.parse(snapshotForum!.children.last.key!) - i}").value != null
                        ? Post(int.parse("${int.parse(snapshotForum!.children.last.key!) - i}"))
                        : const SizedBox();
                  },
                ),
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  bool _comecouListen = false;
}
