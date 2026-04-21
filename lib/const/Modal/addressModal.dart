// ---------- Address Model ----------
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

  factory Address.fromJson(Map<String, dynamic> json) {
    // Mapping "address_line1" back to house and landmark
    String rawAddr = (json['address_line1'] ?? '').toString();

    return Address(
      // Use 'address_id' because that's what your log shows!
      id: (json['address_id'] ?? json['id'] ?? '').toString(),
      house: rawAddr.split(',').first.trim(),
      landmark: rawAddr.contains(',')
          ? rawAddr.split(',').skip(1).join(',').trim()
          : '',
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      postalCode: (json['postal_code'] ?? '').toString(), // Use underscore
      country: (json['country'] ?? '').toString(),
    );
  }
}

// ---------- Address Response Model ----------
class AddressResponse {
  final bool status;
  final String message;
  final Address? data;

  AddressResponse({required this.status, required this.message, this.data});

  factory AddressResponse.fromJson(Map<String, dynamic> json) {
    return AddressResponse(
      status: json['status'] ?? false,
      message: (json['message'] ?? '').toString(),
      // Parse the 'data' object if it exists
      data: json['data'] != null ? Address.fromJson(json['data']) : null,
    );
  }
}