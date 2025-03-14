import 'package:cloud_firestore/cloud_firestore.dart';

class Movies {
  String title;
  String category;
  int duration;

  Movies({
    required this.title,
    required this.category,
    required this.duration,
  });

  // แปลง Object เป็น Map (สำหรับบันทึกลง Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'duration': duration,
    };
  }

  // สร้าง Object จาก Firestore Snapshot โดยไม่เก็บ ID
  factory Movies.fromSnapshot(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return Movies(
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      duration: data['duration'] ?? 0,
    );
  }
}
