import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:frontend/screens/detailPost.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final String baseUrl = 'http://10.0.2.2:3000/api/posts';
  final String categoriesUrl = 'http://10.0.2.2:3000/api/categories';
  List<Map<String, dynamic>> categories = [];
  int? selectedCategoryId;
  List<Map<String, dynamic>> blogs = [];
  bool isLoading = true;

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
      if (response.statusCode != 200) {
        return;
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is! List) {
        return;
      }
      if (!mounted) return;
      setState(() {
        blogs = data.whereType<Map<String, dynamic>>().toList();
        isLoading = false;
      });
    } catch (error) {
      debugPrint('ERROR GET: $error');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredBlogs {
    if (selectedCategoryId == null) {
      return blogs;
    }

    return blogs.where((blog) {
      return int.tryParse(blog['id_category'].toString()) == selectedCategoryId;
    }).toList();
  }

  void openDetail(Map<String, dynamic> blog) {
    Navigator.push(
      context,

      MaterialPageRoute(builder: (context) => DetailPost(data: blog)),
    );
  }

  @override
  void initState() {
    super.initState();
    getDataBlog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6EE),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: getDataBlog,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              const Text(
                'Jelajah',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF244735),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Temukan tulisan yang mungkin kamu suka.',

                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 22),

              const Text(
                'TOPIK',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF315C45),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 38,
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
                        backgroundColor: Colors.white,
                        side: BorderSide.none,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF315C45),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tulisan Terbaru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF244735),
                    ),
                  ),

                  Text(
                    '${filteredBlogs.length} tulisan',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF315C45)),
                  ),
                )
              else if (filteredBlogs.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 45,
                          color: Colors.grey,
                        ),

                        SizedBox(height: 10),

                        Text(
                          'Belum ada tulisan di kategori ini.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filteredBlogs.map((blog) => _articleCard(blog)),
            ],
          ),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: const Color(0xFFE7ECE3),
                borderRadius: BorderRadius.circular(12),
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
                  Text(
                    blog['name_category']?.toString() ?? 'Artikel',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4F805B),
                    ),
                  ),

                  const SizedBox(height: 5),

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

                  const SizedBox(height: 5),
                  Text(
                    blog['post_text']?.toString() ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: Color(0xFF4F805B),
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
