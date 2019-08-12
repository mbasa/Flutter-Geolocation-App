import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Marker> _allMarkers = [];
  FlutterMap _map;
  MapOptions _mapOpts;
  MapController _mapCont = new MapController();
  Location _location = new Location();
  bool _gpsOn = false;

  StreamSubscription<LocationData> _streamSubscription;
  int _timeInterval = 10000;
  double _distInterval = 100.0;

  @override
  void initState() {
    super.initState();
    initLocAndMap();
  }

  initLocAndMap() async {
    await _location.changeSettings(
        accuracy: LocationAccuracy.HIGH,
        interval: _timeInterval,
        distanceFilter: _distInterval);

    await _location.requestPermission();

    try {
      _location.getLocation().then((LocationData currentLoc) {
        if (currentLoc == null) {
          debugPrint("getLocation returned null");
          return;
        }

        _mapOpts = MapOptions(
            // onTap: centerMap,
            center: LatLng(currentLoc.latitude, currentLoc.longitude),
            minZoom: 17.0);

        _map = FlutterMap(options: _mapOpts, mapController: _mapCont, layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          MarkerLayerOptions(markers: _allMarkers)
        ]);

        setState(() {});
      });
    } catch (Exception) {
      debugPrint("Error in getLocation: ${Exception.toString()}");
    }
  }

  geoLocate() async {
    if (_streamSubscription != null) {
      _streamSubscription.cancel();
      _streamSubscription = null;
      _gpsOn = false;
      setState(() {});
      return;
    }

    debugPrint("GeoLocating");

    await _location.changeSettings(
        interval: _timeInterval, distanceFilter: _distInterval);

    try {
      _streamSubscription =
          _location.onLocationChanged().listen((LocationData currentLoc) {
        debugPrint("Listening");
        if (currentLoc != null) {
          double lat = currentLoc.latitude;
          double lon = currentLoc.longitude;
          centerMap(LatLng(lat, lon));

          debugPrint("Latitude: ${currentLoc.latitude}");
          debugPrint("Longitude: ${currentLoc.longitude}");
          debugPrint("Accuracy: ${currentLoc.accuracy}");
          debugPrint("Altitude: ${currentLoc.altitude}");
          debugPrint("Speed: ${currentLoc.speed}");
          debugPrint("Speed Accuracy:${currentLoc.speedAccuracy}");

          _gpsOn = true;
        }
      }, cancelOnError: true);
    } catch (Exception) {
      print("Exception: $Exception");
    }
  }

  void centerMap(LatLng latLng) {
    if (_allMarkers.isNotEmpty) {
      _allMarkers.clear();
    }
    _allMarkers.add(
      Marker(
        width: 45.0,
        height: 45.0,
        point: latLng,
        builder: (context) => IconButton(
          icon: Icon(Icons.location_on),
          color: Colors.blue,
          iconSize: 45.0,
          onPressed: () => debugPrint("Marker Pressed"),
        ),
      ),
    );
    _mapCont.move(latLng, _mapCont.zoom);
    setState(() {});
  }

  Widget createDrawer() {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(color: Colors.lime[50]),
        padding: EdgeInsets.fromLTRB(16, 82, 16, 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                "Enter GPS Parameters",
                style: TextStyle(fontSize: 24.0),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text("Set Distance Interval (meters) : "),
                  DropdownButton<double>(
                    elevation: 36,
                    value: _distInterval,
                    items: <double>[
                      0,
                      20,
                      50,
                      100,
                      200,
                      300,
                      400,
                      500,
                      1000,
                      2000
                    ].map((double value) {
                      return new DropdownMenuItem<double>(
                        value: value,
                        child: new Text("$value"),
                      );
                    }).toList(),
                    onChanged: (p) {
                      _distInterval = p;
                      setState(() {});
                      debugPrint("Val: $_timeInterval");
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text("Set Time Interval (milisecs) : "),
                  DropdownButton<int>(
                    elevation: 36,
                    value: _timeInterval,
                    items: <int>[1000, 5000, 10000, 15000, 20000, 30000, 60000]
                        .map((int value) {
                      return new DropdownMenuItem<int>(
                        value: value,
                        child: new Text("$value"),
                      );
                    }).toList(),
                    onChanged: (p) {
                      _timeInterval = p;
                      setState(() {});
                      debugPrint("Val: $_timeInterval");
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 32,
              ),
              RaisedButton(
                color: Colors.deepOrangeAccent,
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget waiting = Container(
      color: Colors.white,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );

    return _map == null
        ? waiting
        : Scaffold(
            appBar: new AppBar(
              title: new Text('GPS Test Map'),
              centerTitle: true,
              backgroundColor: _gpsOn ? Colors.deepOrangeAccent : Colors.blue,
            ),
            drawer: createDrawer(),
            body: _map,
            floatingActionButton: FloatingActionButton(
              onPressed: () => geoLocate(),
              backgroundColor: Colors.deepOrangeAccent,
              child: Icon(Icons.add_location),
            ),
          );
  }
}
