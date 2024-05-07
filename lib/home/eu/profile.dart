import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/home/eu/pp_edit.dart';
import 'package:gatopedia/home/home.dart';
import 'package:gatopedia/main.dart';
import 'package:google_fonts/google_fonts.dart';

String bioText = "carregando...";
bool? temImagem;
const _shimmerGradient = LinearGradient(
  colors: [
    Color(0xFFEBEBF4),
    Color(0xFFF4F4F4),
    Color(0xFFEBEBF4),
  ],
  stops: [
    0.1,
    0.3,
    0.4,
  ],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
  tileMode: TileMode.clamp,
);

enum MenuItensImg { editar, remover }

enum MenuItensSemImg { adicionar }

class Profile extends StatefulWidget {
  final bool botaoVoltar;

  const Profile(this.botaoVoltar, {super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool editMode = false;
  final txtBio = TextEditingController();
  final focusCoiso = FocusNode();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _apagarImagem(String username) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    final ref = database.ref("users/$username/img");
    FirebaseStorage storage = FirebaseStorage.instance;
    final refS = storage.ref("users/$username.webp");
    await ref.remove();
    await refS.delete();
  }

  _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users");
    ref.onValue.listen((event) {
      if ((event.snapshot.value as Map)[username]["bio"] != null) {
        setState(() {
          bioText = (event.snapshot.value as Map)[username]["bio"];
        });
      } else {
        bioText = "(vazio)";
      }
      setState(
        () => temImagem = ((event.snapshot.value as Map)[username]["img"] ?? false),
      );
    });
  }

  _salvarBio(String bio) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users/$username");
    await ref.update({"bio": bio});
  }

  @override
  void initState() {
    indexAntigo = 1;
    _atualizar();
    temImagem = false;
    super.initState();
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
                Text(
                  "Bio",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[700]!,
                  ),
                ),
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
                icon: const Icon(
                  Icons.more_vert_rounded,
                  shadows: [
                    Shadow(blurRadius: 10),
                  ],
                  color: Colors.white,
                ),
                onSelected: (value) async {
                  if (value == MenuItensImg.editar) {
                    var resposta = await Navigator.push(
                      context,
                      SlideRightAgainRoute(const PPEdit()),
                    );
                    if (!context.mounted) return;
                    if (resposta != null) {
                      if (resposta) {
                        setState(() {
                          CachedNetworkImage.evictFromCache(
                            "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media",
                          );
                        });
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
                        icon: const Icon(Icons.delete_rounded),
                        title: const Text(
                          "Tem certeza que deseja remover sua foto de perfil?",
                          textAlign: TextAlign.center,
                        ),
                        content: const Text(
                          "Essa ação é irreversível",
                          textAlign: TextAlign.center,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text("CANCELAR"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text("OK"),
                          )
                        ],
                      ),
                    ).then(
                      (value) async {
                        if (value ?? false) {
                          await _apagarImagem(username!);
                          setState(() {
                            CachedNetworkImage.evictFromCache(
                              "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media",
                            );
                          });
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItensImg>>[
                  const PopupMenuItem(
                    value: MenuItensImg.editar,
                    child: Row(
                      children: [
                        Icon(Icons.add_photo_alternate_rounded),
                        SizedBox(width: 10),
                        Text("Mudar foto de perfil"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: MenuItensImg.remover,
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever_rounded),
                        SizedBox(width: 10),
                        Text("Remover foto de perfil"),
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
                  shadows: [
                    Shadow(blurRadius: 10),
                  ],
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (value) async {
                  if (value == MenuItensSemImg.adicionar) {
                    var resposta = await Navigator.push(
                      context,
                      SlideRightAgainRoute(const PPEdit()),
                    );
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
                  const PopupMenuItem(
                    value: MenuItensSemImg.adicionar,
                    child: Row(
                      children: [
                        Icon(Icons.add_photo_alternate_rounded),
                        SizedBox(width: 10),
                        Text("Adicionar foto de perfil"),
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
      iconTheme: const IconThemeData(
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.black,
            blurRadius: 20,
          ),
        ],
      ),
      expandedHeight: 400,
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      flexibleSpace: FlexibleSpaceBar(
        title: Text("@$username", style: GoogleFonts.jost()),
        background: Stack(
          fit: StackFit.expand,
          children: [
            temImagem ?? false
                ? FadeInImage(
                    fadeInDuration: const Duration(milliseconds: 100),
                    placeholder: const AssetImage("assets/user.webp"),
                    image: CachedNetworkImageProvider(
                      "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media",
                    ),
                    imageErrorBuilder: (context, obj, stck) {
                      return Image.asset("assets/user.webp", fit: BoxFit.cover);
                    },
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/user.webp",
                    fit: BoxFit.cover,
                  ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.0, 0.5),
                  end: Alignment.center,
                  colors: <Color>[
                    Color(0x60000000),
                    Color(0x00000000),
                  ],
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
        SelectableText(
          bioText,
          style: const TextStyle(
            fontFamily: "Jost",
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  editMode = true;
                  txtBio.text = bioText;
                  focusCoiso.requestFocus();
                });
              },
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
        const SizedBox(
          height: 10,
        ),
        TextField(
          maxLength: 400,
          controller: txtBio,
          maxLines: 2,
          focusNode: focusCoiso,
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
        const SizedBox(
          height: 10,
        ),
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

class Carregandor extends StatefulWidget {
  const Carregandor({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  State<Carregandor> createState() => _CarregandorState();
}

class _CarregandorState extends State<Carregandor> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return _shimmerGradient.createShader(bounds);
      },
      child: widget.child,
    );
  }
}
