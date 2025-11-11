import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'home_screen.dart';
import 'standings_screen.dart';
import 'matches_screen.dart';
import 'transfers_screen.dart';
import 'profile_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const HomeScreen(),
    const StandingsScreen(),
    const MatchesScreen(),
    const TransfersScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_screens.length, (index) {
                final labels = [
                  'Beranda',
                  'Klasemen',
                  'Jadwal',
                  'Transfer',
                  'Profil',
                ];

                final icons = [
                  'assets/icons/home.svg',
                  'assets/icons/standings.svg',
                  'assets/icons/event.svg',
                  'assets/icons/swap.svg',
                  'assets/icons/profile.svg',
                ];

                final selected = index == _selectedIndex;

                return Expanded(
                  child: InkWell(
                    onTap: () => _onItemTapped(index),
                    borderRadius: BorderRadius.circular(15),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              )
                            : null,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            icons[index],
                            width: selected ? 24 : 22,
                            height: selected ? 24 : 22,
                            colorFilter: ColorFilter.mode(
                              selected ? Colors.black : Colors.white70,
                              BlendMode.srcIn,
                            ),
                            semanticsLabel: labels[index],
                            placeholderBuilder: (context) => Icon(
                              Icons.circle,
                              size: selected ? 22 : 20,
                              color: selected ? Colors.black : Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            labels[index],
                            style: TextStyle(
                              fontSize: selected ? 11 : 10,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selected ? Colors.black : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
