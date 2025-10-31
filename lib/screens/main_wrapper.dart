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

      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        elevation: 8.0,
        child: SafeArea(
          child: SizedBox(
            height: 60,
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          icons[index],
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            selected ? Colors.yellow : Colors.white70,
                            BlendMode.srcIn,
                          ),
                          semanticsLabel: labels[index],
                          placeholderBuilder: (context) => Icon(
                            Icons.circle,
                            size: 18,
                            color: selected ? Colors.yellow : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 12,
                            color: selected ? Colors.yellow : Colors.white70,
                          ),
                        ),
                      ],
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
