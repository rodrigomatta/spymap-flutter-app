// Importando os pacotes necessários do Flutter
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spymap/servicos/authService.dart';
import 'package:provider/provider.dart';

// Definindo a classe ConfigPage que é um StatefulWidget
class ConfigPage extends StatefulWidget {
  // Declarando funções de callback como parâmetros opcionais
  final Function(String)? changeColor;
  final Function(String, int)? changeIcon;

  // Construtor da classe
  const ConfigPage({Key? key, this.changeColor, this.changeIcon}) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

// Estado da página de configurações
class _ConfigPageState extends State<ConfigPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = false;

  // Listas de cores e ícones personalizados
  final List<String> listColors = <String>['Verde', 'Amarelo', 'Roxo', 'Preto'];
  String valorCor = 'Verde';
  final List<String> listPoints = <String>[
    'images/spy.png',
    'images/pontoazul.png',
    'images/pontovermelho.jpg',
    'images/nicolascage.png',
  ];
  String valorPoints = 'images/pontoazul.png';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Dropdown para selecionar o tema do aplicativo
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Tema do aplicativo:',
                    style: TextStyle(fontSize: 7, fontFamily: 'MagicalChildhood'),
                  ),
                  SizedBox(width: 49),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: valorCor,
                          onChanged: (String? newValue) {
                            setState(() {
                              valorCor = newValue!;
                              // Chama a função de callback changeColor, se fornecida
                              if (widget.changeColor != null) {
                                widget.changeColor!(newValue);
                              }
                            });
                          },
                          items: listColors.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Dropdown para selecionar o marcador personalizado
              Row(
                children: <Widget>[
                  Text(
                    'Marcador personalizado:',
                    style: TextStyle(fontSize: 7, fontFamily: 'MagicalChildhood'),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: SingleChildScrollView(
                          child: DropdownButton<String>(
                            value: valorPoints,
                            onChanged: (String? newValue) {
                              setState(() {
                                valorPoints = newValue!;
                                // Chama a função de callback changeIcon, se fornecida
                                if (widget.changeIcon != null) {
                                  widget.changeIcon!(newValue, 200);
                                }
                                // Salva o marcador personalizado selecionado no Firestore
                                String uid = FirebaseAuth.instance.currentUser!.uid;
                                FirebaseFirestore.instance.collection('temas').doc(uid).set({
                                  'marcador': newValue,
                                }, SetOptions(merge: true));
                              });
                            },
                            items: listPoints.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Botão para sair da conta
              Padding(
                padding: EdgeInsets.only(top: 50),
                child: SizedBox(
                  width: 220,
                  height: 55,
                  child: OutlinedButton(
                    onPressed: () async {
                      // Chama a função de logout da instância AuthService usando Provider
                      setState(() {
                        loading = true;
                      });
                      await context.read<AuthService>().logout();
                      setState(() {
                        loading = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      primary: Colors.amber[800],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: loading
                          ? [
                              // Exibindo um indicador de carregamento durante o logout
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            ]
                          : [
                              // Exibindo o texto "SAIR DA CONTA"
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'SAIR DA CONTA',
                                  style: TextStyle(fontSize: 8, fontFamily: 'MagicalChildhood'),
                                ),
                              )
                            ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}