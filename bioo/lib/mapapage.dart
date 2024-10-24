import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapaPage extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  MapaPage({required this.onLocationSelected});

  @override
  _MapaPageState createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  late GoogleMapController mapController;
  LatLng _selectedLocation = LatLng(-23.5505, -46.6333); // Ponto padrão (São Paulo)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione sua Zona Segura'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _selectedLocation,
          zoom: 14,
        ),
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        onTap: (LatLng location) {
          setState(() {
            _selectedLocation = location;
          });
        },
        markers: {
          Marker(
            markerId: MarkerId('selected_location'),
            position: _selectedLocation,
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.onLocationSelected(_selectedLocation);
          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
