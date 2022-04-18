//@dart=2.9
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:p10/directions_model.dart';
import 'package:p10/directions_repository.dart';

class ThemapPage extends StatefulWidget {
  LatLng orderdest;
  ThemapPage({this.orderdest});
  @override
  _ThemapPageState createState() => _ThemapPageState();
}

class _ThemapPageState extends State<ThemapPage> {
  GoogleMapController mapController;
  Marker destination;
  Marker origin;
  Directions info;
  // ignore: unused_field
  Location _location = Location();
  LatLng _initialcameraposition = LatLng(45.521563, -122.677433);
  Location location = new Location();

  void _onMapCreated(GoogleMapController controlr) async {
    GoogleMapController _controller = controlr;
    LocationData currentloc = await location.getLocation();

    // setState(() {
    //   destination = Marker(
    //       markerId: const MarkerId('destination'),
    //       infoWindow: const InfoWindow(title: 'Destination'),
    //       position: widget.orderdest,
    //       icon: BitmapDescriptor.defaultMarkerWithHue(
    //         BitmapDescriptor.hueRed,
    //       ));
    // });

    setState(() {
      origin = Marker(
          markerId: MarkerId('origin'),
          position: LatLng(currentloc.latitude, currentloc.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          ));
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: origin.position, zoom: 15),
        ),
      );
    });

    if (widget.orderdest != null) addDestination(widget.orderdest);

    // _location.onLocationChanged.listen((l) {
    //   if (l.latitude != null && l.longitude != null) {
    //     _controller.animateCamera(
    //       CameraUpdate.newCameraPosition(
    //         CameraPosition(target: LatLng(l.latitude, l.longitude), zoom: 15),
    //       ),
    //     );
    //   }
    // });
  }

  void addDestination(LatLng pos) async {
    setState(() {
      if (pos != null) {
        info = null;

        destination = Marker(
            markerId: const MarkerId('destination'),
            infoWindow: const InfoWindow(title: 'Destination'),
            position: pos,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ));
      }
    });

    final directions = await DirectionsRepository()
        .getDirections(origin: origin.position, destination: pos);
    setState(() => info = directions);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
          fontFamily: 'source sans pro', fontSize: 18, color: Colors.black),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
              child: Container(
            width: double.infinity,
            child: //MyMap()

                Stack(alignment: Alignment.center, children: [
              GoogleMap(
                polylines: {
                  if (info != null)
                    Polyline(
                      polylineId: const PolylineId('overview_polyline'),
                      color: Colors.red,
                      width: 5,
                      points: info.polylinePoints
                          .map((e) => LatLng(e.latitude, e.longitude))
                          .toList(),
                    ),
                },
                onMapCreated: _onMapCreated,
                markers: {
                  if (destination != null) destination,
                  // if (origin != null) origin
                },
                onLongPress: (pos) => destination == null
                    ? addDestination(pos)
                    : setState(() {
                        destination = null;
                        info = null;
                      }),
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: _initialcameraposition,
                  zoom: 11.0,
                ),
              ),
              if (info != null)
                Positioned(
                  top: 20.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 6.0,
                        )
                      ],
                    ),
                    child: Text(
                      '${info.totalDistance}, ${info.totalDuration}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ]),
          )),
          // Stack(clipBehavior: Clip.none, children: [
          //   Container(
          //     width: double.infinity,
          //     color: Colors.white,
          //     padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          //     height: 300,
          //     child: Column(
          //       children: [
          //         Container(
          //           color: Colors.grey,
          //           padding: EdgeInsets.symmetric(horizontal: 20),
          //           child: Row(
          //             children: [
          //               Text(
          //                 'Where To?',
          //               ),
          //               Container(
          //                   padding: EdgeInsets.symmetric(horizontal: 5),
          //                   decoration: BoxDecoration(
          //                       color: Colors.white,
          //                       borderRadius: BorderRadius.circular(10)),
          //                   child: Row(
          //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //                     children: [
          //                       Icon(
          //                         Icons.access_time_filled_outlined,
          //                       ),
          //                       Text('Now'),
          //                       Icon(Icons.arrow_drop_down_sharp)
          //                     ],
          //                   ))
          //             ],
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           ),
          //           height: 40,
          //           width: double.infinity,
          //         ),
          //         SizedBox(
          //           height: 20,
          //         ),
          //         Container(
          //             child: Row(
          //           mainAxisAlignment: MainAxisAlignment.start,
          //           children: [
          //             Icon(Icons.history),
          //             SizedBox(width: 10),
          //             Text('hlsjsi jff eij')
          //           ],
          //         ))
          //       ],
          //     ),
          //   ),
          //   Positioned(
          //     left: 0,
          //     top: -90,
          //     child: Container(
          //       padding: EdgeInsets.all(10.0),
          //       child: FloatingActionButton(
          //         backgroundColor: Color(0xff2351ad),
          //         child: Icon(
          //           Icons.location_on,
          //           color: Colors.white,
          //         ),
          //         onPressed: null,
          //       ),
          //     ),
          //   )
          // ])
        ],
      ),
      // Align(
      //   alignment: Alignment.topLeft,
      //   child: Container(
      //     padding: EdgeInsets.only(
      //         top: MediaQuery.of(context).padding.top + 5, left: 5),
      //     child: FloatingActionButton(
      //       backgroundColor: Colors.white,
      //       child: Icon(
      //         Icons.dehaze_outlined,
      //         color: Colors.black,
      //       ),
      //       onPressed: null,
      //     ),
      //   ),
      // ),
    );
  }
}
