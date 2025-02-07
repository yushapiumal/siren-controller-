class Flight {
  final String id;
  final String flightDate;
  final String flightNo;
  final bool status;
  final String depTime;
  final String desTime;
  final String departure;
  final String destination;
  final bool canceled;
  final String createdAt;
  final String cap;
  final String fo;
  final String aircraft;
  final String route;

  Flight({
    required this.id,
    required this.flightDate,
    required this.flightNo,
    required this.status,
    required this.depTime,
    required this.desTime,
    required this.departure,
    required this.destination,
    required this.canceled,
    required this.createdAt,
    required this.cap,
    required this.fo,
    required this.aircraft,
    required this.route,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'],
      flightDate: json['flightDate'],
      flightNo: json['flightNo'],
      status: json['status'],
      depTime: json['depTime'],
      desTime: json['desTime'],
      departure: json['departure'],
      destination: json['destination'],
      canceled: json['canceled'],
      createdAt: json['created_at'],
      cap: json['cap'],
      fo: json['fo'],
      aircraft: json['aircraft'],
      route: json['route'],
    );
  }
}
