import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
// import 'package:sms/sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:siren/selectAirpot.dart';
import 'package:siren/slideAnimation.dart';

class SmsHomePage extends StatefulWidget {
  const SmsHomePage({super.key});

  @override
  _SmsHomePageState createState() => _SmsHomePageState();
}

class _SmsHomePageState extends State<SmsHomePage>
    with TickerProviderStateMixin {
  final String uniqueNumber = "+94741891381";
  //final String uniqueNumber = "+94758713250";
  final String sirenOn = "1234#ON#";
  final String sirenReset = "1234#RESET#";
  final String sirenConfig = "1234#GOT0060#";
  String _receivedMessage = '';

  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  late Animation<double> _scaleAnimation1;
  late Animation<double> _scaleAnimation2;
  late Animation<double> _scaleAnimation3;
  late TabController _tabController;
  late Stream<ConnectivityResult> _connectivityStream;
  AnimationController? _animationController;


  @override
  @override
@override
void initState() {
  super.initState();
  _tabController = TabController(length: 2, vsync: this);

  _requestPermissionsOnce(); // Ensure permissions are requested only once
  _connectivityStream = Connectivity().onConnectivityChanged;

 _initializeAnimations();
}


bool _permissionsRequested = false;

Future<void> _requestPermissionsOnce() async {
  if (!_permissionsRequested) {
    await _checkAndRequestPermissions();
    _permissionsRequested = true;
  }
}


Future<void> _checkAndRequestPermissions() async {
  PermissionStatus status = await Permission.sms.status;

  if (status.isDenied || status.isPermanentlyDenied) {
    PermissionStatus newStatus = await Permission.sms.request();
    if (newStatus.isGranted) {
      print("SMS permission granted");
    } else {
      print("SMS permission denied");
    }
  } else {
    print("SMS permission already granted");
  }
}

void _initializeAnimations() {
  _controller1 = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  _scaleAnimation1 = Tween<double>(begin: 1.0, end: 1.2).animate(
    CurvedAnimation(parent: _controller1, curve: Curves.easeInOut),
  );

  _controller2 = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  _scaleAnimation2 = Tween<double>(begin: 1.0, end: 1.2).animate(
    CurvedAnimation(parent: _controller2, curve: Curves.easeInOut),
  );

  _controller3 = AnimationController(
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  _scaleAnimation3 = Tween<double>(begin: 1.0, end: 1.2).animate(
    CurvedAnimation(parent: _controller3, curve: Curves.easeInOut),
  );

  _animationController = AnimationController(
    vsync: this, 
    duration: Duration(milliseconds: 2000),
  );
}

// ✅ Improved internet check function
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

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
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
              content: Text(
                message,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
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
                  onPressed: () =>
                      Navigator.of(context).pop(true), // User confirms
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

//SEND RESET MESSAGE
  void _sendSMSAndTime() async {
    String formattedTime =
        '${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}';

    try {
      // Sending SMS using flutter_sms package
      String result = await sendSMS(
        message: sirenOn, // Your message here
        recipients: [uniqueNumber], // Your recipient number
      );

      // Show Toast for SMS success
      Fluttertoast.showToast(
        msg: "Siren On Message sent successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 4, 112, 28),
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Simulate sending current time to an API
      await _sendCurrentTimeToApi(formattedTime);
    } catch (error) {
      // Show Toast for SMS error
      Fluttertoast.showToast(
        msg: "Error sending SMS: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    print("Attempting to send SMS to $uniqueNumber at $formattedTime");
  }

//SEND CURRENT TIME WITH API
  Future<void> _sendCurrentTimeToApi(String formattedTime) async {
    final String apiUrl =
        'https://radar.digitable.io/ping.php?t=$formattedTime';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Current time sent successfully');

        // Show Toast for API success
        Fluttertoast.showToast(
          msg: "Current time sent successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: const Color.fromARGB(255, 4, 112, 28),
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        print('Failed to send current time');

        // Show Toast for API failure
        Fluttertoast.showToast(
          msg: "Failed to send current time.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } catch (e) {
      print('Error sending current time: $e');

      // Show Toast for API error
      Fluttertoast.showToast(
        msg: "Error sending current time.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
  //SEND RESET MESSAGE

  void _sirenReset() async {
    try {
      // Sending SMS using flutter_sms package
      String result = await sendSMS(
        message: sirenReset, // Your message here
        recipients: [uniqueNumber], // Your recipient number
      );

      // Show Toast for SMS success
      Fluttertoast.showToast(
        msg: "Siren Reset SMS sent successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 245, 189, 6),
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // If necessary, send current time to an API or perform any other action here

    } catch (error) {
      // Show SnackBar for error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending SMS: $error")),
      );

      // Show Toast for SMS error
      Fluttertoast.showToast(
        msg: "Error sending SMS: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    print("Attempting to send SMS to $uniqueNumber");
  }

  //SEND CONFIG MESSAGE
  void _sirenConfig() async {
    try {
      // Sending SMS using flutter_sms package
      String result = await sendSMS(
        message: sirenConfig, // Your message to be sent
        recipients: [uniqueNumber], // Your recipient's number
      );

      // Show Toast for SMS success
      Fluttertoast.showToast(
        msg: "Siren Config SMS sent successfully!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromARGB(255, 243, 106, 43),
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // If necessary, perform any additional actions like sending data to an API

    } catch (error) {
      // Show SnackBar for error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending SMS: $error")),
      );

      // Show Toast for SMS error
      Fluttertoast.showToast(
        msg: "Error sending SMS: $error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    print("Attempting to send SMS to $uniqueNumber");
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _animationController!.dispose();
     _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    // appBar: AppBar(
    // //  title: Text("Your Title"),
    //   flexibleSpace: Container(
    //     decoration: BoxDecoration(
    //       gradient: LinearGradient(
    //         colors: [Colors.blue[100]!, Colors.white],
    //         begin: Alignment.topCenter,
    //         end: Alignment.bottomCenter,
    //       ),
    //     ),
    //   ),
    //   actions: [
    //     Padding(
    //       padding: const EdgeInsets.all(8.0), // Padding to fit the button properly
    //       child: ElevatedButton(
    //          style: ElevatedButton.styleFrom(
    //                 primary: const Color.fromARGB(
    //                     255, 245, 189, 6), // Background color
    //                 onPrimary: Colors.white, // Text color
    //                 padding: const EdgeInsets.symmetric(
    //                     horizontal: 30, vertical: 15),
    //                 shape: RoundedRectangleBorder(
    //                   borderRadius:
    //                       BorderRadius.circular(30), // Rounded corners
    //                 ),
    //                 elevation: 5,
    //                 minimumSize: const Size(150, 100), // Shadow effect
    //               ),
    //         onPressed: () {
    //           Navigator.push(
    //             context,
    //             MaterialPageRoute(builder: (context) => SelectionScreen()),
    //           );
    //         },
    //         child: Text(
    //           "Select Airport",
    //           style: TextStyle(color: Colors.white,fontSize: 12),

    //         ),
    //       ),
    //     ),
    //   ],
    // ),
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
              SlideAnimation(
                position: 4,
                itemCount: 10,
                slideDirection: SlideDirection.fromLeft,
                animationController: _animationController,
                child: const Text(
                  'Ground handler',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(
                height:100,
              ),
              SlideAnimation(
                animationController: _animationController,
                itemCount: 10,
                position: 4,
                slideDirection: SlideDirection.fromRight,
                child: const Text(
                  'Click Button !',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
              ),
              const SizedBox(height: 50),
              ScaleTransition(
                scale: _scaleAnimation1,
                child: SlideAnimation(
                  animationController: _animationController,
                  itemCount: 10,
                  position: 4,
                  slideDirection: SlideDirection.fromLeft,
                  child: ElevatedButton(
                    onPressed: () async {
                      _controller1
                          .forward()
                          .then((_) => _controller1.reverse());

                      if (await _checkInternetConnection()) {
                        bool userConfirmed = await _showConfirmationDialog(
                            cancelText: 'Cancel',
                            confirmText: 'Confirm',
                            message: 'Are you sure to On Siren ?',
                            title: 'Alert !');
                        if (userConfirmed) {
                          _sendSMSAndTime();
                        }
                      } else {
                        _showNoInternetDialog();
                      }
                    },
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
                    child:
                        const Text('Siren On', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ScaleTransition(
                scale: _scaleAnimation2,
                child: SlideAnimation(
                  animationController: _animationController,
                  itemCount: 10,
                  position: 5,
                  slideDirection: SlideDirection.fromRight,
                child: ElevatedButton(
                  onPressed: () async {
                    _controller2.forward().then((_) => _controller2.reverse());
                    bool userConfirmed = await _showConfirmationDialog(
                        cancelText: 'Cancel',
                        confirmText: 'Confirm',
                        message: 'Are you sure to Reset Siren ?',
                        title: 'Alert !');
                    if (userConfirmed) {
                      _sirenReset();
                    }
                  },
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
                  child:
                      const Text('Siren Reset', style: TextStyle(fontSize: 18)),
                ),
              ),),
              const SizedBox(height: 40),
              ScaleTransition(
                scale: _scaleAnimation3,
                child: SlideAnimation(
                  animationController: _animationController,
                  itemCount: 10,
                  position: 5,
                  slideDirection: SlideDirection.fromLeft,
                child: ElevatedButton(
                  onPressed: () async {
                    _controller3.forward().then((_) => _controller3.reverse());
                    bool userConfirmed = await _showConfirmationDialog(
                        cancelText: 'Cancel',
                        confirmText: 'Confirm',
                        message: 'Are you sure to Config Siren ?',
                        title: 'Alert !');
                    if (userConfirmed) {
                      _sirenConfig();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(
                        255, 243, 106, 43), // Background color
                    onPrimary: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Rounded corners
                    ),
                    elevation: 5,
                    minimumSize: const Size(200, 50), // Button size
                  ),
                  child: const Text('Siren Config',
                      style: TextStyle(fontSize: 18)),
                ),
              ),),
              const SizedBox(height: 20),
            
            
               SlideAnimation(
                animationController: _animationController,
                itemCount: 10,
                position: 6,
                slideDirection: SlideDirection.fromLeft,
           child:   Image.asset(
                'assets/images/speaker.webp',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),),
            ],
          ),
        ),
      ),
    );
  }
  // Widget showPassword() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(
  //         horizontal: MediaQuery.of(context).size.width / 12,
  //         vertical: MediaQuery.of(context).size.width / 40),
  //     child: SlideAnimation(
  //       position: 4,
  //       itemCount: 10,
  //       slideDirection: SlideDirection.fromRight,
  //       animationController: _animationController,
  //       child:

  //         keyboardType: TextInputType.text,
  //         decoration: InputDecoration(
  //           contentPadding: EdgeInsets.only(left: 15.0),
  //           hintStyle: TextStyle(

  //               fontSize: 16,
  //               fontWeight: FontWeight.normal),
  //           labelStyle: TextStyle(

  //               fontSize: 16,
  //               fontWeight: FontWeight.normal),
  //           filled: false,

  //           focusedBorder: OutlineInputBorder(
  //             gapPadding: 0.0,
  //             borderRadius: BorderRadius.circular(14),
  //             borderSide: BorderSide(

  //             ),
  //           ),
  //           border: OutlineInputBorder(
  //             gapPadding: 0.0,
  //             borderRadius: BorderRadius.circular(14),
  //             borderSide: BorderSide(

  //               width: 1,
  //             ),
  //           ),

  //         ),
  //       ),
  //     ),
  //   );
  // }

}