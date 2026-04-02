class CurrencyFormatter {
  static const double _eurToFcfa = 655.957;
  static const double _usdToFcfa = 600.0;

  static String formatPrice(int priceInFcfa, String? userCountry) {
    if (priceInFcfa == 0) return 'Gratuit';

    final countryStr = userCountry?.toLowerCase() ?? 'cameroon';

    // List of countries using Euro
    final europeCountries = [
      'france', 'germany', 'italy', 'spain', 'portugal', 'belgium',
      'netherlands', 'austria', 'greece', 'ireland', 'finland', 'cyprus',
      'estonia', 'latvia', 'lithuania', 'luxembourg', 'malta', 'slovakia',
      'slovenia', 'croatia', 'monaco', 'san marino', 'vatican', 'andorra'
    ];

    // List of countries using FCFA
    final fcfaCountries = [
      'cameroon', 'cameroun', 'central african republic', "république centrafricaine", 
      'chad', 'tchad', 'congo', 'equatorial guinea', "guinée équatoriale", 'gabon', 
      'benin', "bénin", 'burkina faso', "côte d'ivoire", 'ivory coast',
      'guinea-bissau', "guinée-bissau", 'mali', 'niger', 'senegal', "sénégal", 'togo'
    ];

    if (europeCountries.contains(countryStr)) {
      final inEur = priceInFcfa / _eurToFcfa;
      return '${inEur.toStringAsFixed(2)} €';
    } else if (fcfaCountries.contains(countryStr)) {
      final formatted = priceInFcfa.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
      return '$formatted FCFA';
    } else {
      final inUsd = priceInFcfa / _usdToFcfa;
      return '\$${inUsd.toStringAsFixed(2)}';
    }
  }
}
