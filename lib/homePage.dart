import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _mapController = MapController(initMapWithUserPosition: true);
  var markerMap = <String, String>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.listenerMapSingleTapping.addListener(() async {
        var position = _mapController.listenerMapSingleTapping.value;
        if (position != null) {
          await _mapController.addMarker(position,
              markerIcon: const MarkerIcon(
                icon: Icon(
                  Icons.pin_drop,
                  color: Colors.blue,
                  size: 120,
                ),
              ));
          var key = '${position!.latitude}_${position!.longitude}';
          markerMap[key] = markerMap.length.toString();
        }
      });
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Maps"),
        ),
        body: OSMFlutter(
          controller: _mapController,
          mapIsLoading: const Center(
            child: CircularProgressIndicator(),
          ),
          trackMyPosition: true,
          initZoom: 12,
          minZoomLevel: 4,
          maxZoomLevel: 19,
          stepZoom: 1.0,
          userLocationMarker: UserLocationMaker(
              personMarker: const MarkerIcon(
                icon: Icon(
                  Icons.personal_injury,
                  color: Colors.black,
                  size: 48.0,
                ),
              ),
              directionArrowMarker: const MarkerIcon(
                icon: Icon(
                  Icons.location_on,
                  color: Colors.black,
                  size: 48.0,
                ),
              )),
          roadConfiguration: const RoadOption(roadColor: Colors.blueGrey),
          markerOption: MarkerOption(
              defaultMarker: const MarkerIcon(
            icon: Icon(
              Icons.person_pin_circle,
              color: Colors.black,
              size: 120,
            ),
          )),
          onMapIsReady: (isReady) async {
            if (isReady) {
              await Future.delayed(Duration(seconds: 1), () async {
                await _mapController.currentLocation();
              });
            }
          },
          onGeoPointClicked: (geoPoint) {
            var key = '${geoPoint.latitude}_${geoPoint.longitude}';
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Card(
                      child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                            child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Position ${markerMap[key]}',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                            const Divider(thickness: 1,),
                            Text(
                              key,

                            ),
                          ],
                        )),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.clear),
                        )
                      ],
                    ),
                  ));
                });
          },
        ));
  }
}
