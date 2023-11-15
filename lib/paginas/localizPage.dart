import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:cloud_firestore/cloud_firestore.dart';

class LocalizPage extends StatefulWidget {
  const LocalizPage({super.key});

  @override
  State<LocalizPage> createState() => _LocalizPageState();
}

class _LocalizPageState extends State<LocalizPage>
    with SingleTickerProviderStateMixin {
  // Campo para armazenar as assinaturas
  Map<String, StreamSubscription<loc.LocationData>> _locationSubscriptions = {};
  // Instância da classe de localização
  final loc.Location location = loc.Location();
  // Flag de carregamento
  bool loading = false;
  String deviceId = '';

  @override
  void initState() {
    super.initState();
    // Solicitar permissão de localização ao iniciar a tela
    _requestPermission();
    // Configurar as configurações de localização
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    // Habilitar o modo de segundo plano para a localização
    location.enableBackgroundMode(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // Campo de texto para o usuário inserir o ID do dispositivo
            Padding(
              padding: 
                EdgeInsets.only(
                  top: 30, 
                  left: 20, 
                  right: 20
                ),
                child: TextField(
                onChanged: (value) {
                  setState(() {
                    deviceId = value;
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
                _getLocation(deviceId);
              },
              child: Text("Adiconar localização atual"),
            ),
            // Botão para habilitar a localização em tempo real
            TextButton(
              onPressed: () {
                _listenLocastion(deviceId);
              },
              child: Text("Habilitar localização em tempo real"),
            ),
            // Botão para desabilitar a localização em tempo real
           TextButton(
              onPressed: () {
                _stopListening(deviceId);
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
                        onDismissed: (direction) {
                          // Remover o item do nosso banco de dados
                          String uid = FirebaseAuth.instance.currentUser?.uid ?? 'default';
                          FirebaseFirestore.instance.collection(uid).doc(snapshot.data!.docs[index].id).delete();
                        },
                        // Mostrar um ícone de exclusão vermelho e texto atrás do item deslizantez
                        background: Container(color: Colors.red, child: Icon(Icons.delete), alignment: Alignment.centerRight, padding: EdgeInsets.only(right: 20),),
                        child: ListTile(
                          title: Center(child: Text("Rastreando dispositivo: ${snapshot.data!.docs[index]['name'].toString()}")), // Adicionado o widget Center aqui
                          subtitle: Center( // Adicionado o widget Center aqui
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center, // Centraliza os elementos na Row
                              children: [
                                Text("Lat: ${snapshot.data!.docs[index]['latitude'].toString()}"),
                                SizedBox(
                                  width: 20,
                                ),
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
  _getLocation(String deviceId) async {
    try {
      // Verificar a permissão de localização
      loc.PermissionStatus permission = await location.hasPermission();
      if (permission == loc.PermissionStatus.granted) {
        final loc.LocationData _locationResult = await location.getLocation();
        await FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).doc(deviceId).set({
          'latitude': _locationResult.latitude,
          'longitude': _locationResult.longitude,
          'name': deviceId
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
  Future<void> _listenLocastion(String deviceId) async {
    _locationSubscriptions[deviceId] = location.onLocationChanged.handleError((onError) {
      print("Erro: $onError");
      _locationSubscriptions[deviceId]?.cancel();
      setState(() {
        _locationSubscriptions.remove(deviceId);
      });
    }).listen((loc.LocationData currentlocation) async {
      // Atualizar a localização no Firestore durante a escuta
      String uid = FirebaseAuth.instance.currentUser?.uid ?? 'default';
      await FirebaseFirestore.instance.collection(uid).doc(deviceId).set({ 
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
        'name': deviceId
      }, SetOptions(merge: true));
    });
  }

  // Método para parar a escuta da localização em tempo real
  _stopListening(String deviceId) {
    _locationSubscriptions[deviceId]?.cancel();
    setState(() {
      _locationSubscriptions.remove(deviceId);
    });
  }

  // Método para solicitar permissão de localização
  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print("Concluido");
    } else if (status.isPermanentlyDenied) {
      // Abrir configurações do aplicativo se a permissão for negada permanentemente
      openAppSettings();
    }
  }
}