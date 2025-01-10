class MarketModel {
  final String symbol;
  final double bid;

  MarketModel({
    required this.symbol,
    required this.bid,
  });

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      symbol: json['symbol'],
      bid: json['bid'].toDouble(),
    );
  }
}
