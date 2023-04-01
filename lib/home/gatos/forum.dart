
import 'package:flutter/material.dart';
import 'package:gatopedia/main.dart';

class Forum extends StatefulWidget {
  const Forum({super.key});

  @override
  State<Forum> createState() => _ForumState();
}

class _ForumState extends State<Forum> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                  decoration: InputDecoration(
                    hintText: "No que está pensando, $username?",
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
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
                  foregroundColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  disabledBackgroundColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                  hoverColor: Theme.of(context)
                      .colorScheme
                      .onSecondaryContainer
                      .withOpacity(0.08),
                  focusColor: Theme.of(context)
                      .colorScheme
                      .onSecondaryContainer
                      .withOpacity(0.12),
                  highlightColor: Theme.of(context)
                      .colorScheme
                      .onSecondaryContainer
                      .withOpacity(0.12),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.gif),
                style: IconButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  disabledBackgroundColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
                  hoverColor: Theme.of(context)
                      .colorScheme
                      .onSecondaryContainer
                      .withOpacity(0.08),
                  focusColor: Theme.of(context)
                      .colorScheme
                      .onSecondaryContainer
                      .withOpacity(0.12),
                  highlightColor: Theme.of(context)
                      .colorScheme
                      .onSecondaryContainer
                      .withOpacity(0.12),
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
    );
  }
}
