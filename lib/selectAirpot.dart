import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siren/homePage.dart';
import 'package:siren/selectLanding.dart';
import 'package:siren/slideAnimation.dart';

class SelectionScreen extends StatefulWidget {
  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen>
    with TickerProviderStateMixin {
  String? _selectedAirport;
  AnimationController? _animationController;
  final List<String> _airports = ['NUF', 'CMB', 'RTF', 'DPC'];

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
  }

  // Check if it's the first time the user opens the app
  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;

    if (!isFirstTime) {
      // If not the first time, navigate to the landing page
      String? selectedAirport = prefs.getString('selected_airport');
      if (selectedAirport != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TogglePage(selectedAirport: selectedAirport),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Airport')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[100]!, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      
     child:  Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SlideAnimation(
                  animationController: _animationController!,
                  slideDirection: SlideDirection.fromLeft,
                  itemCount: 10,
                  position: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white,
                    ),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: Text(
                        'Select Airport',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: _selectedAirport,
                      underline: const SizedBox(), // Remove default underline
                      icon: Icon(Icons.airplanemode_active,
                          color: Colors.blue.shade700),
                      iconSize: 24,
                      dropdownColor: Colors.white,
                      style: TextStyle(
                        color: Colors.blueGrey.shade900,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      items: _airports.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              value,
                              style: TextStyle(
                                color: _selectedAirport == value
                                    ? Colors.blue.shade700
                                    : Colors.grey.shade800,
                                fontSize: 15,
                                fontWeight: _selectedAirport == value
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedAirport = newValue;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      elevation: 4,
                      menuMaxHeight: 300,
                      focusColor: Colors.blue.shade50,
                      disabledHint: Text(
                        'No airports available',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              SlideAnimation(
                  animationController: _animationController!,
                  slideDirection: SlideDirection.fromRight,
                  itemCount: 10,
                  position: 5,
                  child: ElevatedButton(
                    onPressed: _selectedAirport != null
                        ? () async {
                            final prefs = await SharedPreferences.getInstance();
                            //await prefs.setBool('first_time', false); // Set first_time flag to false
                            // await prefs.setString('selected_airport', _selectedAirport!); // Save selected airport

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TogglePage(
                                    selectedAirport:
                                        _selectedAirport!), // Pass selected airport
                              ),
                            );
                          }
                        : null,
                    child: const Text('Continue'),
                  )),
            ],
          ),
        ),
      ),
     ) );
  }
}
