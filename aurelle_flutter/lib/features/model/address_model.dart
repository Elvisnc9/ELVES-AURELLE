/// ─────────────────────────────────────────────────────────────────────────────
/// address_model.dart
/// ─────────────────────────────────────────────────────────────────────────────

class AddressModel {
  const AddressModel({
    required this.fullName,
    required this.phone,
    required this.streetLine1,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.streetLine2,
  });

  final String fullName;
  final String phone;
  final String streetLine1;
  final String? streetLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  /// Single-line summary shown in the checkout SHIPPING row
  String get summary =>
      '${streetLine1}${streetLine2 != null ? ', $streetLine2' : ''}, $city, $state $postalCode';

  /// Two-line display: name + address
  String get displayName => fullName;
  String get displayAddress => '$summary, $country';

  AddressModel copyWith({
    String? fullName,
    String? phone,
    String? streetLine1,
    String? streetLine2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) {
    return AddressModel(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      streetLine1: streetLine1 ?? this.streetLine1,
      streetLine2: streetLine2 ?? this.streetLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }
}