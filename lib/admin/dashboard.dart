import 'package:flutter/material.dart';
//import 'package:firecheck_setup/admin/dashboard_section/damage_info_section.dart';
import 'package:firecheck_setup/admin/inspection_section/scheduleBox.dart';
import 'package:firecheck_setup/admin/fire_tank_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:firecheck_setup/admin/dashboard_section/fire_tank_box.dart';
import 'package:firecheck_setup/admin/dashboard_section/inspection_status_box.dart';
import 'package:firecheck_setup/admin/dashboard_section/technician_status_box.dart';
//import 'package:firecheck_setup/admin/dashboard_section/damage_info_section.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int remainingTimeInSeconds = FireTankStatusPageState.calculateRemainingTime();
  int remainingQuarterTimeInSeconds =
      FireTankStatusPageState.calculateNextQuarterEnd()
          .difference(DateTime.now())
          .inSeconds;

  int totalTanks = 0;
  int checkedCount = 0;
  int brokenCount = 0;
  int repairCount = 0;
  int otherCount = 0;
  int uncheckedCount = 0;

  // ตัวแปรสำหรับ status_technician
  int checkedTechnicianCount = 0;
  int uncheckedTechnicianCount = 0;
  int brokenTechnicianCount = 0;
  int repairTechnicianCount = 0;

  // ดึงข้อมูลจาก Firestore
  void _fetchFireTankData() async {
    final totalSnapshot = await FirebaseFirestore.instance
        .collection('firetank_Collection')
        .get();
    totalTanks = totalSnapshot.size;

    final checkedSnapshot = await FirebaseFirestore.instance
        .collection('firetank_Collection')
        .where('status', isEqualTo: 'ตรวจสอบแล้ว')
        .get();
    checkedCount = checkedSnapshot.size;

    final brokenSnapshot = await FirebaseFirestore.instance
        .collection('firetank_Collection')
        .where('status', isEqualTo: 'ชำรุด')
        .get();
    brokenCount = brokenSnapshot.size;

    final repairSnapshot = await FirebaseFirestore.instance
        .collection('firetank_Collection')
        .where('status', isEqualTo: 'ส่งซ่อม')
        .get();
    repairCount = repairSnapshot.size;

    final uncheckedSnapshot = await FirebaseFirestore.instance
        .collection('firetank_Collection')
        .where('status', isEqualTo: 'ยังไม่ตรวจสอบ')
        .get();
    uncheckedCount = uncheckedSnapshot.size;

    // ดึงข้อมูลสำหรับ status_technician
    final checkedTechnicianSnapshot = await FirebaseFirestore.instance
        .collection('firetank_Collection')
        .where('status_technician', isEqualTo: 'ตรวจสอบแล้ว')
        .get();
    checkedTechnicianCount = checkedTechnicianSnapshot.size;

    final uncheckedTechnicianSnapshot = await FirebaseFirestore.instance
        .collection('firetank_Collection')
        .where('status_technician', isEqualTo: 'ยังไม่ตรวจสอบ')
        .get();
    uncheckedTechnicianCount = uncheckedTechnicianSnapshot.size;

    final brokenTechnicianSnapshot = await FirebaseFirestore.instance
        .collection('firetank_Collection')
        .where('status_technician', isEqualTo: 'ชำรุด')
        .get();
    brokenTechnicianCount = brokenTechnicianSnapshot.size;

    final repairTechnicianSnapshot = await FirebaseFirestore.instance
        .collection('firetank_Collection')
        .where('status_technician', isEqualTo: 'ส่งซ่อม')
        .get();
    repairTechnicianCount = repairTechnicianSnapshot.size;

    setState(() {}); // อัปเดตข้อมูลหลังจากดึงข้อมูลมา
  }

  @override
  void initState() {
    super.initState();
    _fetchFireTankData(); // ดึงข้อมูลเมื่อหน้าเริ่มต้น
  }

  @override
  Widget build(BuildContext context) {
    double totalStatus =
        (checkedCount + brokenCount + repairCount + uncheckedCount).toDouble();
    double checkedPercentage = (checkedCount / totalStatus) * 100;
    double brokenPercentage = (brokenCount / totalStatus) * 100;
    double repairPercentage = (repairCount / totalStatus) * 100;
    double uncheckedPercentage = (uncheckedCount / totalStatus) * 100;

    double totalTechnicianStatus = (checkedTechnicianCount +
            brokenTechnicianCount +
            repairTechnicianCount +
            uncheckedTechnicianCount)
        .toDouble();
    double checkedTechnicianPercentage =
        (checkedTechnicianCount / totalTechnicianStatus) * 100;
    double brokenTechnicianPercentage =
        (brokenTechnicianCount / totalTechnicianStatus) * 100;
    double repairTechnicianPercentage =
        (repairTechnicianCount / totalTechnicianStatus) * 100;
    double uncheckedTechnicianPercentage =
        (uncheckedTechnicianCount / totalTechnicianStatus) * 100;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScheduleBox(
              remainingTimeInSeconds: remainingTimeInSeconds,
              remainingQuarterTimeInSeconds: remainingQuarterTimeInSeconds,
            ),
            const SizedBox(height: 10),

            // แถวของ 3 กล่อง
            Row(
              children: [
                // ใช้ LayoutBuilder เพื่อปรับการแสดงผลตามขนาดหน้าจอ
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // หากความกว้างของหน้าจอน้อยกว่า 600px ให้ใช้ Column แทน Row
                      if (constraints.maxWidth < 600) {
                        return Column(
                          children: [
                            FireTankBox(totalTanks: totalTanks),
                            const SizedBox(height: 16),
                            InspectionStatusBox(
                                checkedCount: checkedCount,
                                uncheckedCount: uncheckedCount,
                                brokenCount: brokenCount,
                                repairCount: repairCount,
                                totalTanks: totalTanks),
                            const SizedBox(height: 16),
                            TechnicianStatusBox(
                                checkedCount: checkedTechnicianCount,
                                uncheckedCount: uncheckedTechnicianCount,
                                brokenCount: brokenTechnicianCount,
                                repairCount: repairTechnicianCount,
                                totalTanks: totalTanks),
                          ],
                        );
                      } else {
                        // ถ้าหน้าจอมีขนาดกว้างกว่า 600px ให้ใช้ Row เหมือนเดิม
                        return Row(
                          children: [
                            Expanded(
                                child: FireTankBox(totalTanks: totalTanks)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: InspectionStatusBox(
                                    checkedCount: checkedCount,
                                    uncheckedCount: uncheckedCount,
                                    brokenCount: brokenCount,
                                    repairCount: repairCount,
                                    totalTanks: totalTanks)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: TechnicianStatusBox(
                                    checkedCount: checkedTechnicianCount,
                                    uncheckedCount: uncheckedTechnicianCount,
                                    brokenCount: brokenTechnicianCount,
                                    repairCount: repairTechnicianCount,
                                    totalTanks: totalTanks)),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // กล่อง  (ข้อมูลสถานะทั้งหมด)
            /*   */

            LayoutBuilder(
              builder: (context, constraints) {
                bool isSmallScreen =
                    constraints.maxWidth < 600; // ปรับตามขนาดหน้าจอที่ต้องการ
                return Column(
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        SizedBox(
                          width: isSmallScreen
                              ? constraints.maxWidth
                              : constraints.maxWidth / 2 - 16,
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: boxDecorationStyle(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'การตรวจสอบผู้ใช้ทั่วไปในเดือนนี้',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                AspectRatio(
                                  aspectRatio: 1.5,
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value: checkedCount.toDouble(),
                                          title:
                                              '${checkedPercentage.toStringAsFixed(1)}%',
                                          color: Colors.green,
                                          radius: 50,
                                        ),
                                        PieChartSectionData(
                                          value: brokenCount.toDouble(),
                                          title:
                                              '${brokenPercentage.toStringAsFixed(1)}%',
                                          color: Colors.red,
                                          radius: 50,
                                        ),
                                        PieChartSectionData(
                                          value: repairCount.toDouble(),
                                          title:
                                              '${repairPercentage.toStringAsFixed(1)}%',
                                          color: Colors.orange,
                                          radius: 50,
                                        ),
                                        PieChartSectionData(
                                          value: uncheckedCount.toDouble(),
                                          title:
                                              '${uncheckedPercentage.toStringAsFixed(1)}%',
                                          color: Colors.grey,
                                          radius: 50,
                                        ),
                                      ],
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  children: const [
                                    LegendItem(
                                        color: Colors.green,
                                        text: 'ตรวจสอบแล้ว'),
                                    LegendItem(
                                        color: Colors.red, text: 'ชำรุด'),
                                    LegendItem(
                                        color: Colors.orange, text: 'ส่งซ่อม'),
                                    LegendItem(
                                        color: Colors.grey,
                                        text: 'ยังไม่ตรวจสอบ'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: isSmallScreen
                              ? constraints.maxWidth
                              : constraints.maxWidth / 2 - 16,
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: boxDecorationStyle(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'การตรวจสอบช่างเทคนิคในไตรมาสนี้',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                AspectRatio(
                                  aspectRatio: 1.5,
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value:
                                              checkedTechnicianCount.toDouble(),
                                          title:
                                              '${checkedTechnicianPercentage.toStringAsFixed(1)}%',
                                          color: Colors.green,
                                          radius: 50,
                                        ),
                                        PieChartSectionData(
                                          value:
                                              brokenTechnicianCount.toDouble(),
                                          title:
                                              '${brokenTechnicianPercentage.toStringAsFixed(1)}%',
                                          color: Colors.red,
                                          radius: 50,
                                        ),
                                        PieChartSectionData(
                                          value:
                                              repairTechnicianCount.toDouble(),
                                          title:
                                              '${repairTechnicianPercentage.toStringAsFixed(1)}%',
                                          color: Colors.orange,
                                          radius: 50,
                                        ),
                                        PieChartSectionData(
                                          value: uncheckedTechnicianCount
                                              .toDouble(),
                                          title:
                                              '${uncheckedTechnicianPercentage.toStringAsFixed(1)}%',
                                          color: Colors.grey,
                                          radius: 50,
                                        ),
                                      ],
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  children: const [
                                    LegendItem(
                                        color: Colors.green,
                                        text: 'ตรวจสอบแล้ว'),
                                    LegendItem(
                                        color: Colors.red, text: 'ชำรุด'),
                                    LegendItem(
                                        color: Colors.orange, text: 'ส่งซ่อม'),
                                    LegendItem(
                                        color: Colors.grey,
                                        text: 'ยังไม่ตรวจสอบ'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// สร้างฟังก์ชันสำหรับตกแต่งกล่อง
BoxDecoration boxDecorationStyle() {
  return BoxDecoration(
    color: Colors.white,
    border: Border.all(color: Colors.grey[350]!, width: 1.5), // ขอบสีเทา
    borderRadius: BorderRadius.circular(8), // มุมโค้ง
  );
}

Widget _buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.grey[850], // เปลี่ยนเป็นสีเทาเข้ม
          ),
          child: Text(
            'เมนู',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dashboard),
          title: const Text('Dashboard'),
          onTap: () {
            Navigator.pushNamed(context, '/');
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('ประวัติการตรวจสอบ'),
          onTap: () {
            Navigator.pushNamed(context, '/inspectionhistory');
          },
        ),
        ListTile(
          leading: const Icon(Icons.report_problem),
          title: const Text('แจ้งซ่อม'),
          onTap: () {
            Navigator.pushNamed(context, '/AdminReport');
          },
        ),
        ListTile(
          leading: const Icon(Icons.update), // อัปเดตสถานะ
          title: const Text('การอัปเดตสถานะ'),
        ),
        ListTile(
          leading: const Icon(Icons.manage_accounts), // จัดการผู้ใช้งาน
          title: const Text('จัดการผู้ใช้งาน'),
        ),
        ListTile(
          leading: const Icon(Icons.build), // จัดการถังดับเพลิง
          title: const Text('การจัดการถังดับเพลิง'),
          onTap: () {
            Navigator.pushNamed(context, '/fire_tank_management');
          },
        ),
        ListTile(
          leading: const Icon(Icons.apartment), // จัดการอาคาร
          title: const Text('การจัดการอาคาร'),
          onTap: () {
            Navigator.pushNamed(context, '/BuildingManagement');
          },
        ),
        ListTile(
          leading: const Icon(Icons.local_fire_department), // ประเภทถังดับเพลิง
          title: const Text('ประเภทถังดับเพลิง'),
          onTap: () {
            Navigator.pushNamed(context, '/FireTankTypes');
          },
        ),
        ListTile(
            leading: const Icon(Icons.settings), // ตั้งค่า
            title: const Text('ตั้งค่า'),
            onTap: () {
              Navigator.pushNamed(context, '/Settings');
            }),
        ListTile(
          leading: const Icon(Icons.logout), // ออกจากระบบ
          title: const Text('ออกจากระบบ'),
        ),

        /*ListTile(
            leading: const Icon(Icons.check_circle),
            title: const Text('ตรวจสอบสถานะถัง'),
            onTap: () {
              Navigator.pushNamed(context, '/firetankstatus');
            },
          ),*/
        const Divider(),
      ],
    ),
  );
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
