import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/detailPost.dart';
import 'package:frontend/screens/editPost.dart';
import 'package:frontend/saved_posts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final savedPosts = SavedPosts.instance;
  final List<Map<String, dynamic>> blogs = [];

  final String baseUrl = 'http://10.0.2.2:3000/api/posts';
  final String categoriesUrl = 'http://10.0.2.2:3000/api/categories';
  List<Map<String, dynamic>> categories = [];

  int? selectedCategoryId;
  List<Map<String, dynamic>> get filteredBlogs {
    if (selectedCategoryId == null) {
      return blogs;
    }

    return blogs.where((blog) {
      return int.tryParse(blog['id_category'].toString()) == selectedCategoryId;
    }).toList();
  }

  Future<void> getCategories() async {
    try {
      final response = await http.get(Uri.parse(categoriesUrl));
      if (response.statusCode != 200 || !mounted) return;
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is! List) return;
      setState(() {
        categories = data.whereType<Map<String, dynamic>>().toList();
      });
    } catch (error) {
      debugPrint('ERROR GET CATEGORY: $error');
    }
  }

  Future<void> getDataBlog() async {
    try {
      await getCategories();
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode != 200 || !mounted) {
        return;
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is! List) {
        return;
      }

      setState(() {
        blogs
          ..clear()
          ..addAll(data.whereType<Map<String, dynamic>>());
      });
    } catch (error) {
      debugPrint('ERROR GET: $error');
    }
  }

  void openDetail(Map<String, dynamic> blog) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPost(data: blog)),
    );
  }

  Future<void> deleteBlog(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          blogs.removeWhere((blog) => blog['id_post'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel berhasil dihapus')),
        );
      }
    } catch (error) {
      debugPrint('ERROR DELETE: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    getDataBlog();
  }

  @override
  Widget build(BuildContext context) {
    final articles = filteredBlogs;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6EE),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: getDataBlog,

          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDEBDC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          size: 18,
                          color: Color(0xFF315C45),
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        'TepiKata',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF315C45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              const Text(
                'Selamat pagi, Almira.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF244735),
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'Luangkan sejenak untuk membaca dan menemukan sesuatu yang bermakna.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE4E7DE)),
                ),

                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '“',
                      style: TextStyle(fontSize: 28, color: Color(0xFF4F805B)),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Di tepi kata, kita menemukan apa yang tak sempat terucap.',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF315C45),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PILIHAN KAMI',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF315C45),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              if (articles.isNotEmpty) _featuredArticle(articles.first),

              const SizedBox(height: 20),

              const Text(
                'TELUSURI TIAP KATA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF315C45),
                ),
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 36,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length + 1,

                  itemBuilder: (context, index) {
                    final category = index == 0
                        ? null
                        : categories[index - 1]['id_category'];
                    final categoryName = index == 0
                        ? 'Semua'
                        : categories[index - 1]['name_category'].toString();

                    final isSelected = category == selectedCategoryId;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),

                      child: ChoiceChip(
                        label: Text(categoryName),

                        selected: isSelected,

                        onSelected: (_) {
                          setState(() {
                            selectedCategoryId = category is int
                                ? category
                                : int.tryParse(category.toString());
                          });
                        },

                        selectedColor: const Color(0xFF4F805B),

                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF315C45),
                          fontSize: 11,
                        ),

                        backgroundColor: Colors.white,

                        side: BorderSide.none,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tulisan Terhangat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF244735),
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lihat Semua ›',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              if (articles.length > 1)
                ...articles.skip(1).map((blog) => _articleCard(blog)),

              if (articles.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'Belum ada artikel di kategori ini.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featuredArticle(Map<String, dynamic> blog) {
    return GestureDetector(
      onTap: () {
        openDetail(blog);
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,

              width: double.infinity,

              decoration: BoxDecoration(
                color: const Color(0xFFE7ECE3),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),

              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  blog['image']?.toString() ?? '',
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      size: 45,
                      color: Color(0xFF4F805B),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(14),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        blog['name_category']?.toString() ?? 'Artikel',

                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF4F805B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    blog['title']?.toString() ?? '',

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF244735),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    blog['post_text']?.toString() ?? '',

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.4,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyEditPost(data: blog),
                            ),
                          );

                          getDataBlog();
                        },

                        padding: EdgeInsets.zero,

                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),

                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: Color(0xFF315C45),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          final id = blog['id_post'];

                          if (id is int) {
                            deleteBlog(id);
                          }
                        },

                        padding: EdgeInsets.zero,

                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),

                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          setState(() {
                            savedPosts.toggle(blog);
                          });
                        },

                        padding: EdgeInsets.zero,

                        constraints: const BoxConstraints(
                          minWidth: 30,
                          minHeight: 30,
                        ),

                        icon: Icon(
                          savedPosts.contains(blog)
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 18,
                          color: Color(0xFF315C45),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _articleCard(Map<String, dynamic> blog) {
    return GestureDetector(
      onTap: () {
        openDetail(blog);
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFE7ECE3),
                borderRadius: BorderRadius.circular(10),
              ),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  blog['image']?.toString() ?? '',
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      size: 45,
                      color: Color(0xFF4F805B),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // KATEGORI + WAKTU
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        blog['name_category']?.toString() ?? 'Artikel',

                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF4F805B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Text(
                    blog['title']?.toString() ?? '',

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF244735),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // PREVIEW
                  Text(
                    blog['post_text']?.toString() ?? '',

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.3,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyEditPost(data: blog),
                            ),
                          );

                          getDataBlog();
                        },

                        padding: EdgeInsets.zero,

                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),

                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 17,
                          color: Color(0xFF315C45),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          final id = blog['id_post'];

                          if (id is int) {
                            deleteBlog(id);
                          }
                        },

                        padding: EdgeInsets.zero,

                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),

                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 17,
                          color: Colors.redAccent,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          setState(() {
                            savedPosts.toggle(blog);
                          });
                        },

                        padding: EdgeInsets.zero,

                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),

                        icon: Icon(
                          savedPosts.contains(blog)
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 17,
                          color: Color(0xFF315C45),
                        ),
                      ),
                    ],
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
