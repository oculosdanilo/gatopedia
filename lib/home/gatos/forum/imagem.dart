import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Imagem extends StatefulWidget {
  final String imagemUrl;
  const Imagem(this.imagemUrl, {super.key});

  @override
  State<Imagem> createState() => _ImagemState();
}

class _ImagemState extends State<Imagem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  key: UniqueKey(),
                  imageUrl: widget.imagemUrl,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Material(
                  color: Colors.black,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
