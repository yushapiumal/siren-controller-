
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:siren/slideAnimation.dart';
import 'flightJson.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

class TogglePage extends StatefulWidget {
  final String selectedAirport;
  const TogglePage({Key? key, required this.selectedAirport}) : super(key: key);

  @override
  _TogglePageState createState() => _TogglePageState();
}

class _TogglePageState extends State<TogglePage> with TickerProviderStateMixin {
  bool isTakeOff = false;
  late Future<List<Flight>> futureFlights;
  Flight? _selectedFlight;
  String? flightNo;
  String? des;
  AnimationController? _animationController;
  bool switchValue = false;
  late AnimationController _controller1;
  late Animation<double> _scaleAnimation1;
   DateTime today = DateTime.now();

  @override
  void initState() {
    super.initState();
    futureFlights = fetchFlightData(widget.selectedAirport);
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation1 = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller1, curve: Curves.easeInOut),
    );
  }

  Future<List<Flight>> fetchFlightData(String selectedAirport) async {
    DateTime today = DateTime.now();
   String formattedDate = DateFormat('dd/MM/yyyy').format(today);
    final response = await http.get(
      Uri.parse(
          'https://cinnamon.go.digitable.io/api/avidi/v1/radar?type=today&port=$selectedAirport'),
    );

    try {
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        List<dynamic> flightsData = responseData['data'];
        if (flightsData.isEmpty) {
          print("No flight data available.");
          return [];
        }
        

        List<Flight> flights = flightsData.map((flight) {
          var portData = flight['port_data'];
          String flightNo = portData['flightNo'] != null
              ? portData['flightNo'].toString()
              : 'N/A';
          String des =
              portData['des'] != null ? portData['des'].toString() : 'N/A';

          return Flight(flightNo: flightNo, des: des);
        }).toList();

        return flights;
      } else {
        print('Failed to load data');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  void submitSelection() {
    if (_selectedFlight != null) {
      String desTime = _selectedFlight!.des;
      String flightNo = _selectedFlight!.flightNo;
      print("==========----------${_selectedFlight!.flightNo}");
      sendData(flightNo, desTime);
    } else {
      Fluttertoast.showToast(
        msg: "Please select a flight",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       // appBar: AppBar(title: Text("SELECT T/O")),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[100]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 120),
                  child: SlideAnimation(position: 5, 
                  itemCount:10, slideDirection:SlideDirection.fromRight,
                   animationController: _animationController!,
                    child:Text(" Today : ${DateFormat('yyyy-MM-dd').format(today)} ",style: TextStyle(color:Colors.blue,fontSize: 20,fontWeight:FontWeight.w600
                   )   )) ),
           
                   SizedBox(height: 20,)
                   
               , SlideAnimation(
                  position: 5,
                  itemCount: 10,
                  animationController: _animationController!,
                  slideDirection: SlideDirection.fromBottom,
                  child: Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                    ),
                    child: FutureBuilder<List<Flight>>(
                      future: futureFlights,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No flights found.'));
                        } else {
                          List<Flight> flights = snapshot.data!;
                          return DropdownButton<Flight>(
                            isExpanded: true,
                            value: _selectedFlight,
                            underline: SizedBox(),
                            icon: Icon(Icons.airplanemode_active,
                                color: Colors.blue.shade700),
                            iconSize: 24,
                            dropdownColor: Colors.white,
                            style: TextStyle(
                              color: Colors.blueGrey.shade900,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            hint: Text(
                              "Select a Flight",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            items: flights.map((Flight flight) {
                              return DropdownMenuItem<Flight>(
                                value: flight,
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Flight No: ${flight.flightNo}',
                                    style: TextStyle(
                                      color: _selectedFlight == flight
                                          ? Colors.blue.shade700
                                          : Colors.grey.shade800,
                                      fontSize: 15,
                                      fontWeight: _selectedFlight == flight
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (Flight? selectedFlight) {
                              setState(() {
                                _selectedFlight = selectedFlight;
                              });

                              // Print the selected flight number if it's not null
                              if (selectedFlight != null) {
                                print(
                                    "Selected Flight No: ${selectedFlight.flightNo}");
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            elevation: 4,
                            menuMaxHeight: 300,
                            focusColor: Colors.blue.shade50,
                            disabledHint: Text(
                              'No flights available',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideAnimation(
                      position: 5,
                      itemCount: 10,
                      animationController: _animationController!,
                      slideDirection: SlideDirection.fromBottom,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: AnimatedToggleSwitch<bool>.size(
                          current: switchValue,
                          values: const [false, true],
                          iconOpacity: 0.2,
                          indicatorSize: const Size.fromWidth(100),
                          borderWidth: 3.5,
                          borderColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: Offset(0, 8),
                            ),
                          ],
                          innerColor: Colors.white,
                          indicatorColor:
                              switchValue ? Colors.blue : Color.fromARGB(
                          255, 4, 112, 28),
                          iconAnimationType: AnimationType.onHover,
                          customIconBuilder: (context, local, global) => Center(
                            // Centers the text
                            child: Text(
                              local.value ? "T/O" : "Landing",
                              textAlign: TextAlign
                                  .center, // Ensures text alignment in case of dynamic changes
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color.lerp(Colors.black, Colors.white,
                                    local.animationValue),
                              ),
                            ),
                          ),
                          animationDuration: const Duration(milliseconds: 300),
                          onChanged: (value) {
                            setState(() {
                              switchValue = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                    CurvedAnimation(
                        parent: _controller1, curve: Curves.easeInOut),
                  ),
                  child: SlideAnimation(
                    position: 5,
                    itemCount: 10,
                    animationController: _animationController!,
                    slideDirection: SlideDirection.fromLeft,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                         primary: const Color.fromARGB(
                          255, 4, 112, 28), // Background color
                        onPrimary: Colors.white, // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Rounded corners
                        ),
                        elevation: 5,
                        minimumSize: const Size(200, 50), // Shadow effect
                      ),
                      onPressed: () async {
                        _controller1
                            .forward()
                            .then((_) => _controller1.reverse());

                        if (_selectedFlight == null) {
                          Fluttertoast.showToast(
                            msg: "Please select a flight",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.black87,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Confirmation"),
                              content: const Text("Do you want to proceed?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    submitSelection();
                                  },
                                  child: const Text("Yes"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Submit Selection'),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Future<void> sendData(String flightNo, String updatedDesTime) async {
    final ref = FirebaseDatabase.instance.ref();
    String status = switchValue ? "T/O" : "LANG";
    String paddData1 = '$status @ $updatedDesTime';
    int totalLength = 16;
    int padLeftLength1 = (totalLength - paddData1.length) ~/ 2;
    int padRightLength1 = totalLength - paddData1.length - padLeftLength1;
    String paddedString1 = paddData1
        .padLeft(paddData1.length + padLeftLength1)
        .padRight(totalLength);
    String paddData2 = flightNo;
    int padLeftLength2 = (totalLength - paddData2.length) ~/ 2;
    int padRightLength2 = totalLength - paddData2.length - padLeftLength2;
    String paddedString2 = paddData2
        .padLeft(paddData2.length + padLeftLength2)
        .padRight(totalLength);
    print("Padded String 1: '$paddedString1'");
    print("Padded String 2: '$paddedString2'");

    try {
      await ref.update({
        'inarea': "$paddedString2  $paddedString1",
        'led': true,
        'tower': false,
      });
      Fluttertoast.showToast(
        msg: "Data sent successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Color.fromARGB(221, 26, 121, 7),
        textColor: Colors.white,
        fontSize: 16.0,
      );

      print("Data sent successfully!");
      print("$paddedString2  $paddedString1");
    } catch (e) {
      print("Error sending data: $e");
      Fluttertoast.showToast(
        msg: "Error sending data",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
