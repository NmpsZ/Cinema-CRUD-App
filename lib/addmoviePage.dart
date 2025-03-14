import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddMoviePage extends StatefulWidget {
  const AddMoviePage({super.key});

  @override
  _AddMoviePageState createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  Future<void> _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('Movies').add({
          'title': _titleController.text,
          'category': _categoryController.text,
          'duration': int.parse(_durationController.text),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('หนังถูกเพิ่มแล้ว')),
          );
          Navigator.pop(context); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Movie')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'ชื่อภาพยนตร์'),
                validator: (value) => value!.isEmpty ? 'กรุณากรอกชื่อภาพยนตร์' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'หมวดหมู่'),
                validator: (value) => value!.isEmpty ? 'กรุณากรอกหมวดหมู่' : null,
              ),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'ความยาว (นาที)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'กรุณากรอกความยาว';
                  if (int.tryParse(value) == null) return 'กรุณากรอกตัวเลข';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMovie,
                child: const Text('บันทึก'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}