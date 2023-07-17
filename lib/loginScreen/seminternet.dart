import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
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
    listener = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.disconnected:
          break;
        case InternetConnectionStatus.connected:
          internet = true;
          Navigator.of(context, rootNavigator: true).pop();
          break;
      }
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
    return WillPopScope(
        child: Scaffold(
          body: Container(
            margin: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 170,
                ),
                Text(
                  "Sem internet",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Jost",
                      fontSize: 30),
                ),
                Text("Aguardando conexão"),
                SizedBox(
                  height: 30,
                ),
                CircularProgressIndicator(
                  value: null,
                )
              ],
            ),
          ),
        ),
        onWillPop: () async {
          if (internet) {
            return true;
          } else {
            return false;
          }
        });
  }
}
