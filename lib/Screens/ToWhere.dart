import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class ToWhere extends StatefulWidget {
  const ToWhere({super.key});

  @override
  State<ToWhere> createState() => _ToWhereState();
}

class _ToWhereState extends State<ToWhere> {
  TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;
  LatLng? _startPoint;
  LatLng? _selectedDestination;
  LatLng? _searchedLocation;
  bool _isLoadingLocation = true;
  List<LatLng> _routePoints = [];
  double _distanceInKm = 0.0;
  bool _isSelectingStartPoint = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;

      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _startPoint = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      setState(() {
        _isLoadingLocation = false;
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  // دالة البحث باستخدام Nominatim API
  Future<void> _searchLocation(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1'
    );

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'MyApp/1.0 (your-email@example.com)'
      });

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          print('No locations found for this query');
          return;
        }

        // عرض نتائج البحث
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("نتائج البحث"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: data.map((location) {
                  String displayName = location["display_name"];
                  LatLng position = LatLng(
                    double.parse(location["lat"]),
                    double.parse(location["lon"]),
                  );

                  return ListTile(
                    title: Text(displayName),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _searchedLocation = position;
                      });
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      } else {
        print('Failed to fetch location: ${response.body}');
      }
    } catch (e) {

      print(' $e');
    }
  }

  // حساب المسافة بالكيلومترات
  void _calculateDistance() {
    if (_startPoint != null && _selectedDestination != null) {
      _distanceInKm = Geolocator.distanceBetween(
        _startPoint!.latitude,
        _startPoint!.longitude,
        _selectedDestination!.latitude,
        _selectedDestination!.longitude,
      ) /
          1000; // تحويل المسافة إلى كيلومترات
    }
  }

  // دالة لاسترجاع المسار من OSRM API
  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    final url =
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coordinates = data['routes'][0]['geometry']['coordinates'] as List;
        setState(() {
          _routePoints = coordinates
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();
        });
      } else {
        print('Failed to fetch route');
      }
    } catch (e) {
      print('Error fetching route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إلى أين'),
          backgroundColor: Colors.orange,
        ),
        body: _isLoadingLocation
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            // الخريطة
            FlutterMap(
              options: MapOptions(
                center: _startPoint ?? LatLng(0, 0),
                zoom: 13,
                onTap: (tapPosition, point) {
                  setState(() {
                    if (_isSelectingStartPoint) {
                      _startPoint = point;
                    } else {
                      _selectedDestination = point;
                      _calculateDistance();
                      if (_startPoint != null && _selectedDestination != null) {
                        _fetchRoute(_startPoint!, _selectedDestination!);
                      }
                    }
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    if (_startPoint != null)
                      Marker(
                        point: _startPoint!,
                        builder: (ctx) => const Icon(Icons.location_pin,
                            color: Colors.blue, size: 40),
                      ),
                    if (_selectedDestination != null)
                      Marker(
                        point: _selectedDestination!,
                        builder: (ctx) => const Icon(Icons.flag,
                            color: Colors.red, size: 40),
                      ),
                    if (_searchedLocation != null)
                      Marker(
                        point: _searchedLocation!,
                        builder: (ctx) => const Icon(Icons.search,
                            color: Colors.green, size: 40),
                      ),
                  ],
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4.0,
                        color: Colors.red,
                      ),
                    ],
                  ),
              ],
            ),
            // شريط البحث
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن موقع...',
                            border: InputBorder.none,
                          ),
                          onSubmitted: (value) {
                            _searchLocation(value);
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          _searchLocation(_searchController.text);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // شريط اختيار البداية والنهاية
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () {
                      setState(() {
                        _isSelectingStartPoint = true;
                      });
                    },
                    child: const Text('تحديد البداية'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onPressed: () {
                      setState(() {
                        _isSelectingStartPoint = false;
                      });
                    },
                    child: const Text('تحديد النهاية'),
                  ),
                ],
              ),
            ),
            // عرض المسافة
            if (_distanceInKm > 0)
              Positioned(
                bottom: 80,
                left: 20,
                child: Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.white,
                  child: Text(
                    "المسافة: ${_distanceInKm.toStringAsFixed(2)} كم",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
