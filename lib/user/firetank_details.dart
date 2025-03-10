import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // ใช้จัดรูปแบบวันที่

class FireTankDetailsPage extends StatefulWidget {
  final String tankId;

  const FireTankDetailsPage({Key? key, required this.tankId}) : super(key: key);

  @override
  _FireTankDetailsPageState createState() => _FireTankDetailsPageState();
}

class _FireTankDetailsPageState extends State<FireTankDetailsPage> {
  bool isTechnicianView = false; // สลับมุมมองระหว่างผู้ใช้ทั่วไปและช่างเทคนิค

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดการตรวจสอบ'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container 1 - รายละเอียดถังดับเพลิง
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('firetank_Collection')
                    .where('tank_id', isEqualTo: widget.tankId)
                    .limit(1)
                    .get()
                    .then((querySnapshot) => querySnapshot.docs.first),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('เกิดข้อผิดพลาด'));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                        child: Text('ไม่พบรายละเอียดถังดับเพลิง'));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'รายละเอียดถังดับเพลิง',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text('ถังดับเพลิง ID: ${data['tank_id']}'),
                      Text('ประเภท: ${data['type']}'),
                      Text('อาคาร: ${data['building']}'),
                      Text('ชั้น: ${data['floor']}'),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Container 2 - ประวัติการตรวจสอบ
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ประวัติการตรวจสอบ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('form_checks')
                        .where('tank_id', isEqualTo: widget.tankId)
                        .orderBy('date_checked', descending: true)
                        .orderBy('time_checked', descending: true)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('เกิดข้อผิดพลาด'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('ไม่พบประวัติการตรวจสอบ'));
                      }

                      final formChecks = snapshot.data!.docs;
                      int? currentMonth; // ใช้ตรวจสอบว่าเดือนเปลี่ยนไปหรือไม่

                      String timeAgo(String? dateStr) {
                        if (dateStr == null) return "ไม่มีข้อมูล";

                        DateTime now = DateTime.now();
                        DateTime date;

                        try {
                          date = DateFormat('yyyy-MM-dd').parse(dateStr);
                        } catch (e) {
                          return "รูปแบบวันที่ไม่ถูกต้อง";
                        }

                        Duration difference = now.difference(date);

                        if (difference.inDays >= 365) {
                          return "${(difference.inDays / 365).floor()} ปีที่แล้ว";
                        } else if (difference.inDays >= 30) {
                          return "${(difference.inDays / 30).floor()} เดือนที่แล้ว";
                        } else if (difference.inDays >= 7) {
                          return "${(difference.inDays / 7).floor()} สัปดาห์ที่แล้ว";
                        } else if (difference.inDays > 0) {
                          return "${difference.inDays} วันที่แล้ว";
                        } else {
                          return "วันนี้";
                        }
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: formChecks.length,
                        itemBuilder: (context, index) {
                          final checkData =
                              formChecks[index].data() as Map<String, dynamic>;

                          final dateChecked =
                              checkData['date_checked'] ?? 'ไม่มีข้อมูล';
                          final timeChecked = checkData['time_checked'] ?? '';
                          final inspector =
                              checkData['inspector'] ?? 'ไม่มีข้อมูล';
                          final userType = checkData['user_type'] ?? 'ไม่ระบุ';
                          final status = (userType == 'ช่างเทคนิค')
                              ? checkData['status_technician'] ?? 'ไม่มีข้อมูล'
                              : checkData['status'] ?? 'ไม่มีข้อมูล';

                          DateTime? parsedDate;
                          try {
                            parsedDate =
                                DateFormat('yyyy-MM-dd').parse(dateChecked);
                          } catch (e) {
                            parsedDate = null;
                          }

                          String monthLabel = "";
                          if (parsedDate != null) {
                            int month = parsedDate.month;
                            if (currentMonth != month) {
                              currentMonth = month;
                              monthLabel = timeAgo(
                                  dateChecked); // แสดงเฉพาะครั้งแรกของเดือนนั้น
                            }
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (monthLabel
                                  .isNotEmpty) // แสดงหัวข้อเดือนที่แล้วเฉพาะครั้งแรกของเดือนนั้น
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    monthLabel,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ),
                              Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'ตรวจสอบเมื่อ: $dateChecked $timeChecked'),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            userType,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text('ผู้ตรวจสอบ: $inspector'),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Text('สถานะ: '),
                                        if (status == 'ชำรุด') ...[
                                          const Icon(Icons.circle,
                                              color: Colors.red, size: 10),
                                          const SizedBox(width: 5),
                                          const Text('ชำรุด'),
                                        ] else if (status == 'ส่งซ่อม') ...[
                                          const Icon(Icons.circle,
                                              color: Colors.orange, size: 10),
                                          const SizedBox(width: 5),
                                          const Text('ส่งซ่อม'),
                                        ] else if (status == 'ตรวจสอบแล้ว') ...[
                                          const Icon(Icons.circle,
                                              color: Colors.green, size: 10),
                                          const SizedBox(width: 5),
                                          const Text('ตรวจสอบแล้ว'),
                                        ] else ...[
                                          const Icon(Icons.circle,
                                              color: Colors.grey, size: 10),
                                          const SizedBox(width: 5),
                                          const Text('ไม่มีข้อมูล'),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
