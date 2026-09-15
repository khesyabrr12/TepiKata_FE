import 'package:flutter/material.dart';
import 'package:frontend/saved_posts.dart';

class DetailPost extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailPost({super.key, required this.data});

  @override
  State<DetailPost> createState() => _DetailPostState();
}

class _DetailPostState extends State<DetailPost> {
  final savedPosts = SavedPosts.instance;

  @override
  Widget build(BuildContext context) {
    final isSaved = savedPosts.contains(widget.data);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F7F2),
        foregroundColor: const Color(0xFF244735),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'TepiKata',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF244735),
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              savedPosts.toggle(widget.data);
              setState(() {});
            },
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8ECE5),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Text(
                widget.data['name_category']?.toString() ?? 'Artikel',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF315C45),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              widget.data['title']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF244735),
              ),
            ),

            const SizedBox(height: 14),

            Image.network(
              widget.data['image']?.toString() ?? '',
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 220,
                  color: const Color(0xFFE7ECE3),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    size: 50,
                    color: Color(0xFF4F805B),
                  ),
                );
              },
            ),

            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Colors.grey,
                ),

                const SizedBox(width: 5),

                const Text(
                  '5 Desember',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                const Text(
                  '6 menit baca',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 26),

            Container(height: 1, color: const Color(0xFFE1E3DD)),

            const SizedBox(height: 28),
            Text(
              widget.data['post_text']?.toString() ?? '',
              style: const TextStyle(
                fontSize: 17,
                height: 1.75,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
