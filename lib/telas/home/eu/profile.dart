import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/anim/routes.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/eu/pp_edit.dart';
import 'package:gatopedia/telas/home/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MenuItensImg { editar, remover }

enum MenuItensSemImg { adicionar }

bool? temImagem;
String? imagemGoogle;

class Profile extends StatefulWidget {
  final bool botaoVoltar;

  const Profile(this.botaoVoltar, {super.key});

  @override
  State<Profile> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  late StreamSubscription<DatabaseEvent> _atualizarListenProfile;

  bool _editMode = false;
  final _txtBio = TextEditingController();
  late String _bioText = AppLocalizations.of(context).profile_bio_loading;

  late Future<String?> _pegarImgGoogleVar;

  Future<void> _apagarImagem(String username) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    final ref = database.ref("users/$username/img");
    FirebaseStorage storage = FirebaseStorage.instance;
    final refS = storage.ref("users/$username.webp");
    await ref.remove();
    await refS.delete();
  }

  Future<void> _atualizar() async {
    final sp = await SharedPreferences.getInstance();
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users/$username");
    _atualizarListenProfile = ref.onValue.listen((event) {
      final data = event.snapshot;
      if (data.child("bio").value != null && data.child("bio").value.toString() != "(vazio)") {
        setState(() => _bioText = "${data.child("bio").value}");
        sp.setString("bio", "${data.child("bio").value}");
      } else {
        setState(() => _bioText = AppLocalizations.of(context).profile_bio_empty);
        if (!mounted) return;
        sp.setString("bio", AppLocalizations.of(context).profile_bio_empty);
      }
      if (data.child("img").value != null) {
        setState(() => temImagem = true);
      } else {
        setState(() => temImagem = false);
      }
      sp.setBool("img", (data.child("img").value != null));
    });
  }

  Future<void> _salvarBio(String bio) async {
    final ref = FirebaseDatabase.instance.ref("users/$username");
    await ref.update({"bio": bio});
  }

  Future<void> _init() async {
    final sp = await SharedPreferences.getInstance();
    if (sp.containsKey("bio") && sp.containsKey("img")) {
      setState(() {
        _bioText = sp.getString("bio")!;
        temImagem = sp.getBool("img")!;
      });
    }
    _atualizar();
  }

  Future<String?> _pegarImgGoogle() async {
    final refUser = FirebaseDatabase.instance.ref("users/$username/img");
    final imgInfo = await refUser.get();
    if (imgInfo.exists) {
      return "${imgInfo.value}";
    } else {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    indexAntigo = 1;
    temImagem = false;
    _pegarImgGoogleVar = _pegarImgGoogle();
    _init();
  }

  @override
  void dispose() {
    _atualizarListenProfile.cancel();
    super.dispose();
  }

  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const PageScrollPhysics(),
      slivers: [
        appbar(context),
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    fontVariations: const [FontVariation.weight(600)],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: _editMode
                      ? Editando(
                          focusNode: _focusNode,
                          cancelClick: () {
                            setState(() {
                              _editMode = false;
                            });
                          },
                          saveClick: () async {
                            if (_txtBio.text != "" && _txtBio.text != _bioText) {
                              _salvarBio(_txtBio.text);
                              if (mounted) {
                                setState(() {
                                  _editMode = false;
                                });
                              }
                              Flushbar(
                                message: AppLocalizations.of(context).profile_pfp_changeSuccess,
                                duration: const Duration(seconds: 2),
                                margin: const EdgeInsets.all(20),
                                borderRadius: BorderRadius.circular(50),
                              ).show(context);
                            }
                          },
                          bioText: _bioText,
                          txtBio: _txtBio,
                        )
                      : Estatico(
                          editClick: () {
                            setState(() {
                              _editMode = true;
                              _txtBio.text = _bioText;
                              _focusNode.requestFocus();
                            });
                          },
                          bioText: _bioText,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar appbar(BuildContext context) {
    return SliverAppBar(
      actions: temImagem ?? false
          ? [
              PopupMenuButton<MenuItensImg>(
                icon: Icon(
                  Platform.isIOS ? Icons.more_horiz_rounded : Icons.more_vert_rounded,
                  shadows: const [Shadow(blurRadius: 10)],
                  color: Colors.white,
                ),
                onSelected: (value) async {
                  if (value == MenuItensImg.editar) {
                    var resposta = await Navigator.push(context, SlideRightAgainRoute(const PPEdit(true)));
                    if (resposta != null && resposta) {
                      setState(() {
                        CachedNetworkImage.evictFromCache(
                            "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media");
                        temImagem = true;
                      });
                      if (!context.mounted) return;
                      Flushbar(
                        message: AppLocalizations.of(context).profile_pfp_flushbarAdd,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(50),
                      ).show(context);
                    }
                  } else {
                    showCupertinoDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        icon: Icon(Icons.delete_rounded, color: Theme.of(context).colorScheme.error),
                        title: Text(
                          AppLocalizations.of(context).profile_pfp_removeAlert_title,
                          textAlign: TextAlign.center,
                        ),
                        content: Text(AppLocalizations.of(context).profile_pfp_removeAlert_subtitle,
                            textAlign: TextAlign.center),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalizations.of(context).cancel),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("OK"),
                          )
                        ],
                      ),
                    ).then(
                      (value) async {
                        if (value ?? false) {
                          await _apagarImagem(username!);
                          setState(() => CachedNetworkImage.evictFromCache(
                              "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media"));
                          if (!context.mounted) return;
                          Flushbar(
                            message: AppLocalizations.of(context).forum_delete_flush,
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(20),
                            borderRadius: BorderRadius.circular(50),
                          ).show(context);
                        }
                      },
                    );
                  }
                },
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: MenuItensImg.editar,
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          shadows: const [],
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        Text(AppLocalizations.of(context).profile_pfp_change),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: MenuItensImg.remover,
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_forever_rounded,
                          shadows: const [],
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        Text(AppLocalizations.of(context).profile_pfp_remove),
                      ],
                    ),
                  ),
                ],
              ),
            ]
          : [
              PopupMenuButton<MenuItensSemImg>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  shadows: [Shadow(blurRadius: 10)],
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onSelected: (value) async {
                  if (value == MenuItensSemImg.adicionar) {
                    var resposta = await Navigator.push(context, SlideRightAgainRoute(const PPEdit(false)));
                    if (!context.mounted) return;
                    if (resposta != null) {
                      if (resposta) {
                        Flushbar(
                          message: AppLocalizations.of(context).profile_pfp_flushbarAdd,
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(50),
                        ).show(context);
                      }
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuItensSemImg>>[
                  PopupMenuItem(
                    value: MenuItensSemImg.adicionar,
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          shadows: const [],
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        Text(AppLocalizations.of(context).profile_pfp_addPFP),
                      ],
                    ),
                  ),
                ],
              ),
            ],
      leading: widget.botaoVoltar
          ? IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              color: Colors.white,
            )
          : null,
      automaticallyImplyLeading: widget.botaoVoltar,
      iconTheme: const IconThemeData(color: Colors.white, shadows: [Shadow(color: Colors.black, blurRadius: 20)]),
      expandedHeight: 400,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      flexibleSpace: FlexibleSpaceBar(
        title: Transform.translate(
          offset: Offset(widget.botaoVoltar ? -48 : 0, 0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "@$username",
              style: const TextStyle(color: Colors.white, fontVariations: [FontVariation("wght", 500)]),
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            temImagem ?? false
                ? imagemGoogle != null
                    ? Image.network(imagemGoogle!, fit: BoxFit.cover)
                    : FadeInImage(
                        fadeInDuration: const Duration(milliseconds: 100),
                        placeholder: const AssetImage("assets/anim/loading.gif"),
                        image: CachedNetworkImageProvider(
                            "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F$username.webp?alt=media"),
                        imageErrorBuilder: (context, obj, stck) {
                          return FutureBuilder<String?>(
                            future: _pegarImgGoogleVar,
                            builder: (context, snapshot) {
                              if (snapshot.hasData || snapshot.connectionState == ConnectionState.done) {
                                if (snapshot.data != null) {
                                  imagemGoogle = snapshot.data!;
                                  return FadeInImage(
                                    fadeInDuration: const Duration(milliseconds: 100),
                                    placeholder: const AssetImage("assets/anim/loading.gif"),
                                    image: NetworkImage(snapshot.data!),
                                    imageErrorBuilder: (context, obj, stck) =>
                                        Image.asset("assets/user.webp", fit: BoxFit.cover),
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Image.asset("assets/user.webp", fit: BoxFit.cover);
                                }
                              } else {
                                return Image.asset("assets/anim/loading.gif", fit: BoxFit.cover);
                              }
                            },
                          );
                        },
                        fit: BoxFit.cover,
                      )
                : Image.asset("assets/user.webp", fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.0, 0.5),
                  end: Alignment.center,
                  colors: [Color(0x60000000), Color(0x00000000)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Estatico extends StatefulWidget {
  final void Function() editClick;
  final String bioText;

  const Estatico({super.key, required this.editClick, required this.bioText});

  @override
  State<Estatico> createState() => _EstaticoState();
}

class _EstaticoState extends State<Estatico> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(widget.bioText, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed: widget.bioText != AppLocalizations.of(context).profile_bio_loading ? widget.editClick : null,
              icon: const Icon(Icons.edit_rounded),
              label: Text(AppLocalizations.of(context).profile_bio_edit),
            ),
          ],
        ),
      ],
    );
  }
}

class Editando extends StatefulWidget {
  final void Function() cancelClick;
  final void Function() saveClick;
  final String bioText;
  final TextEditingController txtBio;
  final FocusNode focusNode;

  const Editando({
    super.key,
    required this.cancelClick,
    required this.saveClick,
    required this.bioText,
    required this.txtBio,
    required this.focusNode,
  });

  @override
  State<Editando> createState() => _EditandoState();
}

class _EditandoState extends State<Editando> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        TextField(
          maxLength: 255,
          controller: widget.txtBio,
          maxLines: 2,
          focusNode: widget.focusNode,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).profile_bio_empty,
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
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: widget.cancelClick,
              child: Text(AppLocalizations.of(context).cancel),
            ),
            FilledButton(
              onPressed: widget.saveClick,
              child: Text(AppLocalizations.of(context).save),
            ),
          ],
        ),
      ],
    );
  }
}
