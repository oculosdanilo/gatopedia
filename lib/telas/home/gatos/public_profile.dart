import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gatopedia/telas/home/config/config.dart';
import 'package:gatopedia/telas/home/eu/profile.dart';
import 'package:gatopedia/main.dart';
import 'package:grayscale/grayscale.dart';

String bioText = "carregando...";

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
    DatabaseReference ref = database.ref("users/$username");
    ref.get().then(
      (value) {
        if (value.child("bio").exists) {
          setState(() {
            bioText = value.child("bio").value as String;
          });
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
          : Theme(
              data: username != null
                  ? Theme.of(context)
                  : ThemeData.from(
                      colorScheme: GrayColorScheme.highContrastGray(dark ? Brightness.dark : Brightness.light),
                    ),
              child: CustomScrollView(
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
                      title: Text("@${widget.username}", style: TextStyle(color: Colors.white)),
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
                          Text("Bio", style: TextStyle(fontSize: 15, fontFamily: "Jost", color: Colors.grey[700]!)),
                          SelectableText(bioText, style: TextStyle(fontSize: 20))
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
