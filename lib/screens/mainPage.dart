import 'package:flutter/material.dart';
import 'package:frontend/screens/exsplor.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/screens/save.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'homePage.dart';
import 'postAtikel.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );

  List<Widget> _buildScreens() {
    return [
      const HomePage(),
      const ExplorePage(),
      const AddArticelPage(),
      const SavedPage(),
      const ProfilePage(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.home_rounded),
        title: 'Beranda',
        activeColorPrimary: const Color(0xFF315C45),
        inactiveColorPrimary: Colors.grey,
      ),

      PersistentBottomNavBarItem(
        icon: const Icon(Icons.explore_outlined),
        title: 'Jelajah',
        activeColorPrimary: const Color(0xFF315C45),
        inactiveColorPrimary: Colors.grey,
      ),

      PersistentBottomNavBarItem(
        icon: const Icon(Icons.edit_rounded, color: Colors.white,),
        title: 'Tulis',
        activeColorPrimary: const Color(0xFF315C45),
        inactiveColorPrimary: Colors.grey,
      ),

      PersistentBottomNavBarItem(
        icon: const Icon(Icons.bookmark_border_rounded),
        title: 'Tersimpan',
        activeColorPrimary: const Color(0xFF315C45),
        inactiveColorPrimary: Colors.grey,
      ),

      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person_outline_rounded),
        title: 'Profil',
        activeColorPrimary: const Color(0xFF315C45),
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),

      navBarStyle: NavBarStyle.style16,
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.only(bottom: 0),

      backgroundColor: Colors.white,

      decoration: const NavBarDecoration(
        borderRadius: BorderRadius.zero,
        colorBehindNavBar: Color(0xFFF3F6EE),
      ),
    );
  }
}