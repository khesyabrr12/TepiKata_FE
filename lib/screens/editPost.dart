import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyEditPost extends StatefulWidget {
  final Map<String, dynamic> data;

  const MyEditPost({super.key, required this.data});

  @override
  State<MyEditPost> createState() => _MyEditPostState();
}

class _MyEditPostState extends State<MyEditPost> {
  final String baseUrl = 'http://10.0.2.2:3000/api/posts';
  final String categoriesUrl = 'http://10.0.2.2:3000/api/categories';

  late final TextEditingController titleController;
  late final TextEditingController textController;
  late final TextEditingController imageController;

  List<Map<String, dynamic>> categories = [];
  int? selectedCategoryId;
  bool isLoadingCategories = true;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(
      text: widget.data['title']?.toString() ?? '',
    );

    textController = TextEditingController(
      text: widget.data['post_text']?.toString() ?? '',
    );

    imageController = TextEditingController(
      text: widget.data['image']?.toString() ?? '',
    );

    selectedCategoryId = int.tryParse(
      widget.data['id_category']?.toString() ?? '',
    );
    getCategories();
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    imageController.dispose();
    super.dispose();
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
            categories = data
                .whereType<Map>()
                .map((category) {
                  return {
                    ...Map<String, dynamic>.from(category),
                    'id_category': int.tryParse(
                      category['id_category']?.toString() ?? '',
                    ),
                  };
                })
                .where((category) => category['id_category'] != null)
                .toList();
          });
        }
      }
    } catch (error) {
      debugPrint('ERROR GET CATEGORY: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingCategories = false;
        });
      }
    }
  }

  Future<void> updatePost() async {
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori artikel wajib dipilih')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final id = widget.data['id_post'];

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': titleController.text,
          'post_text': textController.text,
          'id_category': selectedCategoryId,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil di-update')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal update data')));
      }
    } catch (error) {
      debugPrint('ERROR UPDATE: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat update data')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6EE),

      appBar: AppBar(
        title: const Text('Edit Artikel'),
        backgroundColor: const Color(0xFF315C45),
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        children: [
          const Text(
            'Rawat ceritamu',
            style: TextStyle(
              color: Color(0xFF244735),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Perbarui tulisanmu agar tetap terasa hidup.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),

          const SizedBox(height: 22),

          // JUDUL
          TextField(
            controller: titleController,
            decoration: _fieldDecoration(labelText: 'Judul Artikel'),
          ),

          const SizedBox(height: 16),

          // ISI ARTIKEL
          TextField(
            controller: textController,
            maxLines: 5,
            decoration: _fieldDecoration(labelText: 'Isi Artikel'),
          ),

          const SizedBox(height: 16),

          // KATEGORI
          if (isLoadingCategories)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF315C45)),
              ),
            )
          else
            DropdownButtonFormField<int>(
              value:
                  categories.any(
                    (category) => category['id_category'] == selectedCategoryId,
                  )
                  ? selectedCategoryId
                  : null,
              decoration: _fieldDecoration(labelText: 'Kategori'),
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

          const SizedBox(height: 24),

          // BUTTON SIMPAN
          ElevatedButton(
            onPressed: isSaving ? null : updatePost,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F805B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({required String labelText}) {
    return InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD7E3D4)),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD7E3D4)),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4F805B), width: 2),
      ),
    );
  }
}
