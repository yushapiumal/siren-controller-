class Flight {
  final String pd_flightNo;
  final String flightNo;
  final String des;
  

  Flight({required this.pd_flightNo, required this.flightNo, required this.des});

  // Factory method to create a Flight from JSON
  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      pd_flightNo: json['flightNo'] as String,  // Ensure this is parsed as a String
      des: json['des'] as String,    
      flightNo: json['flightNo'] as String        // Ensure this is parsed as a String
    );
  }
}
