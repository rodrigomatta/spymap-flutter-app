import 'package:flutter/material.dart';
import 'package:spymap/servicos/authService.dart';
import 'package:provider/provider.dart';

class ConfigPage extends StatefulWidget {
  final Function(String) changeColor;
  const ConfigPage({Key? key, required this.changeColor}) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool loading = false;

  // Lista de opções para o seu DropdownButton
  final List<String> list = <String>['Verde', 'Amarelo', 'Roxo', 'Preto'];
  // Variável para armazenar o valor selecionado
  String dropdownValue = 'Verde';

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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Mudar tema do aplicativo:',
                  style: TextStyle(fontSize: 8, fontFamily: 'MagicalChildhood'),
                ),
                SizedBox(width: 15),
                Expanded( // Wrap the InputDecorator with Expanded
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: dropdownValue,
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              dropdownValue = newValue;
                            });
                            widget.changeColor(newValue);
                          }
                        },
                        items: list.map<DropdownMenuItem<String>>((String value) {
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
            Padding(
              padding: EdgeInsets.only(top: 50),
              child: SizedBox(
                width: 220,
                height: 55,
                child: OutlinedButton(
                  onPressed: () => context.read<AuthService>().logout(),
                  style: OutlinedButton.styleFrom(
                    primary: Colors.amber[800],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: loading
                        ? [
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
                          ]:[
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