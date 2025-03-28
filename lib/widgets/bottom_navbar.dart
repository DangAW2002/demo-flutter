// ignore_for_file: prefer_const_constructors

import 'package:demo/providers/valentine_provider.dart';
import 'package:flutter/material.dart';
import 'package:demo/pages/home.dart';
import 'package:demo/pages/add_device.dart';
import 'package:demo/pages/profile.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Home(),
    const AddDevice(),
    const Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isValentine = context.watch<ValentineProvider>().isValentineMode;

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add Device',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: isValentine ? Colors.pink[400] : Colors.amber,
        unselectedItemColor: isValentine ? Colors.pink[200] : Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
