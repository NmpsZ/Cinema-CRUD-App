import 'package:cinema/addmoviePage.dart';
import 'package:cinema/editmoviePage.dart';
import 'package:cinema/models/movie_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movies App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const MoviesListPage(),
    );
  }
}

class MoviesListPage extends StatelessWidget {
  const MoviesListPage({super.key});

  Future<void> _deleteMovie(String movieId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance.collection('Movies').doc(movieId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบภาพยนตร์สำเร็จ!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies List',style: TextStyle(color: Colors.black),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Movies').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No movies available',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          var movieDocs = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: movieDocs.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              var doc = movieDocs[index];
              if (!doc.exists || doc.data() == null) {
                return const Center(child: Text('ข้อมูลภาพยนตร์ไม่ถูกต้อง'));
              }
              var movie = Movies.fromSnapshot(doc);
              String docId = doc.id;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                tileColor: const Color.fromARGB(255, 255, 255, 255),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Text(
                ("Movie Name :${movie.title}"),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold ,color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                subtitle: Text('Time : ${movie.duration} นาที', style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color.fromARGB(255, 15, 15, 15)),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EditMoviePage(movieId: docId, movie: movie),
                        ));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteMovie(docId, context),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddMoviePage(),
          ));
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
