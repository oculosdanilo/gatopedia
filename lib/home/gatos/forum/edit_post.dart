import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:gatopedia/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gatopedia/home/config/config.dart';

bool imagemRemovida = false;
File? imagemFile;
bool imagemSelecionada = false;
bool imagem = false;

class EditPost extends StatefulWidget {
  final String post;

  const EditPost(this.post, {super.key});

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
      XFile? resultWebp = await FlutterImageCompress.compressAndGetFile(
        result.paths.first!,
        "${(await getApplicationDocumentsDirectory()).path}aa.webp",
        quality: 80,
        format: CompressFormat.webp,
      );
      setState(() {
        imagemFile = File(resultWebp?.path ?? "");
        imagem = true;
        imagemSelecionada = true;
        imagemRemovida = false;
      });
    }
  }

  _editar(String post) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("posts/$post");
    debugPrint("$imagemRemovida");
    DataSnapshot dataSnapshot = await ref.get();
    if ((dataSnapshot.value as Map)["img"] != null && imagemRemovida) {
      Reference refI = FirebaseStorage.instance.ref("posts/$post.webp");
      await refI.delete();
    } else if (imagemSelecionada) {
      Reference refI = FirebaseStorage.instance.ref("posts/$post.webp");
      await refI.putFile(imagemFile ?? File(""));
    }
    CachedNetworkImage.evictFromCache(
      "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F$post.webp?alt=media",
    );
    ref.update(
      {
        "content": txtEdit.text,
        "img": imagem ? (imagemRemovida ? null : true) : null,
      },
    );
  }

  @override
  void initState() {
    CachedNetworkImage.evictFromCache(
      "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${widget.post}.webp?alt=media",
    );
    txtEdit.text = snapshot?.child("${widget.post}/content").value as String;
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
            if (snapshot?.child("${widget.post}/content").value !=
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
      content: SingleChildScrollView(
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
            imagem
                ? badges.Badge(
                    badgeContent: ClipOval(
                      child: Material(
                        child: InkWell(
                          child: const Padding(
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.close_rounded,
                            ),
                          ),
                          onTap: () {
                            showCupertinoDialog(
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
                            ).then(
                              (value) {
                                debugPrint("$value");
                                if (value) {
                                  setState(() {
                                    imagem = false;
                                    imagemRemovida = true;
                                  });
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    badgeStyle: badges.BadgeStyle(
                      padding: const EdgeInsets.all(1),
                      badgeColor: dark ? Colors.grey[800]! : Colors.grey[400]!,
                    ),
                    child: imagemSelecionada
                        ? Image(
                            width: 200,
                            fit: BoxFit.cover,
                            image: FileImage(
                              imagemFile!,
                            ),
                          )
                        : FadeInImage(
                            fit: BoxFit.cover,
                            width: 200,
                            fadeInDuration: const Duration(milliseconds: 300),
                            fadeOutDuration: const Duration(milliseconds: 300),
                            placeholder: const AssetImage('assets/loading.gif'),
                            image: CachedNetworkImageProvider(
                              "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/posts%2F${widget.post}.webp?alt=media",
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
