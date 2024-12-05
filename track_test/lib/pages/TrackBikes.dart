import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:track_test/model/BikeModel.dart';
import 'package:track_test/services/BikeServices.dart';

class TrackBike extends StatefulWidget {
  const TrackBike({super.key, required this.bike});
  final BikeModel bike;

  @override
  _TrackBikeState createState() => _TrackBikeState();
}

class _TrackBikeState extends State<TrackBike> {
  double? totalDistance;
  double? totalDuration;
  final MapController mapController = MapController();
  LocationData? currentLocation;
  List<LatLng> routePoints = [];
  List<Marker> markers = [];
  double _currentZoom = 13.0;
  double maxDistance = 2.0;
  Timer? _markerUpdateTimer;
  double lat = 0.0;
  double long = 0.0;

  final String orsApiKey =
      '5b3ce3597851110001cf6248ed49d5d5d50b47c886fa2a8261919d5d';
  final BikeSrvice _bikeService = BikeSrvice();

  void _startMarkerUpdateTimer() {
    final Distance distance = Distance();
    _markerUpdateTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      final bikemodel = await _bikeService.getBikeById(widget.bike.id);
      if (bikemodel != null) {
        setState(() {
          widget.bike.longitude = bikemodel.longitude;
          widget.bike.latitude = bikemodel.latitude;
          if (currentLocation != null) {
            double calculatedDistance = distance.as(
              LengthUnit.Kilometer,
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
              LatLng(widget.bike.latitude, widget.bike.longitude),
            );
            if (calculatedDistance > maxDistance) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Alert: The bike is ${calculatedDistance.toStringAsFixed(2)} km away from your current location.",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  action: SnackBarAction(
                    label: "Close",
                    textColor: Colors.yellow,
                    onPressed: () {
                      print("Undo action clicked!");
                    },
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        });
      }
    });
  }

  void _updateRedMarkerPosition() {
    if (currentLocation != null) {
      setState(() {
        final LatLng lastPosition = markers.last.point;
        final newLatLng = LatLng(
            lastPosition.latitude - 0.001, lastPosition.longitude - 0.001);
        markers.removeLast();
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: newLatLng,
            child: const Icon(Icons.pedal_bike_sharp,
                color: Colors.red, size: 40.0),
          ),
        );
        _getRoute(newLatLng);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      long = widget.bike.longitude;
      lat = widget.bike.latitude;
    });
    _getCurrentLocation();
    _startMarkerUpdateTimer();
  }

  Future<void> _getCurrentLocation() async {
    var location = Location();
    try {
      var userLocation = await location.getLocation();
      setState(() {
        currentLocation = userLocation;
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(userLocation.latitude!, userLocation.longitude!),
            child: const Icon(Icons.accessibility_new_outlined,
                color: Colors.blue, size: 40.0),
          ),
        );
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(lat, long),
            child: const Icon(Icons.pedal_bike_sharp,
                color: Colors.red, size: 40.0),
          ),
        );
        _getRoute(LatLng(lat, long));
      });
    } on Exception {
      currentLocation = null;
    }

    location.onLocationChanged.listen((LocationData newLocation) {
      setState(() {
        currentLocation = newLocation;
      });
    });
  }

  Future<void> _getRoute(LatLng destination) async {
    if (currentLocation == null) return;
    final start =
        LatLng(currentLocation!.latitude!, currentLocation!.longitude!);
    final response = await http.get(
      Uri.parse(
          'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$orsApiKey&start=${start.longitude},${start.latitude}&end=${destination.longitude},${destination.latitude}'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coords =
          data['features'][0]['geometry']['coordinates'];
      setState(() {
        routePoints =
            coords.map((coord) => LatLng(coord[1], coord[0])).toList();
        final props = data['features'][0]['properties']['segments'][0];
        totalDistance = props['distance'] / 1000;
        totalDuration = props['duration'] / 60;
        markers.removeLast();
        markers.add(
          Marker(
            width: 80.0,
            height: 80.0,
            point: destination,
            child: const Icon(Icons.pedal_bike_sharp,
                color: Colors.red, size: 40.0),
          ),
        );
      });
    } else {
      print('Failed to fetch route');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bike Tracking Id :' + widget.bike.id.toString()),
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    initialZoom: _currentZoom,
                    // onTap: (tapPosition, point) => _getRoute(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(
                      markers: markers,
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
                if (totalDistance != null && totalDuration != null)
                  Positioned(
                    bottom: 20,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 5.0,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Distance: ${totalDistance!.toStringAsFixed(2)} km',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          Text(
                            'Temps estimé: ${totalDuration!.toStringAsFixed(2)} minutes',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                    right: 20,
                    bottom: 80,
                    child: Column(
                      children: [
                        FloatingActionButton(
                          mini: true,
                          onPressed: () {
                            setState(() {
                              _currentZoom += 1;
                              mapController.move(
                                mapController.center,
                                _currentZoom,
                              );
                            });
                          },
                          child: const Icon(Icons.zoom_in),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        FloatingActionButton(
                          mini: true,
                          onPressed: () {
                            setState(() {
                              _currentZoom -= 1;
                              mapController.move(
                                mapController.center,
                                _currentZoom,
                              );
                            });
                          },
                          child: const Icon(Icons.zoom_out),
                        ),
                      ],
                    ))
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (currentLocation != null) {
            mapController.move(
              LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
              _currentZoom,
            );
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
