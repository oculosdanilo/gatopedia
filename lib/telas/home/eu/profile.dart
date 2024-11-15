import 'dart:async';

import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/telas/home/eu/pp_edit.dart';
import 'package:gatopedia/telas/home/home.dart';
import 'package:gatopedia/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MenuItensImg { editar, remover }

enum MenuItensSemImg { adicionar }

StreamSubscription<DatabaseEvent>? atualizarListen;

String bioText = "carregando...";
bool? temImagem;

String? imagemGoogle;

class Profile extends StatefulWidget {
  final bool botaoVoltar;

  const Profile(this.botaoVoltar, {super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool editMode = false;
  final txtBio = TextEditingController();

  late Future<String?> _pegarImgGoogleVar;

  _apagarImagem(String username) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    final ref = database.ref("users/$username/img");
    FirebaseStorage storage = FirebaseStorage.instance;
    final refS = storage.ref("users/$username.webp");
    await ref.remove();
    await refS.delete();
  }

  _atualizar() async {
    final sp = await SharedPreferences.getInstance();
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users/$username");
    atualizarListen = ref.onValue.listen((event) {
      final data = event.snapshot;
      if (data.child("bio").value != null) {
        setState(() => bioText = "${data.child("bio").value}");
        sp.setString("bio", "${data.child("bio").value}");
      } else {
        setState(() => bioText = "(vazio)");
        sp.setString("bio", "(vazio)");
      }
      if (data.child("img").value != null) {
        setState(() => temImagem = true);
      } else {
        setState(() => temImagem = false);
      }
      sp.setBool("img", (data.child("img").value != null));
    });
  }

  _salvarBio(String bio) async {
    final ref = FirebaseDatabase.instance.ref("users/$username");
    await ref.update({"bio": bio});
  }

  _init() async {
    final sp = await SharedPreferences.getInstance();
    if (sp.containsKey("bio") && sp.containsKey("img")) {
      setState(() {
        bioText = sp.getString("bio")!;
        temImagem = sp.getBool("img")!;
      });
    }
    _atualizar();
  }

  Future<String?> _pegarImgGoogle() async {
    final refUser = FirebaseDatabase.instance.ref("users/$username/img");
    final imgInfo = await refUser.get();
    if (imgInfo.exists) {
      return "${imgInfo.value}";
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    indexAntigo = 1;
    temImagem = false;
    _pegarImgGoogleVar = _pegarImgGoogle();
    _init();
  }

  @override
  void dispose() {
    atualizarListen?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const PageScrollPhysics(),
      slivers: [
        appbar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Bio", style: TextStyle(fontSize: 15, color: Colors.grey[700]!)),
                editMode ? editando(context) : estatico()
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar appbar(BuildContext context) {
    return SliverAppBar(
      actions: temImagem ?? false
          ? [
              PopupMenuButton<MenuItensImg>(
                icon: const Icon(Icons.more_vert_rounded, shadows: [Shadow(blurRadius: 10)], color: Colors.white),
                onSelected: (value) async {
                  if (value == MenuItensImg.editar) {
                    var resposta = await Navigator.push(context, SlideRightAgainRoute(const PPEdit()));
                    if (resposta != null) {
                      if (resposta) {
                        setState(() {
                          CachedNetworkImage.evictFromCache(
                              "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media");
                        });
                        if (!context.mounted) return;
                        Flushbar(
                          message: "Atualizada com sucesso!",
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(50),
                        ).show(context);
                      }
                    }
                  } else {
                    showCupertinoDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        icon: Icon(Icons.delete_rounded, color: Theme.of(context).colorScheme.error),
                        title: const Text(
                          "Tem certeza que deseja remover sua foto de perfil?",
                          textAlign: TextAlign.center,
                        ),
                        content: const Text("Essa ação é irreversível", textAlign: TextAlign.center),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("CANCELAR"),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("OK"),
                          )
                        ],
                      ),
                    ).then(
                      (value) async {
                        if (value ?? false) {
                          await _apagarImagem(username!);
                          setState(() => CachedNetworkImage.evictFromCache(
                              "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media"));
                          if (!context.mounted) return;
                          Flushbar(
                            message: "Removida com sucesso!",
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(20),
                            borderRadius: BorderRadius.circular(50),
                          ).show(context);
                        }
                      },
                    );
                  }
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: MenuItensImg.editar,
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          shadows: const [],
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        const Text("Mudar foto de perfil"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: MenuItensImg.remover,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_forever_rounded,
                          shadows: const [],
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        const Text("Remover foto de perfil"),
                      ],
                    ),
                  ),
                ],
              ),
            ]
          : [
              PopupMenuButton<MenuItensSemImg>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  shadows: [Shadow(blurRadius: 10)],
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onSelected: (value) async {
                  if (value == MenuItensSemImg.adicionar) {
                    var resposta = await Navigator.push(context, SlideRightAgainRoute(const PPEdit()));
                    if (!context.mounted) return;
                    if (resposta != null) {
                      if (resposta) {
                        Flushbar(
                          message: "Adicionada com sucesso!",
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(50),
                        ).show(context);
                      }
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItensSemImg>>[
                  PopupMenuItem(
                    value: MenuItensSemImg.adicionar,
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          shadows: const [],
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        const Text("Adicionar foto de perfil"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
      leading: widget.botaoVoltar
          ? IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              color: Colors.white,
            )
          : null,
      automaticallyImplyLeading: widget.botaoVoltar,
      iconTheme: const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 20)]),
      expandedHeight: 400,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      flexibleSpace: FlexibleSpaceBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(username!, style: TextStyle(color: Colors.white)),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            temImagem ?? false
                ? imagemGoogle != null
                    ? Image.network(imagemGoogle!, fit: BoxFit.cover)
                    : FadeInImage(
                        fadeInDuration: const Duration(milliseconds: 100),
                        placeholder: const AssetImage("assets/anim/loading.gif"),
                        image: CachedNetworkImageProvider(
                            "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media"),
                        imageErrorBuilder: (context, obj, stck) {
                          return FutureBuilder<String?>(
                            future: _pegarImgGoogleVar,
                            builder: (context, snapshot) {
                              if (snapshot.hasData || snapshot.connectionState == ConnectionState.done) {
                                if (snapshot.data != null) {
                                  imagemGoogle = snapshot.data!;
                                  return FadeInImage(
                                    fadeInDuration: const Duration(milliseconds: 100),
                                    placeholder: const AssetImage("assets/anim/loading.gif"),
                                    image: NetworkImage(snapshot.data!),
                                    imageErrorBuilder: (context, obj, stck) =>
                                        Image.asset("assets/user.webp", fit: BoxFit.cover),
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Image.asset("assets/user.webp", fit: BoxFit.cover);
                                }
                              } else {
                                return Image.asset("assets/anim/loading.gif", fit: BoxFit.cover);
                              }
                            },
                          );
                        },
                        /*FadeInImage(
                      fadeInDuration: const Duration(milliseconds: 100),
                      placeholder: const AssetImage("assets/anim/loading.gif"),
                      image: NetworkImage(),
                      imageErrorBuilder: (context, obj, stck) => Image.asset("assets/user.webp", fit: BoxFit.cover),
                      fit: BoxFit.cover,
                    ),*/
                        fit: BoxFit.cover,
                      )
                : Image.asset("assets/user.webp", fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.0, 0.5),
                  end: Alignment.center,
                  colors: [Color(0x60000000), Color(0x00000000)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column estatico() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(bioText, style: TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: bioText != "carregando..."
                  ? () {
                      setState(() {
                        editMode = true;
                        txtBio.text = bioText;
                        FocusNode().requestFocus();
                      });
                    }
                  : null,
              icon: const Icon(Icons.edit_rounded),
              label: const Text("Editar bio"),
            ),
          ],
        ),
      ],
    );
  }

  Column editando(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        TextField(
          maxLength: 255,
          controller: txtBio,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: "(vazio)",
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () {
                setState(() {
                  editMode = false;
                });
              },
              child: const Text("CANCELAR"),
            ),
            FilledButton(
              child: const Text("SALVAR"),
              onPressed: () async {
                if (txtBio.text != "" && txtBio.text != bioText) {
                  _salvarBio(txtBio.text);
                  if (mounted) {
                    setState(() {
                      editMode = false;
                    });
                  }
                  Flushbar(
                    message: "Atualizado com sucesso!",
                    duration: const Duration(seconds: 2),
                    margin: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(50),
                  ).show(context);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
