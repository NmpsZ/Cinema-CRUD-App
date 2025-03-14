import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cinema/models/movie_model.dart';

class EditMoviePage extends StatefulWidget {
  final String movieId;
  final Movies movie;

  const EditMoviePage({super.key, required this.movieId, required this.movie});

  @override
  _EditMoviePageState createState() => _EditMoviePageState();
}

class _EditMoviePageState extends State<EditMoviePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.movie.title);
    _categoryController = TextEditingController(text: widget.movie.category);
    _durationController = TextEditingController(text: widget.movie.duration.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _updateMovie() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('Movies').doc(widget.movieId).update({
          'title': _titleController.text,
          'category': _categoryController.text,
          'duration': int.parse(_durationController.text),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('หนังถูกแก้ไขแล้ว')),
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
      appBar: AppBar(title: const Text('Edit Movie')),
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
                onPressed: _updateMovie,
                child: const Text('บันทึกการแก้ไข'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}