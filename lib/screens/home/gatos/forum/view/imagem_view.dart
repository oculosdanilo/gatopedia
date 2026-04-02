import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';

class Imagem extends StatefulWidget {
  final String imagemPath;
  final String hero;

  const Imagem(this.imagemPath, this.hero, {super.key});

  @override
  State<Imagem> createState() => _ImagemState();
}

class _ImagemState extends State<Imagem> {
  late Future<String> _imageUrlGet;

  @override
  void initState() {
    super.initState();
    _imageUrlGet = FirebaseStorage.instance.ref(widget.imagemPath).getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          FutureBuilder(
              future: _imageUrlGet,
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.hasData && asyncSnapshot.connectionState == ConnectionState.done) {
                  return PhotoView(
                    imageProvider: CachedNetworkImageProvider(asyncSnapshot.requireData),
                    heroAttributes: PhotoViewHeroAttributes(tag: widget.hero, transitionOnUserGestures: true),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: 1.0,
                  );
                } else {
                  return const CircularProgressIndicator(value: null);
                }
              }),
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
