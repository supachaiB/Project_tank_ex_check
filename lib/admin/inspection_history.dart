/*import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firecheck_setup/admin/fire_tank_status.dart';
import 'package:firecheck_setup/admin/inspection_section/filterWidget.dart';

class InspectionHistoryPage extends StatefulWidget {
  const InspectionHistoryPage({super.key});

  @override
  _InspectionHistoryPageState createState() => _InspectionHistoryPageState();
}

class _InspectionHistoryPageState extends State<InspectionHistoryPage> {
  String? selectedBuilding;
  String? selectedFloor;
  String? selectedStatus;
  String? sortBy = 'tank_number'; // เริ่มต้นการเรียงตามหมายเลขถัง
  bool isUserView = true; // true = ผู้ใช้ทั่วไป, false = ช่างเทคนิค
  bool get isTechnician =>
      !isUserView; // กำหนดให้ isTechnician ตรงข้ามกับ isUserView

  List<Map<String, dynamic>> combinedData = [];

  void _onBuildingChanged(String? value) {
    setState(() {
      selectedBuilding = value;
      selectedFloor = null; // รีเซ็ตชั้นเมื่อเลือกอาคารใหม่
    });
  }

  void _onFloorChanged(String? value) {
    setState(() {
      selectedFloor = value;
    });
  }

  void _onStatusChanged(String? value) {
    setState(() {
      selectedStatus = value;
    });
  }

  void _onReset() {
    setState(() {
      selectedBuilding = null;
      selectedFloor = null;
      selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // ปรับสีพื้นหลังนอก Container

      appBar: AppBar(
        title: const Text(
          'ประวัติการตรวจสอบ',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // จัดตำแหน่งกลาง
              children: [
                // ส่วนตัวกรอง
                FilterWidget(
                  selectedBuilding: selectedBuilding,
                  selectedFloor: selectedFloor,
                  selectedStatus: selectedStatus,
                  onBuildingChanged: _onBuildingChanged,
                  onFloorChanged: _onFloorChanged,
                  onStatusChanged: _onStatusChanged,
                  onReset: _onReset,
                ),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InspectionOverviewPage extends StatefulWidget {
  @override
  _InspectionOverviewPageState createState() => _InspectionOverviewPageState();
}

class _InspectionOverviewPageState extends State<InspectionOverviewPage> {
  String? selectedBuilding;
  String? selectedFloor;
  String? selectedStatus;

  Stream<QuerySnapshot> _getInspections() {
    Query query = FirebaseFirestore.instance.collection('firetank_Collection');

    if (selectedBuilding != null) {
      query = query.where('building', isEqualTo: selectedBuilding);
    }
    if (selectedFloor != null) {
      query = query.where('floor', isEqualTo: selectedFloor);
    }
    if (selectedStatus != null) {
      query = query.where('status_technician', isEqualTo: selectedStatus);
    }

    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📊 ประวัติการตรวจสอบ')),
      body: Column(
        children: [
          // 🔍 Filter Section
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'อาคาร'),
                    value: selectedBuilding,
                    items: ['OPD', 'อาคาร B', 'อาคาร C'] // แก้ไขให้ตรงกับ DB
                        .map((building) => DropdownMenuItem(
                            value: building, child: Text(building)))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => selectedBuilding = value),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'ชั้น'),
                    value: selectedFloor,
                    items: List.generate(11, (index) => index + 1)
                        .map((floor) => DropdownMenuItem(
                            value: '$floor', child: Text('ชั้น $floor')))
                        .toList(),
                    onChanged: (value) => setState(() => selectedFloor = value),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => setState(() {}),
                ),
              ],
            ),
          ),

          // 📊 Summary
          Container(
            padding: EdgeInsets.all(8.0),
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('firetank_Collection')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Text("Loading...");
                int totalTanks = snapshot.data!.docs.length;
                int damagedTanks = snapshot.data!.docs
                    .where((doc) => doc['status_technician'] == 'ชำรุด')
                    .length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📌 ถังทั้งหมด: $totalTanks'),
                    Text('🛑 ถังที่มีปัญหา: $damagedTanks'),
                  ],
                );
              },
            ),
          ),

          // 📋 ListView of FireTanks
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getInspections(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('ไม่พบข้อมูล'));
                }

                final fireTanks = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: fireTanks.length,
                  itemBuilder: (context, index) {
                    final data =
                        fireTanks[index].data() as Map<String, dynamic>;

                    String tankId = data['tank_id'];
                    String status = data['status_technician'] ?? 'ไม่มีข้อมูล';
                    String building = data['building'] ?? 'ไม่ระบุ';
                    String floor = data['floor'] ?? 'ไม่ระบุ';
                    String lastCheckedBy = data['last_checked_by'] ?? 'ไม่ระบุ';
                    String lastCheckedDate =
                        data['last_checked_date'] ?? 'ไม่ระบุ';

                    Color statusColor = status == 'ชำรุด'
                        ? Colors.red
                        : status == 'ส่งซ่อม'
                            ? Colors.orange
                            : Colors.green;

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading:
                            Icon(Icons.fire_extinguisher, color: statusColor),
                        title: Text('ถังดับเพลิง ID: $tankId'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📍 อาคาร: $building, ชั้น: $floor'),
                            Text('👤 ตรวจล่าสุดโดย: $lastCheckedBy'),
                            Text('📅 วันที่ตรวจล่าสุด: $lastCheckedDate'),
                            Row(
                              children: [
                                Icon(Icons.circle,
                                    color: statusColor, size: 12),
                                SizedBox(width: 5),
                                Text('สถานะ: $status'),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        /* onTap: () {
                          // เปิดหน้ารายละเอียด
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FireTankDetailPage(                                          tankId: widget.tankId,
),
                            ),
                          );
                        },*/
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FireTankDetailPage extends StatefulWidget {
  final String tankId;

  const FireTankDetailPage({Key? key, required this.tankId}) : super(key: key);

  @override
  _FireTankDetailPageState createState() => _FireTankDetailPageState();
}

