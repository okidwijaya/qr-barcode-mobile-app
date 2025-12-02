import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_app/features/home/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:qr_app/features/home/controller/home_state.dart';
import 'package:qr_app/routes/go_router_ad_extension.dart';

class HeaderSection extends StatelessWidget {
  final int itemCount;

  const HeaderSection({Key? key, required this.itemCount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Scan History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$itemCount items',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text(
            'No scan history',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your scanned codes will appear here',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class ScanHistoryList extends StatelessWidget {
  final List<ScanItem> items;
  final HomeController controller;

  const ScanHistoryList({
    Key? key,
    required this.items,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ScanHistoryCard(
          item: items[index],
          onDelete: () => controller.deleteScanItem(items[index].id),
          onCopy: () => controller.copyScanData(items[index].data),
        );
      },
    );
  }
}

class ScanHistoryCard extends StatelessWidget {
  final ScanItem item;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const ScanHistoryCard({
    Key? key,
    required this.item,
    required this.onDelete,
    required this.onCopy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isBarcode = item.type == ScanType.barcode;
    final icon = isBarcode ? Icons.barcode_reader : Icons.qr_code;
    final color = isBarcode ? Colors.orange : Colors.green;
    final typeLabel = isBarcode ? 'Barcode' : 'QR Code';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showDetailDialog(context, color, isBarcode),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              typeLabel,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            _formatTime(item.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        item.data,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDate(item.timestamp),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'copy') {
                      onCopy();
                    } else if (value == 'delete') {
                      _confirmDelete(context);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'copy',
                          child: Row(
                            children: [
                              Icon(
                                Icons.copy,
                                size: 20,
                                color: Colors.blue[700],
                              ),
                              SizedBox(width: 12),
                              Text('Copy'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • HH:mm').format(dateTime);
  }

  void _confirmDelete(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Item'),
        content: Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context, Color color, bool isBarcode) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isBarcode ? Icons.barcode_reader : Icons.qr_code,
                  color: color,
                  size: 40,
                ),
              ),
              SizedBox(height: 16),
              Text(
                isBarcode ? 'Barcode' : 'QR Code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  item.data,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              Text(
                _formatDate(item.timestamp),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        onCopy();
                      },
                      icon: Icon(Icons.copy),
                      label: Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      child: Text('Close'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScanHistoryWidget extends StatefulWidget {
  const ScanHistoryWidget({Key? key}) : super(key: key);

  @override
  State<ScanHistoryWidget> createState() => _ScanHistoryWidgetState();
}

class _ScanHistoryWidgetState extends State<ScanHistoryWidget> {
  List<ScanItem> _scanItems = [];
  bool _isLoading = true;
  late HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await controller.loadScanHistory();
    setState(() {
      _scanItems = controller.state.value.scanHistory;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_scanItems.isEmpty) {
      return EmptyStateWidget();
    }

    return ScanHistoryList(items: _scanItems, controller: controller);
  }
}

class SpeedDialFAB extends StatefulWidget {
  final dynamic controller;

  const SpeedDialFAB({Key? key, required this.controller}) : super(key: key);

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB> {
  bool isOpen = false;

  void toggleMenu() {
    setState(() {
      isOpen = !isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child:
              isOpen
                  ? Column(
                    key: ValueKey('menu'),
                    children: [
                      _buildOption(
                        context: context,
                        icon: Icons.qr_code,
                        label: 'Generate QR',
                        onTap: () {
                          setState(() => isOpen = false);
                          context.pushWithAd('/qr_generator');
                        },
                        color: Colors.green,
                      ),
                      SizedBox(height: 12),
                      _buildOption(
                        context: context,
                        icon: Icons.barcode_reader,
                        label: 'Generate Barcode',
                        onTap: () {
                          setState(() => isOpen = false);
                          context.pushWithAd('/barcode_generator');
                        },
                        color: Colors.orange,
                      ),
                    ],
                  )
                  : SizedBox.shrink(),
        ),
        FloatingActionButton(
          onPressed: toggleMenu,
          backgroundColor: Color(0xFFFF5F15),
          heroTag: 'main_fab',
          child: Icon(isOpen ? Icons.close : Icons.add, size: 28, color: Colors.white,),
        ),
      ],
    );
  }
}

Widget _buildOption({
  required BuildContext context,
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  required Color color,
}) {
  return Material(
    elevation: 8,
    borderRadius: BorderRadius.circular(50),
    color: Colors.white,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(width: 4),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 70,
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      elevation: 22,
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.pushWithAd('/qr_scanner');
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      color:
                          selectedIndex == 1
                              ? Colors.blue[700]
                              : Colors.grey[400],
                      size: 22,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Scan QR',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            selectedIndex == 1
                                ? Colors.blue[700]
                                : Colors.grey[400],
                        fontWeight:
                            selectedIndex == 1
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 80),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.pushWithAd('/barcode_scanner');
              },
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.document_scanner,
                      color:
                          selectedIndex == 0
                              ? Colors.blue[700]
                              : Colors.grey[400],
                      size: 22,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Scan Barcode',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            selectedIndex == 0
                                ? Colors.blue[700]
                                : Colors.grey[400],
                        fontWeight:
                            selectedIndex == 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
