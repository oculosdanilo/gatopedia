import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/telas/home/config/config.dart';
import 'package:gatopedia/telas/home/public_profile.dart';
import 'package:gatopedia/main.dart';

Card comentario(
    BuildContext context, int index, String usernamePost, String contentPost, Function(int index) deletarC) {
  return Card(
    margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    color: username == null && dark
        ? Theme.of(context).colorScheme.surfaceTint.withOpacity(0.25)
        : Theme.of(context).colorScheme.surfaceContainerLow,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: GestureDetector(
              onTap: () => Navigator.push(context, SlideRightAgainRoute(PublicProfile(usernamePost))),
              child: Image(
                image: NetworkImage(
                    "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$usernamePost.webp?alt=media"),
                width: 40,
                fit: BoxFit.cover,
                errorBuilder: (c, obj, stacktrace) => Image.asset("assets/user.webp", width: 40),
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
                    SlideRightAgainRoute(PublicProfile(usernamePost)),
                  ),
                  child: Text(
                    usernamePost,
                    style: TextStyle(fontVariations: [FontVariation("wght", 500)], fontSize: 20),
                    softWrap: true,
                  ),
                ),
                Text(
                  contentPost,
                  style: TextStyle(fontSize: 17, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  softWrap: true,
                  maxLines: 50,
                )
              ],
            ),
          ),
          usernamePost == username
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
                                deletarC(index);
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
