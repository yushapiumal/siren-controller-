// Fetch flight data from API
// Future<List<Flight>> fetchFlightData(String selectedAirport) async {
//   DateTime today = DateTime.now();
//   String formattedDate = DateFormat('dd/MM/yyyy').format(today);
//   final response = await http.get(
//     Uri.parse(
//         'https://cinnamon.go.digitable.io/api/avidi/v1/radar?type=today&port=CMB'),
//   );

//   try {
//     if (response.statusCode == 200) {
//       Map<String, dynamic> responseData = jsonDecode(response.body);
//       List<dynamic> flightsData = responseData['data'];
//       if (flightsData.isEmpty) {
//         print("No flight data available.");
//         return [];
//       }
      
//       List<Flight> flights = flightsData.map((flight) {
//         var portData = flight['port_data'];

//         String pd_flightNo = portData['flightNo'] != null
//             ? portData['flightNo'].toString()
//             : 'N/A';

//         String flightNo = flight['flightNo'] != null
//             ? flight['flightNo'].toString()
//             : 'N/A';

//         String des = portData['des'] != null 
//             ? portData['des'].toString() 
//             : 'N/A';
        
//         print("FlightNo: $flightNo, PortData FlightNo: $pd_flightNo");
        
//         return Flight(
//           pd_flightNo: pd_flightNo,
//           des: des,
//           flightNo: flightNo,
//         );
//       }).toList();

//       if (flights.isNotEmpty) {
//         await sendToFirebase(flights);
//       }

//       return flights;
//     } else {
//       print('Failed to load data: ${response.statusCode}');
//       return [];
//     }
//   } catch (e) {
//     print('Error fetching flight data: $e');
//     return [];
//   }
// }

// // Send data to Firebase in comma-separated row format
// Future<void> sendToFirebase(List<Flight> flights) async {
//   final ref = FirebaseDatabase.instance.ref();
//   int totalLength = 16;

//   try {
//     // Create a single string with all flights separated by commas
//     String flightRow = flights.map((flight) {
//       String flightNo = flight.pd_flightNo;
//       String desTime = flight.des;
//       String paddedData1 = ' @ $desTime';
      
//       // Center align padding
//       String paddedString1 = paddedData1.padLeft((totalLength + paddedData1.length) ~/ 2).padRight(totalLength);
//       String paddedString2 = flightNo.padLeft((totalLength + flightNo.length) ~/ 2).padRight(totalLength);
      
//       print("Padded String 1: '$paddedString1'");
//       print("Padded String 2: '$paddedString2'");
      
//       return '$paddedString2$paddedString1';
//     }).join(', ');  // Join all flights with comma and space

//     // Update Firebase with the row format
//     await ref.update({
//       'today': flightRow,
//     });
    
//     print("Data sent to Firebase successfully!");
//     print("Sent data: $flightRow");
//   } catch (e) {
//     print("Failed to send data to Firebase: $e");
//   }
// }