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

// Estado da HomePage
class _HomePageState extends State<HomePage> {
  int indiceSelecionado = 0;
  String? userId;
  Color appBarColor = Colors.green;
  Color? bottomNavBarColor = Colors.green[800];
  late List<Widget> telas;

  @override
  void initState() {
    super.initState();
    telas = [
      LocalizPage(),
      Container(), // Placeholder for MapPage
      ConfigPage(changeColor: changeColor),
    ];
  }

  void changeColor(String color) {
    setState(() {
      switch (color) {
        case 'Amarelo':
          appBarColor = Colors.amber;
          bottomNavBarColor = Colors.amber[800] ?? Colors.amber;
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
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('location').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          userId = snapshot.data!.docs.first.id;
          telas[1] = MapPage(userId!); // Substitui o placeholder pela MapPage real
        }

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
      },
    );
  }
}