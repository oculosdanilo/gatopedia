import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/l10n/app_localizations.dart';
import 'package:gatopedia/main.dart';
import 'package:gatopedia/telas/home/eu/profile.dart';
import 'package:gatopedia/telas/index.dart';

class PublicProfile extends StatefulWidget {
  final String username;

  const PublicProfile(this.username, {super.key});

  @override
  State<PublicProfile> createState() => _PublicProfileState();
}

class _PublicProfileState extends State<PublicProfile> {
  late StreamSubscription<DatabaseEvent> _atualizarListenPublicProfile;

  String bioText = "carregando...";

  Future<void> _pegarUserinfo(String username, BuildContext c) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users/$username");
    ref.get().then(
      (value) {
        if (value.child("bio").exists && value.child("bio").value != "(vazio)") {
          setState(() {
            bioText = value.child("bio").value as String;
          });
        } else {
          if (!c.mounted) return;
          bioText = AppLocalizations.of(c).profile_bio_empty;
        }
      },
    );
  }

  void _atualizar(BuildContext c) {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users");
    _atualizarListenPublicProfile = ref.onValue.listen((event) {
      if (!c.mounted) return;
      _pegarUserinfo(widget.username, c);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bioText = AppLocalizations.of(context).profile_bio_loading;
      _pegarUserinfo(widget.username, context);
      _atualizar(context);
    });
  }

  @override
  void dispose() {
    _atualizarListenPublicProfile.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: username != null
          ? Theme.of(context)
          : ThemeData.from(
              colorScheme: temaBaseBW(App.themeNotifier.value, context).colorScheme,
              textTheme: temaBaseBW(App.themeNotifier.value, context).textTheme.apply(fontFamily: "Jost"),
            ),
      child: Scaffold(
        body: widget.username == username
            ? const Profile(true)
            : CustomScrollView(
                physics: const NeverScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    iconTheme: const IconThemeData(shadows: [Shadow(color: Colors.black, blurRadius: 20)]),
                    leading: IconButton(
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    expandedHeight: 400,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Transform.translate(
                        offset: const Offset(-33, 0),
                        child: Text(
                          "@${widget.username}",
                          style: const TextStyle(color: Colors.white, fontVariations: [FontVariation("wght", 500)]),
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image(
                            image: NetworkImage(
                                "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F${widget.username}.webp?alt=media"),
                            errorBuilder: (c, obj, stacktrace) => Image.asset("assets/user.webp", fit: BoxFit.cover),
                            fit: BoxFit.cover,
                          ),
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
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Bio", style: TextStyle(fontSize: 15, color: Colors.grey[700]!)),
                          SelectableText(bioText, style: const TextStyle(fontSize: 20)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
