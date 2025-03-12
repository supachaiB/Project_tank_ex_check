import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Box3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('firetank_Collection')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('ไม่มีข้อมูล'));
            }

            // สร้างแผนที่เพื่อเก็บข้อมูลจำนวนสถานะ 'ตรวจสอบแล้ว' ในแต่ละอาคาร
            Map<String, Map<String, int>> buildingsStatus = {};

            for (var doc in snapshot.data!.docs) {
              String building = doc['building'] ?? '';
              String status = doc['status_technician'] ?? '';

              if (!buildingsStatus.containsKey(building)) {
                buildingsStatus[building] = {'checked': 0, 'total': 0};
              }

              buildingsStatus[building]!['total'] =
                  buildingsStatus[building]!['total']! + 1;

              if (status == 'ตรวจสอบแล้ว') {
                buildingsStatus[building]!['checked'] =
                    buildingsStatus[building]!['checked']! + 1;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'อาคารที่ตรวจสอบแล้ว',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                buildingsStatus.isEmpty
                    ? const Center(child: Text('ไม่มีอาคารที่มีข้อมูล'))
                    : ListView(
                        shrinkWrap: true,
                        children: buildingsStatus.entries.map((entry) {
                          String buildingName = entry.key;
                          int checked = entry.value['checked']!;
                          int total = entry.value['total']!;

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BuildingDetailPage(
                                    buildingName: buildingName,
                                  ),
                                ),
                              );
                            },
                            child: _buildingCard(buildingName, checked, total),
                          );
                        }).toList(),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildingCard(String buildingName, int checked, int total) {
    double percentage = total > 0 ? (checked / total) * 100 : 0;

    return Card(
      color: Colors.white,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(buildingName, style: const TextStyle(fontSize: 14)),
            Text(
              '$checked/$total ถัง (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class BuildingDetailPage extends StatelessWidget {
  final String buildingName;

  const BuildingDetailPage({Key? key, required this.buildingName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('อาคาร $buildingName')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('firetank_Collection')
              .where('building', isEqualTo: buildingName)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('ไม่มีข้อมูล'));
            }

            // สร้างแผนที่เก็บจำนวนถังดับเพลิงที่ตรวจสอบแล้วในแต่ละชั้น
            Map<int, Map<String, int>> floorStatus = {};

            for (var doc in snapshot.data!.docs) {
              String floorStr = doc['floor'] ?? '0';
              int floor = int.tryParse(floorStr) ?? 0; // แปลงชั้นเป็นตัวเลข
              String status = doc['status_technician'] ?? '';

              if (!floorStatus.containsKey(floor)) {
                floorStatus[floor] = {'checked': 0, 'total': 0};
              }

              floorStatus[floor]!['total'] = floorStatus[floor]!['total']! + 1;

              if (status == 'ตรวจสอบแล้ว') {
                floorStatus[floor]!['checked'] =
                    floorStatus[floor]!['checked']! + 1;
              }
            }

            // เรียงชั้นจาก ชั้น 1 ลงไปเรื่อยๆ
            List<int> sortedFloors = floorStatus.keys.toList();
            sortedFloors.sort();

            return ListView(
              children: sortedFloors.map((floor) {
                int checked = floorStatus[floor]!['checked']!;
                int total = floorStatus[floor]!['total']!;

                return Card(
                  color: Colors.white,
                  elevation: 3,
                  child: ListTile(
                    title: Text('ชั้น $floor'),
                    subtitle: Text('ตรวจสอบแล้ว: $checked/$total ถัง'),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
