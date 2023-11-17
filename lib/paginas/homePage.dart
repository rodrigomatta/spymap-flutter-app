import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spymap/paginas/configPage.dart';
import 'package:spymap/paginas/localizPage.dart';
import 'package:spymap/paginas/mapPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Classe da HomePage
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int indiceSelecionado = 0;
  String? userId;
  Color appBarColor = Colors.green;
  Color? bottomNavBarColor = Colors.green[800];
  late List<Widget> telas;
  late StreamSubscription<QuerySnapshot> _subscription;
  ValueNotifier<String> iconPathNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    telas = [
      LocalizPage(),
      Container(), // Placeholder for MapPage
      ConfigPage(changeColor: changeColor),
    ];
    _subscription = FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).snapshots().listen(_updateState);

    // Load the selected theme from Firestore
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('temas').doc(uid).get().then((doc) {
      if (doc.exists && doc.data()!['tema'] != null) {
        changeColor(doc.data()!['tema']);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void _updateState(QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
      String? newUserId = snapshot.docs.first.id;

      // Check if the added document is the 'temas' document
      if (newUserId == 'temas') {
        return;
      }

      // Check if the userId has changed before creating a new MapPage
      if (newUserId != userId) {
        setState(() {
          userId = newUserId;
          telas[1] = MapPage(userId!, iconPathNotifier); // Replace the placeholder with the actual MapPage
        });
      }
    }
  }

  void changeIcon(String path, int width) {
    setState(() {
      iconPathNotifier.value = path;
    });
  }

  void changeColor(String color) {
    setState(() {
      switch (color) {
        case 'Amarelo':
          appBarColor = Colors.yellow;
          bottomNavBarColor = Colors.yellow[500] ?? Colors.yellow;
          break;
        case 'Roxo':
          appBarColor = Colors.purple;
          bottomNavBarColor = Colors.purple[800] ?? Colors.purple;
          break;
        case 'Preto':
          appBarColor = Colors.black;
          bottomNavBarColor = Colors.black;
          break;
        default:
          appBarColor = Colors.green;
          bottomNavBarColor = Colors.green[800] ?? Colors.green;
      }
    });

    // Save the selected theme to Firestore
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('temas').doc(uid).set({
      'tema': color,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SpyMap Tracker'),
        centerTitle: true, // Centraliza o título
        backgroundColor: appBarColor, // Altera a cor de fundo para verde
      ),
      body: telas[indiceSelecionado],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (indice){
          setState(() {
            indiceSelecionado = indice;
          });
        },
        unselectedItemColor: Colors.white70,
        backgroundColor: bottomNavBarColor,
        currentIndex: indiceSelecionado,
        selectedItemColor: Colors.amber[800],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Mapas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}