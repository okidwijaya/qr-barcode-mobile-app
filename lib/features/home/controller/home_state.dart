enum ScanType { barcode, qr }

class ScanItem {
  final String id;
  final ScanType type;
  final String data;
  final DateTime timestamp;

  ScanItem({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
  });

  ScanItem copyWith({
    String? id,
    ScanType? type,
    String? data,
    DateTime? timestamp,
  }) {
    return ScanItem(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class HomeState {
  final bool isLoading;
  final List<ScanItem> scanHistory;
  final int selectedNavIndex;
  final String? errorMessage;

  HomeState({
    this.isLoading = true,
    this.scanHistory = const [],
    this.selectedNavIndex = 0,
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    List<ScanItem>? scanHistory,
    int? selectedNavIndex,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      scanHistory: scanHistory ?? this.scanHistory,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
      errorMessage: errorMessage,
    );
  }
}