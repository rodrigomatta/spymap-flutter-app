import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MapPage extends StatefulWidget {
  final String user_id;

  MapPage(this.user_id);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Instância da classe Location do pacote location.
  final loc.Location location = loc.Location();

  // Instância do GoogleMapController que será utilizada para controlar o mapa.
  late GoogleMapController _controller;

  // Variável para controlar se o marcador foi adicionado ao mapa.
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Configuração do local do botão de ação flutuante.
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: StreamBuilder(
        // Stream que escuta alterações na coleção 'uID' do Firestore.
        stream: FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Verifica se o marcador já foi adicionado.
          if (_added) {
            // Chama a função MapPage para realizar a animação da câmera.
            MapPage(snapshot);
          }

          // Verifica se não há dados disponíveis.
          if (!snapshot.hasData) {
            // Exibe um indicador de carregamento enquanto os dados estão sendo carregados.
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          // Retorna o widget do GoogleMap com base nos dados do snapshot.
          return GoogleMap(
            // Configuração do tipo de mapa.
            mapType: MapType.hybrid,
            // Configuração dos marcadores no mapa.
            markers: {
              for (var doc in snapshot.data!.docs)
                Marker(
                  position: LatLng(
                    // Obtém a latitude do usuário com base no ID.
                    doc['latitude'],
                    // Obtém a longitude do usuário com base no ID.
                    doc['longitude'],
                  ),
                  markerId: MarkerId(doc.id),
                  // Configuração do ícone do marcador.
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueMagenta,
                  ),
                ),
            },
              // Configuração da posição inicial da câmera no mapa.
            initialCameraPosition: CameraPosition(
              target: LatLng(
                // Obtém a latitude do primeiro usuário na lista.
                snapshot.data!.docs.first['latitude'],
                // Obtém a longitude do primeiro usuário na lista.
                snapshot.data!.docs.first['longitude'],
              ),
              zoom: 14.75,
            ),
            // Callback chamado quando o mapa é criado.
            onMapCreated: (GoogleMapController controller) async {
              // Atualiza o controlador e marca que o marcador foi adicionado.
              setState(() {
                _controller = controller;
                _added = true;
              });
            },
          );
        },
      ),
    );
  }

  // Função assíncrona para realizar a animação da câmera no mapa.
  Future<void> MapPage(AsyncSnapshot<QuerySnapshot> snapshot) async {
    if (snapshot.data!.docs.any((element) => element.id == widget.user_id)) {
      var doc = snapshot.data!.docs.firstWhere((element) => element.id == widget.user_id);

      await _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              doc['latitude'],
              doc['longitude'],
            ),
            zoom: 14.75,
          ),
        ),
      );
    } else {
      print("No matching document found");
    }
  }
}