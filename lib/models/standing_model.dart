class StandingModel {
  final int rank;
  final String teamName;
  final String teamLogo;
  final int points;
  final int goalsDiff;
  final int played;
  final int win;
  final int draw;
  final int lose;
  final int goalsFor;
  final int goalsAgainst;

  StandingModel({
    required this.rank,
    required this.teamName,
    required this.teamLogo,
    required this.points,
    required this.goalsDiff,
    required this.played,
    required this.win,
    required this.draw,
    required this.lose,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  factory StandingModel.fromJson(Map<String, dynamic> json) {
    // Defensive parsing to handle null/missing fields
    final team = json['team'] is Map
        ? json['team'] as Map<String, dynamic>
        : <String, dynamic>{};
    final all = json['all'] is Map
        ? json['all'] as Map<String, dynamic>
        : <String, dynamic>{};
    final goals = all['goals'] is Map
        ? all['goals'] as Map<String, dynamic>
        : <String, dynamic>{};

    return StandingModel(
      rank: json['rank'] as int? ?? 0,
      teamName: team['name'] as String? ?? 'Unknown',
      teamLogo: team['logo'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      goalsDiff: json['goalsDiff'] as int? ?? 0,
      played: all['played'] as int? ?? 0,
      win: all['win'] as int? ?? 0,
      draw: all['draw'] as int? ?? 0,
      lose: all['lose'] as int? ?? 0,
      goalsFor: goals['for'] as int? ?? 0,
      goalsAgainst: goals['against'] as int? ?? 0,
    );
  }
}
