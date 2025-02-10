class Flight {
  final String flightNo;
  final String des;

  Flight({required this.flightNo, required this.des});

  // Factory method to create a Flight from JSON
  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      flightNo: json['flightNo'] as String,  // Ensure this is parsed as a String
      des: json['des'] as String,            // Ensure this is parsed as a String
    );
  }
}
