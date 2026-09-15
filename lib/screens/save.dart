import 'package:flutter/material.dart';
import 'package:frontend/saved_posts.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  final savedPosts = SavedPosts.instance;

  @override
  void initState() {
    super.initState();
    savedPosts.addListener(_refresh);
  }

  @override
  void dispose() {
    savedPosts.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final posts = savedPosts.posts;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6EE),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          children: [
            const Text(
              'Tersimpan',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF244735),
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Tulisan yang kamu simpan ada di sini.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            if (posts.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      size: 55,
                      color: Color(0xFF4F805B),
                    ),

                    SizedBox(height: 14),

                    Text(
                      'Kamu belum menyimpan tulisan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF244735),
                      ),
                    ),

                    SizedBox(height: 6),

                    Text(
                      'Simpan tulisan yang kamu suka untuk dibaca lagi nanti.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ...posts.map(
                (post) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      post['title']?.toString() ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      post['name_category']?.toString() ?? 'Artikel',
                    ),
                    trailing: IconButton(
                      tooltip: 'Hapus dari tersimpan',
                      icon: const Icon(Icons.bookmark_rounded),
                      onPressed: () {
                        savedPosts.toggle(post);
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
