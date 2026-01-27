/// Currency model
class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'symbol': symbol,
      'name': name,
    };
  }

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
    );
  }
}

/// Available currencies
class Currencies {
  static const Currency usd = Currency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
  );

  static const Currency bdt = Currency(
    code: 'BDT',
    symbol: '৳',
    name: 'Bangladeshi Taka',
  );

  static const Currency eur = Currency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
  );

  static const Currency gbp = Currency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
  );

  static const Currency inr = Currency(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
  );

  static const Currency jpy = Currency(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
  );

  static const Currency cny = Currency(
    code: 'CNY',
    symbol: '¥',
    name: 'Chinese Yuan',
  );

  static const Currency aud = Currency(
    code: 'AUD',
    symbol: 'A\$',
    name: 'Australian Dollar',
  );

  static const Currency cad = Currency(
    code: 'CAD',
    symbol: 'C\$',
    name: 'Canadian Dollar',
  );

  static const List<Currency> all = [
    usd,
    bdt,
    eur,
    gbp,
    inr,
    jpy,
    cny,
    aud,
    cad,
  ];

  static Currency getByCode(String code) {
    return all.firstWhere(
      (currency) => currency.code == code,
      orElse: () => bdt, // Default to BDT
    );
  }
}
