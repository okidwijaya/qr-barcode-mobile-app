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
}

class HomeState {
  final List<ScanItem> scanHistory;
  final bool isLoading;
  final int selectedNavIndex;

  HomeState({
    this.scanHistory = const [],
    this.isLoading = false,
    this.selectedNavIndex = 0,
  });

  HomeState copyWith({
    List<ScanItem>? scanHistory,
    bool? isLoading,
    int? selectedNavIndex,
  }) {
    return HomeState(
      scanHistory: scanHistory ?? this.scanHistory,
      isLoading: isLoading ?? this.isLoading,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
    );
  }
}