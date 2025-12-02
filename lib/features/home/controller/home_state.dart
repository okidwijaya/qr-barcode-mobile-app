enum ScanType { qr, barcode }
class ScanItem {
  final String id;
  final String data;
  final ScanType type;
  final DateTime timestamp;

  ScanItem({
    required this.id,
    required this.data,
    required this.type,
    required this.timestamp,
  });

  ScanItem copyWith({
    String? id,
    String? data,
    ScanType? type,
    DateTime? timestamp,
  }) {
    return ScanItem(
      id: id ?? this.id,
      data: data ?? this.data,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class HomeState {
  final bool isLoading;
  final int selectedNavIndex;
  final List<ScanItem> scanHistory;

  HomeState({
    this.isLoading = true,
    this.selectedNavIndex = 2,
    this.scanHistory = const [],
  });

  HomeState copyWith({
    bool? isLoading,
    int? selectedNavIndex,
    List<ScanItem>? scanHistory,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
      scanHistory: scanHistory ?? this.scanHistory,
    );
  }
}