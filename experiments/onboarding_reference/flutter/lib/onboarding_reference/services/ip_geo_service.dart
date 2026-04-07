import 'package:flutter/widgets.dart';

import '../data/countries.dart';
import '../models/country.dart';

class IpGeoService {
  static Country? detectCountry() {
    final locales = WidgetsBinding.instance.platformDispatcher.locales;
    for (final locale in locales) {
      final code = locale.countryCode;
      if (code != null && code.length == 2) {
        final country = countryByCode(code);
        if (country != null) return country;
      }
    }
    return null;
  }
}
