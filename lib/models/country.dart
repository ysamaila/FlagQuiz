class Country {
  final String name;
  final String capital;
  final String code;
  final String continent;

  const Country({
    required this.name,
    required this.capital,
    required this.code,
    required this.continent,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String,
      capital: json['capital'] as String,
      code: (json['code'] as String).toUpperCase(),
      continent: json['continent'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'capital': capital,
        'code': code,
        'continent': continent,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$name ($code)';
}
