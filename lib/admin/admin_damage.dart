import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminReportPage extends StatefulWidget {
  @override
  _AdminReportPageState createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการแจ้งชำรุด'),
        backgroundColor: Colors.redAccent,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // แก้ไขให้ใช้ QuerySnapshot
        stream: FirebaseFirestore.instance
            .collection('firetank_Collection')
            .where('status', isEqualTo: 'ชำรุด')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลการชำรุด'));
          }

          final damagedExtinguishers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: damagedExtinguishers.length,
            itemBuilder: (context, index) {
              var data =
                  damagedExtinguishers[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text('ถัง #${data['tank_id']} ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📍 อาคาร: ${data['building']} ชั้น ${data['floor']}',
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('form_checks')
                            .where('tank_id', isEqualTo: data['tank_id'])
                            .limit(1)
                            .snapshots(),
                        builder: (context, formSnapshot) {
                          if (formSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (formSnapshot.hasError) {
                            return const Text('เกิดข้อผิดพลาดในการโหลดข้อมูล');
                          }
                          if (!formSnapshot.hasData ||
                              formSnapshot.data!.docs.isEmpty) {
                            return const Text('ไม่มีข้อมูลการตรวจสอบ');
                          }

                          var formData = formSnapshot.data!.docs.first.data()
                              as Map<String, dynamic>;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('🔧 ประเภทถัง: ${data['type']}'),
                              Text('🔧 ส่วนที่ชำรุด : ${data['type']}'),
                              Text(
                                  '💬 หมายเหตุ: ${formData['remarks'] ?? 'ไม่มีข้อมูล'}'),
                              Text(
                                  '📅 การตรวจสอบเมื่อ: ${_formatDate(formData['date_checked'])}'),
                              // ดึงข้อมูลจาก field 'equipment_status'
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '📝 ผู้ตรวจสอบ: ${formData['inspector']}'),
                                  ElevatedButton(
                                    onPressed: () {
                                      _assignTechnician(data);
                                    },
                                    child: const Text(
                                      'แจ้งชำรุดหาช่าง',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent),
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
            },
          );
        },
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      return DateFormat('yyyy-MM-dd').format(date.toDate());
    } else if (date is String) {
      try {
        return DateFormat('yyyy-MM-dd').format(DateTime.parse(date));
      } catch (e) {
        return '-';
      }
    }
    return '-';
  }

  void _assignTechnician(Map<String, dynamic> data) {
    // บันทึกข้อมูลการแจ้งหาช่างใน Firestore ใน collection ใหม่ 'technician_requests'
    FirebaseFirestore.instance
        .collection('technician_requests')
        .doc(data['tank_id']) // ใช้ tank_id เป็น doc ID
        .set({
      'tank_id': data['tank_id'],
      'building': data['building'],
      'floor': data['floor'],
      'type': data['type'],
      'remarks': data['remarks'],
      'status': 'ไม่ปกติ',
      'inspector': data['inspector'],
      'timestamp': FieldValue.serverTimestamp(), // บันทึกเวลา
    }).then((_) {
      // แสดง Snackbar หลังจากการบันทึกข้อมูลสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'แจ้งสำเร็จ รอการอัปเดตเปลี่ยน,ซ่อม จาก ช่างเทคนิค หมายเลขถัง ${data['tank_id']}'),
        ),
      );
      // รีเฟรชหน้าจอหลังการแจ้ง
      setState(() {});
    }).catchError((error) {
      // หากเกิดข้อผิดพลาด แสดง Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $error'),
        ),
      );
    });
  }
}
