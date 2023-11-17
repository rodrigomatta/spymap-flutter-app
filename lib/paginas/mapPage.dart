import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MapPage extends StatefulWidget {
  final String user_id;
  final ValueNotifier<String> iconPathNotifier;

  MapPage(this.user_id, this.iconPathNotifier);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Objeto de localização
  final loc.Location location = loc.Location();

  // Controlador do GoogleMap
  late GoogleMapController _controller;

  // Variável para armazenar o ícone customizado do marcador
  BitmapDescriptor? iconeCustomizado;

  @override
  void initState() {
    super.initState();
    
    // Adiciona um listener ao notifier para atualizar o ícone quando houver alterações
    widget.iconPathNotifier.addListener(() {
      changeIcon(widget.iconPathNotifier.value, 200);
    });
  }

  // Método para mudar o ícone do marcador
  void changeIcon(String path, int width) {
    iconeCustomizadoCarregamento(path, width);
  }

  // Método para carregar o ícone customizado
  Future<void> iconeCustomizadoCarregamento(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    iconeCustomizado = BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: StreamBuilder(
        // Stream para obter dados do Firestore em tempo real
        stream: FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // Verifica se há dados
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // Verifica se há documentos no snapshot
          if (snapshot.data!.docs.isNotEmpty) {
            double latitude = snapshot.data!.docs.first['latitude'];
            double longitude = snapshot.data!.docs.first['longitude'];

            // Retorna o widget do GoogleMap
            return GoogleMap(
              mapType: MapType.hybrid,
              markers: {
                // Adiciona marcadores para cada documento no snapshot
                for (var doc in snapshot.data!.docs)
                  Marker(
                    position: LatLng(
                      doc['latitude'],
                      doc['longitude'],
                    ),
                    markerId: MarkerId(doc.id),
                    infoWindow: InfoWindow(
                      title: "Marcador: ${doc['name']}",
                    ),
                    icon: iconeCustomizado ?? BitmapDescriptor.defaultMarker,
                  ),
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  latitude,
                  longitude,
                ),
                zoom: 14.75,
              ),
              onMapCreated: (GoogleMapController controller) async {
                setState(() {
                  _controller = controller;
                });
              },
            );
          } else {
            return Text("Nenhum documento foi encontrado");
          }
        },
      ),
    );
  }

  // Método para movimentar a câmera para a posição do usuário específico
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
      print("Nenhum documento correspondente encontrado");
    }
  }
}