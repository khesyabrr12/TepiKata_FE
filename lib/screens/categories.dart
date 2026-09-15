import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  static const categoriesUrl = 'http://10.0.2.2:3000/api/categories';

  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final response = await http.get(Uri.parse(categoriesUrl));
      if (!mounted) return;

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = decoded['data'];
        setState(() {
          categories = data is List
              ? data.whereType<Map>().map((item) {
                  return Map<String, dynamic>.from(item);
                }).toList()
              : [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        showMessage('Gagal memuat kategori');
      }
    } catch (error) {
      debugPrint('ERROR GET CATEGORY: $error');
      if (!mounted) return;
      setState(() => isLoading = false);
      showMessage('Tidak dapat terhubung ke server');
    }
  }

  Future<void> addCategory() async {
    final name = await showCategoryDialog(title: 'Tambah kategori');
    if (name == null) return;

    try {
      final response = await http.post(
        Uri.parse(categoriesUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name_category': name}),
      );
      if (!mounted) return;

      if (response.statusCode == 201) {
        await loadCategories();
        showMessage('Kategori berhasil ditambahkan');
      } else {
        showMessage('Gagal menambah kategori');
      }
    } catch (error) {
      debugPrint('ERROR ADD CATEGORY: $error');
      if (mounted) showMessage('Tidak dapat terhubung ke server');
    }
  }

  Future<void> editCategory(Map<String, dynamic> category) async {
    final name = await showCategoryDialog(
      title: 'Edit kategori',
      initialValue: category['name_category']?.toString() ?? '',
    );
    if (name == null) return;

    try {
      final response = await http.put(
        Uri.parse('$categoriesUrl/${category['id_category']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name_category': name}),
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        await loadCategories();
        showMessage('Kategori berhasil diperbarui');
      } else {
        showMessage('Gagal mengedit kategori');
      }
    } catch (error) {
      debugPrint('ERROR EDIT CATEGORY: $error');
      if (mounted) showMessage('Tidak dapat terhubung ke server');
    }
  }

  Future<void> deleteCategory(Map<String, dynamic> category) async {
    final name = category['name_category']?.toString() ?? 'kategori ini';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus kategori?'),
        content: Text('Kategori "$name" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final response = await http.delete(
        Uri.parse('$categoriesUrl/${category['id_category']}'),
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        await loadCategories();
        showMessage('Kategori berhasil dihapus');
      } else {
        showMessage(
          'Kategori tidak dapat dihapus. Mungkin masih dipakai artikel.',
        );
      }
    } catch (error) {
      debugPrint('ERROR DELETE CATEGORY: $error');
      if (mounted) showMessage('Tidak dapat terhubung ke server');
    }
  }

  Future<String?> showCategoryDialog({
    required String title,
    String initialValue = '',
  }) async {
    return showDialog<String>(
      context: context,
      builder: (_) => _CategoryDialog(title: title, initialValue: initialValue),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6EE),
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        backgroundColor: const Color(0xFF315C45),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addCategory,
        backgroundColor: const Color(0xFF315C45),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah kategori'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? const Center(child: Text('Belum ada kategori'))
          : RefreshIndicator(
              onRefresh: loadCategories,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFDCE9DD),
                        child: Icon(
                          Icons.category_outlined,
                          color: Color(0xFF315C45),
                        ),
                      ),
                      title: Text(category['name_category']?.toString() ?? ''),
                      trailing: Wrap(
                        children: [
                          IconButton(
                            tooltip: 'Edit kategori',
                            onPressed: () => editCategory(category),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Hapus kategori',
                            onPressed: () => deleteCategory(category),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({required this.title, required this.initialValue});

  final String title;
  final String initialValue;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() {
    final value = controller.text.trim();
    if (value.isNotEmpty) {
      Navigator.of(context).pop(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: 50,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(hintText: 'Contoh: Teknologi'),
        onSubmitted: (_) => submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: submit, child: const Text('Simpan')),
      ],
    );
  }
}
