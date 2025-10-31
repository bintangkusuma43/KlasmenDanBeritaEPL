import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Wajib untuk ikon SVG

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

  // FIX: Hanya 5 menu setelah menghapus Hasil Pertandingan
  // Gunakan lazy loading untuk screens
  late final List<Widget> _screens = [
    const HomeScreen(),
    const StandingsScreen(),
    const MatchesScreen(), // Jadwal (Hanya satu screen)
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
      // Menggunakan IndexedStack untuk menjaga state layar
      body: IndexedStack(index: _selectedIndex, children: _screens),
      
      // Menggunakan BottomAppBar sesuai keinginan Anda
      bottomNavigationBar: BottomAppBar(
        color: Colors.black, // Background hitam solid
        elevation: 8.0,
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              // FIX: List.generate hanya untuk 5 menu (_screens.length)
              children: List.generate(_screens.length, (index) {
                // FIX: Menyesuaikan labels dan icons menjadi 5 item
                final labels = [
                  'Beranda',
                  'Klasemen',
                  'Jadwal',
                  'Transfer',
                  'Profil',
                ];
                
                // Catatan: Anda harus memastikan semua file SVG ini ada di folder assets/icons/
                final icons = [
                  'assets/icons/home.svg',
                  'assets/icons/standings.svg',
                  'assets/icons/event.svg', // Mengganti ikon Hasil menjadi Jadwal
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
                        // Menggunakan SvgPicture.asset
                        SvgPicture.asset(
                          icons[index],
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            selected ? Colors.yellow : Colors.white70,
                            BlendMode.srcIn,
                          ),
                          semanticsLabel: labels[index],
                          // Placeholder wajib jika SVG gagal dimuat
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