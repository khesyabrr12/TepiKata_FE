import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/categories.dart';

class AddArticelPage extends StatefulWidget {
  const AddArticelPage({super.key});

  @override
  State<AddArticelPage> createState() => _AddArticelPageState();
}

class _AddArticelPageState extends State<AddArticelPage> {
  final titleController = TextEditingController();
  final textController = TextEditingController();
  final imageController = TextEditingController();

  final String postsUrl = 'http://10.0.2.2:3000/api/posts';
  final String categoriesUrl = 'http://10.0.2.2:3000/api/categories';

  List<Map<String, dynamic>> categories = [];

  int? selectedCategoryId;

  bool isLoadingCategory = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  int? parseCategoryId(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  List<Map<String, dynamic>> normalizeCategories(List data) {
    final categoriesById = <int, Map<String, dynamic>>{};

    for (final item in data.whereType<Map>()) {
      final id = parseCategoryId(item['id_category']);
      if (id == null) continue;

      categoriesById[id] = {
        ...Map<String, dynamic>.from(item),
        'id_category': id,
      };
    }

    return categoriesById.values.toList();
  }

  Future<void> getCategories() async {
    try {
      final response = await http.get(Uri.parse(categoriesUrl));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;

        final data = decoded['data'];

        if (data is List) {
          setState(() {
            categories = normalizeCategories(data);

            isLoadingCategory = false;
          });
        } else {
          setState(() {
            isLoadingCategory = false;
          });
        }
      } else {
        setState(() {
          isLoadingCategory = false;
        });
      }
    } catch (error) {
      debugPrint('ERROR GET CATEGORY: $error');

      if (!mounted) return;

      setState(() {
        isLoadingCategory = false;
      });
    }
  }

  Future<void> openCategoryPage() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CategoriesPage()));

    if (!mounted) return;
    setState(() {
      isLoadingCategory = true;
    });
    await getCategories();
  }

  Future<void> addArticel() async {
    if (titleController.text.trim().isEmpty ||
        textController.text.trim().isEmpty ||
        selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul, kategori, dan isi artikel wajib diisi!'),
        ),
      );

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final response = await http.post(
        Uri.parse(postsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_category': selectedCategoryId,
          'title': titleController.text.trim(),
          'post_text': textController.text.trim(),
          if (imageController.text.trim().isNotEmpty)
            'image': imageController.text.trim(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil menyimpan artikel!'),
            backgroundColor: Color(0xFF315C45),
          ),
        );

        titleController.clear();
        textController.clear();
        imageController.clear();
        setState(() {
          selectedCategoryId = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    } catch (error) {
      debugPrint('ERROR ADD ARTICLE: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error koneksi: $error')));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validSelectedCategoryId =
        categories.any(
          (category) => category['id_category'] == selectedCategoryId,
        )
        ? selectedCategoryId
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6EE),

      appBar: AppBar(
        title: const Text(
          'Tulis Artikel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF315C45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Bagikan Ceritamu',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF244735),
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Tulis sesuatu yang ingin kamu bagikan kepada pembaca TepiKata.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),

          const SizedBox(height: 28),

          const Text(
            'Judul Artikel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF244735),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: titleController,
            textInputAction: TextInputAction.next,
            decoration: _fieldDecoration(
              hintText: 'Masukkan judul artikel...',
              icon: Icons.title,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Kategori',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF244735),
            ),
          ),

          const SizedBox(height: 8),

          if (isLoadingCategory)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF315C45),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Memuat kategori...'),
                ],
              ),
            )
          else
            DropdownButtonFormField<int>(
              value: validSelectedCategoryId,

              decoration: _fieldDecoration(
                hintText: 'Pilih kategori artikel',
                icon: Icons.category_outlined,
              ),

              items: categories.map((category) {
                return DropdownMenuItem<int>(
                  value: category['id_category'] as int,
                  child: Text(category['name_category'].toString()),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                });
              },
            ),

          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: openCategoryPage,
              icon: const Icon(Icons.add),
              label: const Text('Kelola kategori'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF315C45),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'URL Gambar (Opsional)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF244735),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: imageController,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            decoration: _fieldDecoration(
              hintText: 'Tambahkan Gambar URL',
              icon: Icons.image_outlined,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Isi Artikel',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF244735),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: textController,
            maxLines: 12,
            textAlignVertical: TextAlignVertical.top,
            decoration: _fieldDecoration(
              hintText: 'Mulai tulis artikel kamu di sini...',
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isSaving ? null : addArticel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF315C45),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isSaving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded),
                        SizedBox(width: 8),
                        Text(
                          'Publikasikan Artikel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hintText, IconData? icon}) {
    return InputDecoration(
      hintText: hintText,

      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF315C45))
          : null,

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF315C45), width: 1.5),
      ),
    );
  }
}
