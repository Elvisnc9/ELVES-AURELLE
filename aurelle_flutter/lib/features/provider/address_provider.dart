/// ─────────────────────────────────────────────────────────────────────────────
/// address_provider.dart
/// Global address provider — read by CheckoutScreen to show saved address.
/// Written to by AddAddressScreen on save.
/// ─────────────────────────────────────────────────────────────────────────────

import 'package:aurelle_flutter/features/model/address_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddressNotifier extends StateNotifier<AddressModel?> {
  AddressNotifier() : super(null);

  void save(AddressModel address) => state = address;
  void clear() => state = null;
}

final addressProvider =
    StateNotifierProvider<AddressNotifier, AddressModel?>(
  (ref) => AddressNotifier(),
);