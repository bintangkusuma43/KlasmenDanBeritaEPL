class NewsModel {
  final String title;
  final String description;
  final String url;
  final String? imageUrl;
  final String sourceName;
  final String publishedAt;

  NewsModel({
    required this.title,
    required this.description,
    required this.url,
    this.imageUrl,
    required this.sourceName,
    required this.publishedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      url: json['url'] ?? '',
      imageUrl: json['urlToImage'],
      sourceName: json['source']['name'] ?? 'Unknown Source',
      publishedAt: json['publishedAt'] ?? '',
    );
  }
}