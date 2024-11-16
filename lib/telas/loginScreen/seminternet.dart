import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gatopedia/main.dart';

class SemInternet extends StatefulWidget {
  const SemInternet({super.key});

  @override
  SemInternetState createState() {
    return SemInternetState();
  }
}

class SemInternetState extends State {
  late StreamSubscription listener;

  @override
  void initState() {
    super.initState();
    listener = connecteo.connectionStream.listen((internet) {
      if (!mounted) return;
      if (internet) Navigator.pop(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          margin: const EdgeInsets.all(20),
          width: MediaQuery.of(context).size.width,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 170),
              Text(
                "Sem internet",
                style: TextStyle(fontVariations: [FontVariation("wght", 600)], fontSize: 30),
              ),
              Text("Aguardando conexão"),
              SizedBox(height: 30),
              CircularProgressIndicator(value: null)
            ],
          ),
        ),
      ),
    );
  }
}
