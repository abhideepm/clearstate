class Currency {
  final String code;
  final String symbol;
  final String name;

  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
  });

  static const List<Currency> currencies = [
    Currency(code: 'USD', symbol: '\$', name: 'US Dollar'),
    Currency(code: 'EUR', symbol: '€', name: 'Euro'),
    Currency(code: 'GBP', symbol: '£', name: 'British Pound'),
    Currency(code: 'INR', symbol: '₹', name: 'Indian Rupee'),
    Currency(code: 'JPY', symbol: '¥', name: 'Japanese Yen'),
    Currency(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar'),
    Currency(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar'),
  ];
}
