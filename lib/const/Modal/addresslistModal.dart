class Address {
  final String id;
  final String house;
  final String landmark;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  Address({
    required this.id,
    required this.house,
    required this.landmark,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
  });

  // Helper to show the address in the UI
  String get displayAddress => landmark.isNotEmpty ? "$house, $landmark" : house;

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id']?.toString() ?? '',
      // Map the "address" key from your JSON to our "house" field
      house: json['address']?.toString() ?? '',
      landmark: '', // Your JSON doesn't separate landmark, we'll keep it empty
      city: json['city']?.toString() ?? '',
      state: json['state'] ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      country: json['country'] ?? '',
    );
  }
}