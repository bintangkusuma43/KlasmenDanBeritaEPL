class MatchModel {
  final int? id;
  final String date;
  final String time; 
  final String homeTeam;
  final String awayTeam;
  final String homeLogo;
  final String awayLogo;
  final String? score;

  MatchModel({
    this.id,
    required this.date,
    required this.time,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeLogo,
    required this.awayLogo,
    this.score,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    // Model disesuaikan untuk data statis
    return MatchModel(
      id: json['id'],
      date: json['date'], 
      time: json['time'], 
      homeTeam: json['home_team'],
      awayTeam: json['away_team'],
      homeLogo: json['home_logo'] ?? '',
      awayLogo: json['away_logo'] ?? '',
      score: json['score'],
    );
  }
}