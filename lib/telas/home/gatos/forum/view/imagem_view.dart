import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

class Imagem extends StatefulWidget {
  final String imagemUrl;
  final String hero;

  const Imagem(this.imagemUrl, this.hero, {super.key});

  @override
  State<Imagem> createState() => _ImagemState();
}

class _ImagemState extends State<Imagem> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PhotoView(
            imageProvider: CachedNetworkImageProvider(widget.imagemUrl),
            heroAttributes: PhotoViewHeroAttributes(tag: widget.hero, transitionOnUserGestures: true),
            minScale: PhotoViewComputedScale.contained,
            maxScale: 1.0,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, MediaQuery.paddingOf(context).top + 5, 0, 0),
            child: ClipOval(
              child: Material(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
