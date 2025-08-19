class Crypto {
  final String id;
  final String name;
  final String symbol;
  final double priceUsd;
  final double? changePercent24Hr;
  final double? marketCapUsd;
  final double? volumeUsd24Hr;
  final double? supply;

  Crypto({
    required this.id,
    required this.name,
    required this.symbol,
    required this.priceUsd,
    this.changePercent24Hr,
    this.marketCapUsd,
    this.volumeUsd24Hr,
    this.supply,
  });

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      symbol: json['symbol'] ?? '',
      priceUsd: double.tryParse(json['priceUsd']?.toString() ?? '0') ?? 0,
      changePercent24Hr: double.tryParse(json['changePercent24Hr']?.toString() ?? ''),
      marketCapUsd: double.tryParse(json['marketCapUsd']?.toString() ?? ''),
      volumeUsd24Hr: double.tryParse(json['volumeUsd24Hr']?.toString() ?? ''),
      supply: double.tryParse(json['supply']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'priceUsd': priceUsd,
      'changePercent24Hr': changePercent24Hr,
      'marketCapUsd': marketCapUsd,
      'volumeUsd24Hr': volumeUsd24Hr,
      'supply': supply,
    };
  }

  factory Crypto.fromMap(Map<String, dynamic> map) {
    return Crypto(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      symbol: map['symbol'] ?? '',
      priceUsd: map['priceUsd'] ?? 0.0,
      changePercent24Hr: map['changePercent24Hr'],
      marketCapUsd: map['marketCapUsd'],
      volumeUsd24Hr: map['volumeUsd24Hr'],
      supply: map['supply'],
    );
  }
}
