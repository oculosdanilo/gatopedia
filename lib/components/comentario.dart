import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/animations/routes.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/screens/home/public_profile.dart';

class Comentario extends StatefulWidget {
  final String usernamePost;
  final String contentPost;
  final void Function() deletarC;

  const Comentario(this.usernamePost, this.contentPost, this.deletarC, {super.key});

  @override
  State<Comentario> createState() => _ComentarioState();
}

class _ComentarioState extends State<Comentario> {
  late Future<String> _imageUrlGet;
  bool _pegouImageUrl = false;

  @override
  void initState() {
    super.initState();

    if (!_pegouImageUrl) {
      try {
        _imageUrlGet = FirebaseStorage.instance.ref("users/${widget.usernamePost}.webp").getDownloadURL();
      } on FirebaseException catch (e) {
        "$e";
        debugPrint("ops");
        _imageUrlGet = Future<String>.delayed(Duration.zero, () => "");
      }
      _pegouImageUrl = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: username == null && _isDark(context)
          ? Theme.of(context).colorScheme.surfaceTint.withValues(alpha: 0.25)
          : Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipOval(
              child: GestureDetector(
                onTap: () => Navigator.push(context, SlideRightAgainRoute(PublicProfile(widget.usernamePost))),
                child: FutureBuilder(
                  future: _imageUrlGet,
                  builder: (context, snapshotFoto) {
                    if (snapshotFoto.connectionState == ConnectionState.done) {
                      if (snapshotFoto.hasData) {
                        return CachedNetworkImage(
                          imageUrl: snapshotFoto.data!,
                          width: 40,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Image.asset("assets/animations/loading.gif", width: 40, fit: BoxFit.cover),
                          errorListener: (_) {},
                        );
                      } else {
                        return Image.asset(
                          "assets/user.webp",
                          width: 40,
                          fit: BoxFit.cover,
                        );
                      }
                    } else {
                      return Image.asset(
                        "assets/animations/loading.gif",
                        width: 40,
                        fit: BoxFit.cover,
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      SlideRightAgainRoute(PublicProfile(widget.usernamePost)),
                    ),
                    child: Text(
                      "@${widget.usernamePost}",
                      style: const TextStyle(fontVariations: [FontVariation("wght", 500)], fontSize: 20),
                      softWrap: true,
                    ),
                  ),
                  Text(
                    widget.contentPost,
                    style: TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    softWrap: true,
                    maxLines: 50,
                  )
                ],
              ),
            ),
            widget.usernamePost == username
                ? Ink(
                    width: 40,
                    height: 40,
                    decoration: ShapeDecoration(color: blueScheme.errorContainer, shape: const CircleBorder()),
                    child: IconButton(
                      icon: const Icon(Icons.delete_rounded),
                      color: blueScheme.onErrorContainer,
                      onPressed: () {
                        showCupertinoDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AlertDialog(
                            icon: Icon(Icons.delete_rounded, color: Theme.of(context).colorScheme.error),
                            title: const Text(
                              "Tem certeza que deseja deletar esse comentário?",
                              textAlign: TextAlign.center,
                            ),
                            content: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text("Ele sumirá para sempre! (muito tempo)")],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("CANCELAR"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  widget.deletarC();
                                  Navigator.pop(context);
                                  Flushbar(
                                    message: "Excluído com sucesso!",
                                    duration: const Duration(seconds: 3),
                                    margin: const EdgeInsets.all(20),
                                    borderRadius: BorderRadius.circular(50),
                                  ).show(context);
                                },
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }

  bool _isDark(BuildContext context) {
    if (App.themeNotifier.value == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    } else {
      return App.themeNotifier.value == ThemeMode.dark;
    }
  }
}

class ComentarioData {
  final String id;
  final String user;
  final String content;
  final int timestamp;

  ComentarioData({required this.id, required this.user, required this.content, required this.timestamp});

  @override
  String toString() {
    return "\nUsuário: @$user\nComentário: $content\nData: ${DateTime.fromMillisecondsSinceEpoch(timestamp).toString()}";
  }
}
