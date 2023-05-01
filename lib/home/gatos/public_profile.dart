import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/home/eu/profile.dart';

import '../../main.dart';

String bioText = "(vazio)";

class PublicProfile extends StatefulWidget {
  final String username;
  const PublicProfile(this.username, {super.key});

  @override
  State<PublicProfile> createState() => _PublicProfileState();
}

class _PublicProfileState extends State<PublicProfile> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  _pegarUserinfo(username) async {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users/");
    ref.get().then(
      (value) {
        if ((value.value as Map)[username] != null) {
          if ((value.value as Map)[username]["bio"] != null) {
            setState(() {
              bioText = (value.value as Map)[username]["bio"];
              temImagem = ((value.value as Map)[username]["img"] ?? false);
            });
          } else {
            bioText = "(vazio)";
          }
        } else {
          bioText = "(vazio)";
        }
      },
    );
  }

  _atualizar() {
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("users");
    ref.onValue.listen((event) {
      _pegarUserinfo(widget.username);
    });
  }

  @override
  void initState() {
    bioText = "(vazio)";
    _pegarUserinfo(widget.username);
    _atualizar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.username == username
          ? const Profile(true)
          : CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: true,
                  expandedHeight: 400,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Text("@${widget.username}"),
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image(
                          image: listaTemImagem.contains(widget.username)
                              ? NetworkImage(
                                  "https://firebasestorage.googleapis.com/v0/b/fluttergatopedia.appspot.com/o/users%2F${widget.username}.png?alt=media")
                              : const AssetImage("lib/assets/user.webp")
                                  as ImageProvider,
                          width: 50,
                          fit: BoxFit.cover,
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.0, 0.5),
                              end: Alignment.center,
                              colors: <Color>[
                                Color(0x60000000),
                                Color(0x00000000),
                              ],
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
                        Text(
                          "Bio",
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Jost",
                              color: Colors.grey[700]!),
                        ),
                        SelectableText(
                          bioText,
                          style: const TextStyle(
                            fontFamily: "Jost",
                            fontSize: 20,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
