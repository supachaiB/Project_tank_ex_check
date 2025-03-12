import 'package:flutter/material.dart';
import 'package:firecheck_setup/admin/dashboard.dart';

class InspectionStatusBox extends StatelessWidget {
  final String title;
  final int checkedCount, uncheckedCount, brokenCount, repairCount, totalTanks;

  const InspectionStatusBox({
    Key? key,
    required this.title,
    required this.checkedCount,
    required this.uncheckedCount,
    required this.brokenCount,
    required this.repairCount,
    required this.totalTanks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(12.0),
      decoration: boxDecorationStyle(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title, // ใช้ title ที่ส่งเข้ามา
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            '$checkedCount / $totalTanks',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
