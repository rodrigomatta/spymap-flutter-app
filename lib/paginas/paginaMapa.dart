import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class PaginaMapa extends StatefulWidget {
  final String idUsuario; // ID do usuário
  final ValueNotifier<String> notificadorCaminhoIcone; // Notificador para o caminho do ícone

  PaginaMapa(this.idUsuario, this.notificadorCaminhoIcone);

  @override
  _PaginaMapaState createState() => _PaginaMapaState();
}

class _PaginaMapaState extends State<PaginaMapa> {
  // Objeto de localização
  final loc.Location localizacao = loc.Location();

  // Controlador do GoogleMap
  late GoogleMapController _controlador;

  // Variável para armazenar o ícone customizado do marcador
  BitmapDescriptor? iconeCustomizado;

  @override
  void initState() {
    super.initState();
    
    // Carrega o marcador selecionado do Firestore
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('temas').doc(uid).get().then((documento) {
      if (documento.exists && documento.data()!['marcador'] != null) {
        // Carrega o ícone customizado com o caminho fornecido
        carregarIconeCustomizado(documento.data()!['marcador'], 300).then((iconeCustomizadoCarregado) {
          setState(() {
            iconeCustomizado = iconeCustomizadoCarregado;
          });
        });
      } else {
        // Carrega o ícone padrão se 'marcador' for nulo
        carregarIconeCustomizado('images/pontoazul.png', 250).then((iconeCustomizadoCarregado) {
          setState(() {
            iconeCustomizado = iconeCustomizadoCarregado;
          });
        });
      }
    });
  }

  // Método para mudar o ícone do marcador
  void alterarIcone(String caminho, int largura) {
    // Atualiza o ícone customizado com o novo caminho
    carregarIconeCustomizado(caminho, largura);
  }

  // Método para carregar o ícone customizado
  Future<BitmapDescriptor> carregarIconeCustomizado(String caminho, int largura) async {
    // Carrega o ícone customizado a partir do caminho fornecido
    final ByteData dados = await rootBundle.load(caminho);
    final ui.Codec codec = await ui.instantiateImageCodec(
      dados.buffer.asUint8List(),
      targetWidth: largura,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final byteData = await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
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
                  _controlador = controller;
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
  Future<void> moverCameraParaUsuario(AsyncSnapshot<QuerySnapshot> snapshot) async {
    if (snapshot.data!.docs.any((element) => element.id == widget.idUsuario)) {
      var doc = snapshot.data!.docs.firstWhere((element) => element.id == widget.idUsuario);

      // Anima a câmera para a posição do usuário
      await _controlador.animateCamera(
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