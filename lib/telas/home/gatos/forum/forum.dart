import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/components/post.dart';
import 'package:gatopedia/telas/home/gatos/gatos.dart';

bool postado = false;
String imagemTipo = "";
String legenda = "";
File? file; /* arquivo pra comprimir a imagem de upload do post */
final txtPost = TextEditingController();

class Forum extends StatefulWidget {
  static late final ValueNotifier<DataSnapshot?> snapshotForum;
  final ScrollController scrollForum;
  final AnimationController animController;
  final EdgeInsets pd;

  const Forum(this.scrollForum, this.animController, this.pd, {super.key});

  @override
  State<Forum> createState() => _ForumState();
}

enum MenuItems { editar, deletar }

bool iniciouListenForum = false;
double scrollSalvo = 0;
double scrollAcumulado = 0;

class _ForumState extends State<Forum> with AutomaticKeepAliveClientMixin {
  _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts");
    ref.onValue.listen((event) {
      if (!mounted) return;
      setState(() {
        Forum.snapshotForum.value = event.snapshot;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    tabIndex = 1;
    if (!iniciouListenForum) {
      _atualizar();
      iniciouListenForum = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder<DataSnapshot?>(
        valueListenable: Forum.snapshotForum,
        builder: (context, snapshotForum, _) {
          return Scaffold(
            body: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: snapshotForum?.value != null
                  ? StretchingOverscrollIndicator(
                      axisDirection: AxisDirection.down,
                      child: ListView.builder(
                        controller: widget.scrollForum,
                        itemCount: int.parse(snapshotForum!.children.last.key!) + 1,
                        itemBuilder: (context, i) {
                          final lastKey = snapshotForum.children.last.key!;
                          return snapshotForum.child("${int.parse(snapshotForum.children.last.key!) - i}").value != null
                              ? Post(
                                  int.parse(snapshotForum.children.last.key!) - i,
                                  widget.pd,
                                  int.parse(snapshotForum.children.last.key!) - i == int.parse(lastKey),
                                )
                              : const SizedBox();
                        },
                      ),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
