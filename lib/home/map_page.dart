import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // Import the geocoding package
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController googleMapController;
  List<String> properties = [];

  CameraPosition? initialCameraPosition;

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      // Get current user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Get highlighted property from Firestore
        QuerySnapshot highlightedSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('properties')
            .where('highlight', isEqualTo: true)
            .get();

        if (highlightedSnapshot.docs.isNotEmpty) {
          String highlightedAddress = highlightedSnapshot.docs.first['name'];
          await _fetchHighlightedAddress(highlightedAddress);
        }

        // Get all properties
        QuerySnapshot propertySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('properties')
            .get();

        for (QueryDocumentSnapshot documentSnapshot in propertySnapshot.docs) {
          Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;

          if (data != null) {
            String address = data['name'];
            properties.add(address);
            _addMarker(address); // Add marker for each property
          }
        }

        setState(() {
          // Update the state after loading properties
        });
      }

      // Set initial camera position to current location if not set
      if (initialCameraPosition == null) {
        Position position = await _getCurrentLocation();
        setState(() {
          initialCameraPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 14,
          );
        });
      }
    } catch (e) {
      print('Error loading properties: $e');
      // Handle error
    }
  }

  Future<void> _fetchHighlightedAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      print (locations);
      if (locations.isNotEmpty) {
        setState(() {
          initialCameraPosition = CameraPosition(
            target: LatLng(locations.first.latitude, locations.first.longitude),
            zoom: 14,
          );
        });
      }
    } catch (e) {
      print('Error fetching highlighted address: $e');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: GoogleMap(
          initialCameraPosition: initialCameraPosition ?? CameraPosition(target: LatLng(0, 0), zoom: 14), // Use default camera position if not set
          markers: markers,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
          onMapCreated: (GoogleMapController controller) {
            googleMapController = controller;
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Position position = await _getCurrentLocation();
          googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(position.latitude, position.longitude),
                zoom: 14,
              ),
            ),
          );
        },
        label: Text(
          "Current Location",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        icon: Icon(
          Icons.location_history,
          color: Colors.white,
        ),
      ),
    );
  }

  void _addMarker(String address) async {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      var marker = Marker(
        markerId: MarkerId(address),
        position: LatLng(
          locations.first.latitude,
          locations.first.longitude,
        ),
        infoWindow: InfoWindow(title: address),
      );
      setState(() {
        markers.add(marker);
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Handle the case where the user denies permission
        return Future.error("Location permission denied");
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}