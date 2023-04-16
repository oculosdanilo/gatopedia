import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/home/eu/pp_edit.dart';

import '../../main.dart';
import '../home.dart';

String bioText = "(vazio)";
bool? temImagem;

enum MenuItensImg { editar, remover }

enum MenuItensSemImg { adicionar }

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool editMode = false;
  final txtBio = TextEditingController();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  pegarImagens() async {
    await Firebase.initializeApp();
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users/");
    DataSnapshot userinfo = await ref.get();
    int i = 0;
    while (i < userinfo.children.length) {
      if (((userinfo.children).toList()[i].value as Map)["img"] != null) {
        setState(() {
          listaTemImagem.add(
            "${(userinfo.children.map((i) => i)).toList()[i].key}",
          );
        });
      }
      i++;
    }
    debugPrint("$listaTemImagem");
  }

  _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users");
    ref.onValue.listen((event) {
      _pegarUserinfo(username);
    });
  }

  _pegarUserinfo(username) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users/");
    ref.get().then(
      (value) {
        if ((value.value as Map)[username] != null) {
          if ((value.value as Map)[username]["bio"] != null) {
            setState(() {
              bioText = (value.value as Map)[username]["bio"];
              temImagem = ((value.value as Map)[username]["img"] ?? false);
            });
          } else {
            bioText = "(vazio)";
          }
        } else {
          bioText = "(vazio)";
        }
      },
    );
  }

  _salvarBio(String bio) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users/$username");
    ref.update({"bio": bio});
  }

  @override
  void initState() {
    pegarImagens();
    indexAntigo = 1;
    _atualizar();
    _pegarUserinfo(username);
    temImagem = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          actions: (temImagem ?? false)
              ? [
                  PopupMenuButton<MenuItensImg>(
                    onSelected: (value) {
                      if (value == MenuItensImg.editar) {
                        Navigator.push(
                          context,
                          SlideRightAgainRoute(const PPEdit()),
                        );
                      } else {
                        debugPrint("aafolou");
                      }
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<MenuItensImg>>[
                      PopupMenuItem(
                        value: MenuItensImg.editar,
                        child: Row(
                          children: const [
                            Icon(Icons.edit_rounded),
                            SizedBox(width: 10),
                            Text("Mudar foto de perfil"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: MenuItensImg.remover,
                        child: Row(
                          children: const [
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
                  PopupMenuButton<MenuItensImg>(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<MenuItensImg>>[
                      PopupMenuItem(
                        child: Row(
                          children: const [
                            Icon(Icons.add_photo_alternate_rounded),
                            SizedBox(width: 10),
                            Text("Adicionar foto de perfil"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
          automaticallyImplyLeading: false,
          expandedHeight: 300,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            title: Text("@$username"),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: (temImagem ?? false)
                      ? NetworkImage(
                          "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.png?alt=media")
                      : const AssetImage("lib/assets/user.webp")
                          as ImageProvider,
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
        ),
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
                      fontFamily: "Jost",
                      color: Colors.grey[700]!),
                ),
                editMode
                    ? Column(
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
                                  if (txtBio.text != "" &&
                                      txtBio.text != bioText) {
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
                      )
                    : Column(
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
                                  });
                                },
                                icon: const Icon(Icons.edit_rounded),
                                label: const Text("Editar bio"),
                              ),
                            ],
                          ),
                        ],
                      )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
