import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/components/post.dart';
import 'package:gatopedia/telas/home/gatos/gatos.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool postado = false;
String imagemTipo = "";
String legenda = "";
File? file; /* arquivo pra comprimir a imagem de upload do post */
final txtPost = TextEditingController();

class Forum extends StatefulWidget {
  final ScrollController scrollForum;
  final void Function() setStateGatos;
  final AnimationController animController;
  final Animation<double> anim;
  final EdgeInsets pd;

  const Forum(this.scrollForum, this.setStateGatos, this.animController, this.anim, this.pd, {super.key});

  @override
  State<Forum> createState() => _ForumState();
}

enum MenuItems { editar, deletar }

bool iniciouListenForum = false;
double scrollSalvo = 0;
double scrollAcumulado = 0;

class _ForumState extends State<Forum> {
  _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    ref.onValue.listen((event) {
      if (!mounted) return;
      setState(() {
        Gatos.snapshotForum.value = event.snapshot;
      });
    });
  }

  void _barHideListen() {
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

      if (scrollAcumulado > (kToolbarHeight * 2.86) / 2 && !expandido) {
        if (!mounted) return;
        setState(() {
          expandido = true;
          offsetInicial = off;

          widget.animController.reverse();
        });
      } else if (scrollAcumulado < (-(kToolbarHeight * 2.86) / 2) && expandido) {
        if (!mounted) return;
        setState(() {
          expandido = false;
          offsetInicial = off;

          widget.animController.forward();
        });
      }
      SharedPreferences.getInstance().then((sp) {
        sp.setDouble("scrollSalvo", off);
      });
    });
  }

  late double offsetInicial = widget.scrollForum.offset;

  @override
  void initState() {
    super.initState();
    tabIndex = 1;
    if (!iniciouListenForum) {
      _atualizar();
      iniciouListenForum = true;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!expandido && scrollSalvo < ((kToolbarHeight * 2.86) / 2)) {
        setState(() {
          expandido = true;

          widget.animController.reverse();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Gatos.snapshotForum.value != null
            ? StretchingOverscrollIndicator(
                axisDirection: AxisDirection.down,
                child: ListView.builder(
                  controller: widget.scrollForum,
                  itemCount: int.parse(Gatos.snapshotForum.value!.children.last.key!) + 1,
                  itemBuilder: (context, i) {
                    if (!_comecouListen) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        widget.scrollForum.jumpTo(scrollSalvo);
                        _barHideListen();
                        _comecouListen = true;
                      });
                    }
                    final lastKey = Gatos.snapshotForum.value!.children.last.key!;
                    return Gatos.snapshotForum.value!
                                .child("${int.parse(Gatos.snapshotForum.value!.children.last.key!) - i}")
                                .value !=
                            null
                        ? Post(
                            int.parse(Gatos.snapshotForum.value!.children.last.key!) - i,
                            widget.pd,
                            int.parse(Gatos.snapshotForum.value!.children.last.key!) - i == int.parse(lastKey),
                          )
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
