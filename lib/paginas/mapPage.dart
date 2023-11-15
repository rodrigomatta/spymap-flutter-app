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
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isNotEmpty) {
            double latitude = snapshot.data!.docs.first['latitude'];
            double longitude = snapshot.data!.docs.first['longitude'];

            return GoogleMap(
              mapType: MapType.hybrid,
              markers: {
                for (var doc in snapshot.data!.docs)
                  Marker(
                    position: LatLng(
                      doc['latitude'],
                      doc['longitude'],
                    ),
                    markerId: MarkerId(doc.id),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueMagenta,
                    ),
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
            return Text("No documents found");
          }
        },
      ),
    );
  }

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