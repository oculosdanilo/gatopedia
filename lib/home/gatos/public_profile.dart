import 'package:flutter/material.dart';
import 'package:gatopedia/home/eu/profile.dart';

import '../../main.dart';

class PublicProfile extends StatefulWidget {
  final String username;
  const PublicProfile(this.username, {super.key});

  @override
  State<PublicProfile> createState() => _PublicProfileState();
}

class _PublicProfileState extends State<PublicProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          widget.username == username ? const Profile() : Text(widget.username),
    );
  }
}
