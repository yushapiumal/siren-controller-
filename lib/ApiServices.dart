import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'flightJson.dart';
import 'package:http/http.dart' as http;

class ApiService {

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

          String pd_flightNo = portData['flightNo'] != null
              ? portData['flightNo'].toString()
              : 'N/A';

          String flightNo = flight['flightNo'] != null
              ? flight['flightNo'].toString()
              : 'N/A';

          String des =
              portData['des'] != null ? portData['des'].toString() : 'N/A';
          print("FlightNo: $flightNo, PortData FlightNo: $pd_flightNo");

          return Flight(pd_flightNo: pd_flightNo, des: des, flightNo: flightNo);
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






  Future<List<Flight>> fetchFlight(String selectedAirport) async {
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

          String pd_flightNo = portData['flightNo'] != null
              ? portData['flightNo'].toString()
              : 'N/A';

          String flightNo = flight['flightNo'] != null
              ? flight['flightNo'].toString()
              : 'N/A';

          String des = portData['des'] != null
              ? portData['des'].toString()
              : 'N/A';

          print("FlightNo: $flightNo, PortData FlightNo: $pd_flightNo");

          return Flight(
            pd_flightNo: pd_flightNo,
            des: des,
            flightNo: flightNo,
          );
        }).toList();

        if (flights.isNotEmpty) {
          await sendToFirebase(flights);
        }

        return flights;
      } else {
        print('Failed to load data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching flight data: $e');
      return [];
    }
  }

  Future<void> sendToFirebase(List<Flight> flights) async {
    final ref = FirebaseDatabase.instance.ref();
    int totalLength = 16;

    try {
      String flightRow = flights.map((flight) {
        String flightNo = flight.pd_flightNo;
        String desTime = flight.des;
        String paddedData1 = ' @ $desTime';
        String padRow = '$flightNo$paddedData1';

        String paddedString1 =
            padRow.padLeft((totalLength + padRow.length) ~/ 2).padRight(totalLength);
        // String paddedString2 =
        //     flightNo.padLeft((totalLength + flightNo.length) ~/ 2).padRight(totalLength);

        print("Padded String 1: '$paddedString1'");
       // print("Padded String 2: '$paddedString2'");

        return paddedString1;
      }).join(', ');

      await ref.update({
        'today': flightRow,
        //'led' : 'true'
      });

      print("Data sent to Firebase successfully!");
      print("Sent data: $flightRow");
    } catch (e) {
      print("Failed to send data to Firebase: $e");
    }
  }
}