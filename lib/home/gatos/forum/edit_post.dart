// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

import 'package:gatopedia/main.dart';

import '../../config/config.dart';

bool imagemRemovida = false;
File? imagemFile;
bool imagemSelecionada = false;

class EditPost extends StatefulWidget {
  dynamic post;
  bool imagem = false;

  EditPost(this.post, this.imagem, {super.key});

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final txtEdit = TextEditingController();

  _pegarImagem() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: ['jpeg', 'jpg', 'png', 'webp', 'gif'],
      type: FileType.custom,
      allowMultiple: false,
    );
    if (result != null) {
      debugPrint("${result.paths.first}");
      setState(() {
        imagemFile = File(result.paths.first ?? "");
        widget.imagem = true;
        imagemSelecionada = true;
        imagemRemovida = false;
      });
    }
  }

  _editar(post) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$post");
    debugPrint("$imagemRemovida");
    DataSnapshot dataSnapshot = await ref.get();
    if ((dataSnapshot.value as Map)["img"] != null && imagemRemovida) {
      Reference refI = FirebaseStorage.instance.ref("posts/$post.png");
      await refI.delete();
    } else if (imagemSelecionada) {
      Reference refI = FirebaseStorage.instance.ref("posts/$post.png");
      await refI.putFile(imagemFile ?? File(""));
    }
    ref.update(
      {
        "content": txtEdit.text,
        "img": widget.imagem ? (imagemRemovida ? null : true) : null,
      },
    );
  }

  @override
  void initState() {
    txtEdit.text = (snapshot?.value as List)[widget.post]["content"];
    imagemRemovida = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              false,
            );
          },
          child: const Text(
            "CANCELAR",
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if ((snapshot?.value as List)[widget.post]["content"] !=
                    txtEdit.text ||
                imagemRemovida ||
                imagemSelecionada) {
              _editar(widget.post);
              Navigator.pop(
                context,
                true,
              );
            }
          },
          child: const Text(
            "OK",
          ),
        ),
      ],
      title: const Text(
        "Editar post...",
        textAlign: TextAlign.center,
      ),
      icon: const Icon(Icons.edit_rounded),
      content: SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              maxLength: 400,
              controller: txtEdit,
              decoration: InputDecoration(
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
            widget.imagem
                ? badges.Badge(
                    badgeContent: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Material(
                        child: InkWell(
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.close_rounded,
                            ),
                          ),
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (timeStamp) {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    icon: const Icon(Icons.delete_rounded),
                                    title: const Text(
                                      "Tem certeza que deseja remover a imagem do post?",
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
                                ).then((value) {
                                  debugPrint("$value");
                                  if (value) {
                                    setState(() {
                                      widget.imagem = false;
                                      imagemRemovida = true;
                                    });
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    /* IconButton(
                      onPressed: () {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (timeStamp) {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) => AlertDialog(
                                icon: const Icon(Icons.delete_rounded),
                                title: const Text(
                                  "Tem certeza que deseja remover a imagem do post?",
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
                            ).then((value) {
                              debugPrint("$value");
                              if (value) {
                                setState(() {
                                  widget.imagem = false;
                                  imagemRemovida = true;
                                });
                              }
                            });
                          },
                        );
                      },
                      icon: const Icon(Icons.close_rounded),
                    ), */
                    badgeStyle: badges.BadgeStyle(
                      padding: const EdgeInsets.all(1),
                      badgeColor: dark ? Colors.grey[800]! : Colors.grey[400]!,
                    ),
                    child: imagemSelecionada
                        ? Image(
                            width: 200,
                            fit: BoxFit.cover,
                            image: FileImage(
                              imagemFile ?? File(""),
                            ),
                          )
                        : FadeInImage(
                            fit: BoxFit.cover,
                            width: 200,
                            fadeInDuration: const Duration(milliseconds: 300),
                            fadeOutDuration: const Duration(milliseconds: 300),
                            placeholder:
                                const AssetImage('lib/assets/loading.gif'),
                            image: NetworkImage(
                              "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${widget.post}.png?alt=media",
                            ),
                          ),
                  )
                : TextButton.icon(
                    icon: const Icon(Icons.add_photo_alternate_rounded),
                    onPressed: () async {
                      _pegarImagem();
                    },
                    label: const Text("Adicionar imagem"),
                  ),
          ],
        ),
      ),
    );
  }
}
