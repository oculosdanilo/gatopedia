import 'package:flutter/material.dart';
import 'package:gatopedia/main.dart';

class Forum extends StatefulWidget {
  const Forum({super.key});

  @override
  State<Forum> createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  bool enabled = true;
  final txtPost = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return StretchingOverscrollIndicator(
      axisDirection: AxisDirection.down,
      child: Container(
        margin: const EdgeInsets.all(30),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Image(
                  image: AssetImage("lib/assets/user.webp"),
                  width: 50,
                ),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                  child: TextField(
                    controller: txtPost,
                    decoration: InputDecoration(
                      hintText: "No que está pensando, $username?",
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
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.image),
                  style: IconButton.styleFrom(
                    focusColor: colors.onSurfaceVariant.withOpacity(0.12),
                    highlightColor: colors.onSurface.withOpacity(0.12),
                    side: BorderSide(color: colors.primary),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.gif),
                  style: IconButton.styleFrom(
                    focusColor: colors.onSurfaceVariant.withOpacity(0.12),
                    highlightColor: colors.onSurface.withOpacity(0.12),
                    side: BorderSide(color: colors.primary),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.send),
                      label: const Text("ENVIAR"),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
