class Country {
  final String name;
  final String code; // ISO 2-letter, e.g. 'BR'
  final String dialCode; // e.g. '+55'
  final String? phoneMask; // e.g. '(##) #####-####', null = free input

  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    this.phoneMask,
  });

  String get flag {
    return code.toUpperCase().runes
        .map((c) => String.fromCharCode(c + 0x1F1A5))
        .join();
  }
}
