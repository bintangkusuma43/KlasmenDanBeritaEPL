// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_model.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<NewsModel> _newsList = [];
  bool _isLoading = true;

  // Inisialisasi final service instances di dalam State class
  final ApiService _apiService = ApiService();
  // Use singleton instance instead of creating new one
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _fetchNewsData();
  }

  Future<void> _fetchNewsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final rawData = await _apiService.fetchNews();

      if (rawData.isNotEmpty) {
        _newsList =
            rawData; // Karena fetchNews sudah mengembalikan List<NewsModel>

        // Pemicu Notifikasi (Kriteria Wajib) - FIX: Argumen ID dimasukkan
        // Call notification without await to prevent blocking
        _notificationService
            .showNotification(
              10, // ID Notifikasi
              '🚨 Berita Terbaru Liga Inggris!',
              'Ada ${_newsList.length} artikel baru menanti Anda. Cek sekarang.',
            )
            .catchError((e) {
              // Silently ignore notification errors
            });
      } else {
        _newsList = [];
      }
    } catch (e) {
      debugPrint("Error fetching news: $e");
      _newsList = [];
    } finally {
      // Avoid returning inside finally; only set state when mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka link berita.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda & Berita Terkini')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _newsList.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada berita yang ditemukan. Menggunakan data statis.',
              ),
            )
          : ListView.builder(
              itemCount: _newsList.length,
              itemBuilder: (context, index) {
                final news = _newsList[index];
                return InkWell(
                  onTap: () => _launchURL(news.url),
                  child: Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tampilkan gambar jika ada, jika tidak tampilkan placeholder
                        news.imageUrl != null && news.imageUrl!.isNotEmpty
                            ? (news.imageUrl!.startsWith('assets/')
                                  ? Image.asset(
                                      news.imageUrl!.replaceFirst(
                                        RegExp(r'^/+'),
                                        '',
                                      ),
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            debugPrint(
                                              'Asset image load error: $error',
                                            );
                                            return Container(
                                              height: 180,
                                              color: Colors.grey[900],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 48,
                                                  color: Colors.white54,
                                                ),
                                              ),
                                            );
                                          },
                                    )
                                  : Image.network(
                                      news.imageUrl!,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            debugPrint(
                                              'Image load error: $error',
                                            );
                                            return Container(
                                              height: 180,
                                              color: Colors.grey[900],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 48,
                                                  color: Colors.white54,
                                                ),
                                              ),
                                            );
                                          },
                                    ))
                            : Container(
                                height: 180,
                                color: Colors.grey[900],
                                child: const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 48,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),

                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                news.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.source, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    news.sourceName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Text(
                                    news.publishedAt.substring(0, 10),
                                    style: const TextStyle(fontSize: 12),
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
              },
            ),
    );
  }
}
