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

  final ApiService _apiService = ApiService();
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
        _newsList = rawData;

        _notificationService
            .showNotification(
              10,
              '🚨 Berita Terbaru Liga Inggris!',
              'Ada ${_newsList.length} artikel baru menanti Anda. Cek sekarang.',
            )
            .catchError((e) {});
      } else {
        _newsList = [];
      }
    } catch (e) {
      debugPrint("Error fetching news: $e");
      _newsList = [];
    } finally {
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
