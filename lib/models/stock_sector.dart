
class StockSector {
  final String id;
  final String name;
  final double newsVolume; // Determines size
  final double changeRate; // Determines color (heat)

  const StockSector({
    required this.id,
    required this.name,
    required this.newsVolume,
    required this.changeRate,
  });

  // Dummy data for testing
  static List<StockSector> get dummyData {
    return [
      StockSector(id: '1', name: '반도체', newsVolume: 100, changeRate: 2.5),
      StockSector(id: '2', name: '2차전지', newsVolume: 80, changeRate: 1.8),
      StockSector(id: '3', name: 'AI/SW', newsVolume: 70, changeRate: 3.0),
      StockSector(id: '4', name: '바이오', newsVolume: 60, changeRate: -0.5),
      StockSector(id: '5', name: '자동차', newsVolume: 50, changeRate: 0.8),
      StockSector(id: '6', name: '조선', newsVolume: 40, changeRate: -1.2),
      StockSector(id: '7', name: '철강', newsVolume: 35, changeRate: -0.2),
      StockSector(id: '8', name: '화학', newsVolume: 30, changeRate: 0.5),
      StockSector(id: '9', name: '금융', newsVolume: 25, changeRate: 0.1),
      StockSector(id: '10', name: '건설', newsVolume: 20, changeRate: -2.0),
      StockSector(id: '11', name: '유통', newsVolume: 15, changeRate: -0.8),
      StockSector(id: '12', name: '통신', newsVolume: 10, changeRate: 0.3),
    ];
  }
}
