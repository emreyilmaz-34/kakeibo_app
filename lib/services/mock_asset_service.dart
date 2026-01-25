import '../models/asset.dart';

class MockAssetService {
  // Mock varlık listesi
  static final List<Asset> _assets = [
    Asset(
      symbol: 'ALTIN',
      name: 'Gold (Gram)',
      type: AssetType.commodity,
      price: 2850.0, // TRY per gram
      currency: 'TRY',
      unit: 'gram',
    ),
    Asset(
      symbol: 'THYAO',
      name: 'Türk Hava Yolları',
      type: AssetType.stock,
      price: 245.50, // TRY per share
      currency: 'TRY',
      unit: 'share',
    ),
    Asset(
      symbol: 'BIST30ETF',
      name: 'BIST 30 ETF',
      type: AssetType.etf,
      price: 125.75, // TRY per unit
      currency: 'TRY',
      unit: 'unit',
    ),
    Asset(
      symbol: 'AKBNK',
      name: 'Akbank',
      type: AssetType.stock,
      price: 68.90, // TRY per share
      currency: 'TRY',
      unit: 'share',
    ),
    Asset(
      symbol: 'GARAN',
      name: 'Garanti BBVA',
      type: AssetType.stock,
      price: 95.20, // TRY per share
      currency: 'TRY',
      unit: 'share',
    ),
    Asset(
      symbol: 'SASA',
      name: 'Sasa Polyester',
      type: AssetType.stock,
      price: 42.30, // TRY per share
      currency: 'TRY',
      unit: 'share',
    ),
  ];

  // Tüm varlıkları getir
  static Future<List<Asset>> getAllAssets() async {
    // Simüle edilmiş network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_assets);
  }

  // Belirli semboller için fiyatları getir
  static Future<Map<String, Asset>> getPrices(List<String> symbols) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final Map<String, Asset> result = {};
    for (final symbol in symbols) {
      final asset = _assets.firstWhere(
        (a) => a.symbol == symbol,
        orElse: () => Asset(
          symbol: symbol,
          name: symbol,
          type: AssetType.other,
          price: 0.0,
          currency: 'TRY',
          unit: 'unit',
        ),
      );
      result[symbol] = asset;
    }
    return result;
  }

  // Belirli bir varlığın fiyatını getir
  static Future<Asset?> getAssetBySymbol(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _assets.firstWhere((a) => a.symbol == symbol);
    } catch (e) {
      return null;
    }
  }

  // Fiyatları güncelle (mock - rastgele değişiklik simülasyonu)
  static Future<void> updatePrices() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // Gerçek uygulamada backend'den çekilecek
    // Şimdilik mock data olduğu için değişiklik yapmıyoruz
  }
}