class _FireTankDetailPageState extends State<FireTankDetailPage> {
  Map<String, dynamic>? tankData;
  List<Map<String, dynamic>> inspectionHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchTankData();
    _fetchInspectionHistory();
  }

  Future<void> _fetchTankData() async {
    try {
      DocumentSnapshot tankSnapshot = await FirebaseFirestore.instance
          .collection('firetank_Collection')
          .doc(widget.tankId)
          .get();

      if (tankSnapshot.exists) {
        setState(() {
          tankData = tankSnapshot.data() as Map<String, dynamic>;
        });
      }
    } catch (e) {
      print("Error fetching tank data: $e");
    }
  }

  Future<void> _fetchInspectionHistory() async {
    try {
      QuerySnapshot inspections = await FirebaseFirestore.instance
          .collection('form_checks')
          .where('tank_id', isEqualTo: widget.tankId)
          .orderBy('date_checked', descending: true)
          .orderBy('time_checked', descending: true)
          .get();

      setState(() {
        inspectionHistory = inspections.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Error fetching inspection history: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('📄 รายละเอียดถังดับเพลิง')),
      body: tankData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📍 อาคาร: ${tankData!['building']}, ชั้น: ${tankData!['floor']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('🆔 รหัสถัง: ${tankData!['tank_id']}'),
                  Text(
                      '👷‍♂️ ตรวจล่าสุดโดย: ${tankData!['last_checked_by'] ?? 'ไม่ระบุ'}'),
                  Text(
                      '📅 วันที่ตรวจล่าสุด: ${tankData!['last_checked_date'] ?? 'ไม่ระบุ'}'),
                  SizedBox(height: 10),
                  Text(
                    '📋 รายการตรวจสอบ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ...?tankData!['equipment_status']?.entries.map(
                        (entry) => ListTile(
                          title: Text(entry.key),
                          trailing: Text(entry.value == 'ปกติ' ? '✅' : '❌'),
                        ),
                      ),
                  SizedBox(height: 10),
                  if (tankData!['remarks'] != null)
                    Text('📝 หมายเหตุ: ${tankData!['remarks']}'),
                  SizedBox(height: 20),
                  Text(
                    '📜 ประวัติการตรวจสอบ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: inspectionHistory.length,
                      itemBuilder: (context, index) {
                        final history = inspectionHistory[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              'ตรวจสอบเมื่อ: ${history['date_checked']} ${history['time_checked']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('👤 ผู้ตรวจสอบ: ${history['inspector']}'),
                                Text('⚙️ ประเภท: ${history['user_type']}'),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: history['status_technician'] ==
                                              'ชำรุด'
                                          ? Colors.red
                                          : Colors.green,
                                      size: 12,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                        'สถานะ: ${history['status_technician']}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
