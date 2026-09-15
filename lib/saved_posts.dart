import 'package:flutter/foundation.dart';

class SavedPosts extends ChangeNotifier {
  SavedPosts._();

  static final SavedPosts instance = SavedPosts._();

  final List<Map<String, dynamic>> _posts = [];

  List<Map<String, dynamic>> get posts => List.unmodifiable(_posts);

  bool contains(Map<String, dynamic> post) {
    return _posts.any((savedPost) => savedPost['id_post'] == post['id_post']);
  }

  void toggle(Map<String, dynamic> post) {
    final index = _posts.indexWhere(
      (savedPost) => savedPost['id_post'] == post['id_post'],
    );

    if (index == -1) {
      _posts.add(Map<String, dynamic>.from(post));
    } else {
      _posts.removeAt(index);
    }

    notifyListeners();
  }
}
