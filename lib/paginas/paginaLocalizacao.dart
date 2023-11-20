import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginaLocalizacao extends StatefulWidget {
  const PaginaLocalizacao({super.key});

  @override
  State<PaginaLocalizacao> createState() => _PaginaLocalizacaoState();
}

class _PaginaLocalizacaoState extends State<PaginaLocalizacao>
    with SingleTickerProviderStateMixin {
  // Campo para armazenar as assinaturas
  Map<String, StreamSubscription<loc.LocationData>> _assinaturasLocalizacao = {};

  // Instância da classe de localização
  final loc.Location localizacao = loc.Location();

  // Flag de carregamento
  bool carregando = false;
  String idDispositivo = '';

  @override
  void initState() {
    super.initState();

    // Solicitar permissão de localização ao iniciar a tela
    _solicitarPermissao();

    // Configurar as configurações de localização
    localizacao.changeSettings(interval: 1000, accuracy: loc.LocationAccuracy.balanced);

    // Habilitar o modo de segundo plano para a localização
    localizacao.enableBackgroundMode(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // Campo de texto para o usuário inserir o ID do dispositivo
            Padding(
              padding: EdgeInsets.only(top: 30, left: 20, right: 20),
              child: TextField(
                onChanged: (valor) {
                  setState(() {
                    idDispositivo = valor;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Informe o nome do dispositivo',
                ),
              ),
            ),

            // Botão para obter a localização atual
            TextButton(
              onPressed: () {
                _obterLocalizacaoAtual(idDispositivo);
              },
              child: Text("Adicionar localização atual"),
            ),

            // Botão para habilitar a localização em tempo real
            TextButton(
              onPressed: () {
                _escutarLocalizacao(idDispositivo);
              },
              child: Text("Habilitar localização em tempo real"),
            ),

            // Botão para desabilitar a localização em tempo real
            TextButton(
              onPressed: () {
                _pararEscuta(idDispositivo);
              },
              child: Text("Desabilitar localização em tempo real"),
            ),

            // Lista de locais com base nos dados do Firestore
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        // Cada Dismissible deve conter uma chave única. Neste caso, usamos o ID do documento.
                        key: Key(snapshot.data!.docs[index].id),

                        // Fornecemos uma função que diz ao Flutter o que fazer depois que um item foi descartado
                        onDismissed: (direcao) {
                          // Remover o item do nosso banco de dados
                          String uid = FirebaseAuth.instance.currentUser?.uid ?? 'default';
                          FirebaseFirestore.instance.collection(uid).doc(snapshot.data!.docs[index].id).delete();
                        },

                        // Mostrar um ícone de exclusão vermelho e texto atrás do item deslizante
                        background: Container(
                          color: Colors.red,
                          child: Icon(Icons.delete),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                        ),

                        child: ListTile(
                          title: Center(child: Text("Rastreando dispositivo: ${snapshot.data!.docs[index]['name'].toString()}")),
                          // Adicionado o widget Center para centralizar o texto
                          subtitle: Center(
                            // Adicionado o widget Center para centralizar a Row
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Lat: ${snapshot.data!.docs[index]['latitude'].toString()}"),
                                SizedBox(width: 20),
                                Text("Long: ${snapshot.data!.docs[index]['longitude'].toString()}"),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para obter a localização e salvar no Firestore
  _obterLocalizacaoAtual(String idDispositivo) async {
    try {
      // Verificar a permissão de localização
      loc.PermissionStatus permissao = await localizacao.hasPermission();
      if (permissao == loc.PermissionStatus.granted) {
        final loc.LocationData _resultadoLocalizacao = await localizacao.getLocation();
        await FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).doc(idDispositivo).set({
          'latitude': _resultadoLocalizacao.latitude,
          'longitude': _resultadoLocalizacao.longitude,
          'name': idDispositivo
        }, SetOptions(merge: true));
      } else {
        // Tratar caso a permissão não esteja concedida
        print("Permissão de localização não concedida");
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  // Método para iniciar a escuta da localização em tempo real
  Future<void> _escutarLocalizacao(String idDispositivo) async {
    _assinaturasLocalizacao[idDispositivo] = localizacao.onLocationChanged.handleError((erro) {
      print("Erro: $erro");
      _assinaturasLocalizacao[idDispositivo]?.cancel();
      setState(() {
        _assinaturasLocalizacao.remove(idDispositivo);
      });
    }).listen((loc.LocationData localizacaoAtual) async {
      // Atualizar a localização no Firestore durante a escuta
      String uid = FirebaseAuth.instance.currentUser?.uid ?? 'default';
      await FirebaseFirestore.instance.collection(uid).doc(idDispositivo).set({
        'latitude': localizacaoAtual.latitude,
        'longitude': localizacaoAtual.longitude,
        'name': idDispositivo
      }, SetOptions(merge: true));
    });
  }

  // Método para parar a escuta da localização em tempo real
  _pararEscuta(String idDispositivo) {
    _assinaturasLocalizacao[idDispositivo]?.cancel();
    setState(() {
      _assinaturasLocalizacao.remove(idDispositivo);
    });
  }

  // Método para solicitar permissão de localização
  _solicitarPermissao() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print("Concluído");
    } else if (status.isPermanentlyDenied) {
      // Abrir configurações do aplicativo se a permissão for negada permanentemente
      openAppSettings();
    }
  }
}