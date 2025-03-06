import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:siren/homePage.dart';
import 'package:siren/selectLanding.dart';
import 'package:siren/slideAnimation.dart';
import 'package:siren/tabpage.dart';

class SelectionScreen extends StatefulWidget {
  @override
  _SelectionScreenState createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen>
    with TickerProviderStateMixin {
  String? _selectedAirport;
  AnimationController? _animationController;
  final List<String> _airports = ['NUF'];
  late Animation<double> _scaleAnimation2;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    _controller2 = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation2 = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller2, curve: Curves.easeInOut),
    );
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
       // appBar: AppBar(title: const Text('Select Airport')),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[100]!, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
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
                          underline:
                              const SizedBox(), // Remove default underline
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
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.1).animate(
                      CurvedAnimation(
                          parent: _controller2, curve: Curves.easeInOut),
                    ),
                    child: SlideAnimation(
                      animationController: _animationController!,
                      slideDirection: SlideDirection.fromRight,
                      itemCount: 10,
                      position: 5,
                      child: ElevatedButton(
                         style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(
                        255, 245, 189, 6), // Background color
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
                         onPressed: _selectedAirport != null
      ? () async {
          _controller2.forward().then((_) => _controller2.reverse());
          await _showConfirmationDialog(context);  // Show the confirmation dialog
        }
      : null,
                          
                        child: const Text('Continue'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
  Future<void> _showConfirmationDialog(BuildContext context) async {
  // Show the confirmation dialog
  bool? isConfirmed = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Warning!', style: TextStyle(color: Colors.red)),
        content: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: "You can't change this airport again once you select. Do you want to continue with ",
              ),
              TextSpan(
                text: _selectedAirport,
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),  // Change color here
              ),
              const TextSpan(
                text: " ?",
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);  // User clicked No
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);  // User clicked Yes
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );

  if (isConfirmed == true) {
    // If Yes, save the selected airport and navigate
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time', false);
   await prefs.setString('selected_airport', _selectedAirport!);

    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyTabbedApp(
          selectedAirport: _selectedAirport!,
        ),
      ),
    );
  }
  
}
}
