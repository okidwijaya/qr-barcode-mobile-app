import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../widget/home_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.qr_code_scanner, color: Colors.white, size: 28),
            ),
            SizedBox(width: 12),
            Text(
              'ScanMaster',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                Get.snackbar(
                  'Account',
                  'Profile page coming soon',
                  snackPosition: SnackPosition.TOP,
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, color: Colors.blue[700]),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final currentState = controller.state.value;

        if (currentState.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue[700],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderSection(itemCount: currentState.scanHistory.length),
            Expanded(
              child: currentState.scanHistory.isEmpty
                  ? EmptyStateWidget()
                  : ScanHistoryList(
                      items: currentState.scanHistory,
                      controller: controller,
                    ),
            ),
          ],
        );
      }),
      floatingActionButton: SpeedDialFAB(controller: controller),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(() => CustomBottomNavBar(
            selectedIndex: controller.state.value.selectedNavIndex,
            onTap: controller.onBottomNavTap,
          )),
    );
  }
}