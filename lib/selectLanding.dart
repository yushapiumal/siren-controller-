import 'dart:io';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:siren/slideAnimation.dart';
import 'ApiServices.dart';
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
  String? pd_flightNo;
  String? des;
  AnimationController? _animationController;
  bool switchValue = false;
  late AnimationController _controller1;
  late Animation<double> _scaleAnimation1;
  DateTime today = DateTime.now();
  late Future<List<Flight>> _futureFlights;

  @override
  void initState() {
    super.initState();
    futureFlights = ApiService().fetchFlightData(widget.selectedAirport);
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    _controller1 = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation1 = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller1, curve: Curves.easeInOut),
    );

    _futureFlights = ApiService().fetchFlight(widget.selectedAirport);
  }

  

  void submitSelection() {
    if (_selectedFlight != null) {
      String desTime = _selectedFlight!.des;
      String flightNo = _selectedFlight!.pd_flightNo;
      print("==========----------${_selectedFlight!.pd_flightNo}");
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
                child: SlideAnimation(
                    position: 5,
                    itemCount: 10,
                    slideDirection: SlideDirection.fromRight,
                    animationController: _animationController!,
                    child: Text(
                        " Today : ${DateFormat('yyyy-MM-dd').format(today)} ",
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20,
                            fontWeight: FontWeight.w600)))),
            SizedBox(
              height: 20,
            ),
            SlideAnimation(
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No flights available today',style: TextStyle(fontSize:20, color: Colors.orange, fontWeight:FontWeight.bold ),));
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
                                'NO-:${flight.flightNo} ,  Flight No-: ${flight.pd_flightNo}',
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
                                "Selected Flight No: ${selectedFlight.pd_flightNo}");
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
                      indicatorColor: switchValue
                          ? Colors.blue
                          : Color.fromARGB(255, 4, 112, 28),
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
                CurvedAnimation(parent: _controller1, curve: Curves.easeInOut),
              ),
              child: SlideAnimation(
                position: 5,
                itemCount: 10,
                animationController: _animationController!,
                slideDirection: SlideDirection.fromLeft,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 4, 112, 28),
                    onPrimary: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    minimumSize: const Size(200, 50), // Shadow effect
                  ),
                  onPressed: () async {
                    _controller1.forward().then((_) => _controller1.reverse());

                    if (_selectedFlight == null) {
                      Fluttertoast.showToast(
                        msg: "Please select a flight",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black87,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    }
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
                      if (await _checkInternetConnection()) {
                        await _showConfirmationDialog(
                          cancelText: 'Cancel',
                          confirmText: 'Confirm',
                          message: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Are you sure to proceed with this?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "NO-: ${_selectedFlight?.flightNo ?? 'N/A'}",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Flight NO-: ${_selectedFlight?.pd_flightNo ?? 'N/A'}",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Status-: ${switchValue ? "T/O" : "Landing"}",
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          title: 'Alert!',
                        );
                      } else {
                        _showNoInternetDialog();
                      }
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
        'tower': true,
      });
      Fluttertoast.showToast(
        msg: "Data sent successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color.fromARGB(221, 26, 121, 7),
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

  Future<bool> _showConfirmationDialog({
    required String title,
    required Widget message, // Change String to Widget
    required String cancelText,
    required String confirmText,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Prevent dismissal by clicking outside
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: const Color(0xFFf9f9f9),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.orange, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              content: message, // Accepts a Widget now
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(false), // User cancels
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(cancelText),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    submitSelection();
                    setState(() {
                      _selectedFlight = null; // Reset selection
                    });
                  },
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(confirmText),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      print("Internet check failed: $e");
      return false;
    }
  }

  void _showNoInternetDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("No Internet"),
        content:
            const Text("Please check your internet connection and try again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
