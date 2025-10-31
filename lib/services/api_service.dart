import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/transfer_model.dart';
import '../models/match_model.dart';
import '../models/news_model.dart';
import '../models/standing_model.dart';

class ApiService {
  static const String _apiSportsKey = "31651087a18efa3f76091600cb87e205";
  static const String _apiSportsHost = "v3.football.api-sports.io";

  Map<String, String> get _apiHeaders => {
    'x-apisports-key': _apiSportsKey,
    'x-apisports-host': _apiSportsHost,
  };

  Future<List<StandingModel>> fetchStandings({
    String leagueId = '39',
    String season = '2023',
  }) async {
    final url = Uri.parse(
      'https://$_apiSportsHost/standings?league=$leagueId&season=$season',
    );

    debugPrint('Fetching standings from: $url');

    final headers = Map<String, String>.from(_apiHeaders);
    if (headers['x-apisports-key'] == null ||
        headers['x-apisports-key']!.isEmpty) {
      debugPrint('fetchStandings: missing API key in headers');
      return [];
    }

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      debugPrint('Standings API status code: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('Standings API error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return [];
      }

      final data = json.decode(response.body);
      debugPrint('Standings API response decoded successfully');

      if (data is! Map) {
        debugPrint('Standings: Response is not a Map');
        return [];
      }

      if (data['response'] is! List) {
        debugPrint('Standings: data["response"] is not a List');
        debugPrint('data["response"] type: ${data['response'].runtimeType}');
        return [];
      }

      final responseList = data['response'] as List;
      debugPrint('Response list length: ${responseList.length}');

      if (responseList.isEmpty) {
        debugPrint('Standings: response array is empty');
        return [];
      }

      final firstItem = responseList[0];
      debugPrint('First item type: ${firstItem.runtimeType}');

      if (firstItem is! Map) {
        debugPrint('Standings: First response item is not a Map');
        return [];
      }

      debugPrint('First item keys: ${firstItem.keys.join(", ")}');

      if (firstItem.containsKey('league') && firstItem['league'] is Map) {
        final league = firstItem['league'] as Map;
        debugPrint('League keys: ${league.keys.join(", ")}');

        if (league.containsKey('standings') && league['standings'] is List) {
          final standingsArray = league['standings'] as List;
          debugPrint('Standings array length: ${standingsArray.length}');

          if (standingsArray.isNotEmpty) {
            final firstStandingsItem = standingsArray[0];
            debugPrint(
              'First standings item type: ${firstStandingsItem.runtimeType}',
            );

            if (firstStandingsItem is List) {
              final standingsList = firstStandingsItem;
              debugPrint('Found ${standingsList.length} standings entries');

              final List<StandingModel> standings = [];
              for (var i = 0; i < standingsList.length; i++) {
                try {
                  final e = standingsList[i];
                  if (e is Map) {
                    final standing = StandingModel.fromJson(
                      Map<String, dynamic>.from(e),
                    );
                    standings.add(standing);
                    debugPrint('Parsed standing $i: ${standing.teamName}');
                  }
                } catch (err, stackTrace) {
                  debugPrint('Failed to parse standing entry $i: $err');
                  debugPrint('Stack trace: $stackTrace');
                }
              }

              debugPrint('Successfully parsed ${standings.length} standings');
              return standings;
            } else {
              debugPrint('First standings item is not a List');
            }
          } else {
            debugPrint('Standings array is empty');
          }
        } else {
          debugPrint('league["standings"] not found or not a List');
        }
      } else {
        debugPrint('firstItem["league"] not found or not a Map');
      }

      debugPrint('Standings: Could not find league.standings[0] in response');
      return [];
    } catch (e, st) {
      debugPrint('Error fetching standings: $e');
      debugPrint('Stack trace: $st');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchStandingsRaw({
    String leagueId = '39',
    String season = '2023',
  }) async {
    final url = Uri.parse(
      'https://$_apiSportsHost/standings?league=$leagueId&season=$season',
    );

    try {
      final response = await http
          .get(url, headers: _apiHeaders)
          .timeout(const Duration(seconds: 10));

      final int status = response.statusCode;
      dynamic body;
      try {
        body = json.decode(response.body);
      } catch (_) {
        body = response.body;
      }

      return {'status': status, 'body': body};
    } catch (e) {
      debugPrint('Error in fetchStandingsRaw: $e');
      return null;
    }
  }

  Future<List<NewsModel>> fetchNews() async {
    final rawData = [
      {
        'title': 'Arsenal Konsisten Perkasa Sepanjang Oktober',
        'description': 'Laporan performa Arsenal bulan Oktober.',
        'url':
            'https://www.medcom.id/olahraga/liga-inggris/MkMOgeVN-arsenal-konsisten-perkasa-sepanjang-oktober',
        'urlToImage': 'assets/Berita Arsenal.jpeg',
        'source': {'name': 'Medcom'},
        'publishedAt': '2025-10-31T...',
      },
      {
        'title':
            'Nottingham Forest vs MU, Duel Casemiro Lawan Sang Calon Pengganti',
        'description': 'Pratinjau pertandingan yang menarik.',
        'url':
            'https://www.bola.net/inggris/nottingham-forest-vs-mu-duel-casemiro-lawan-sang-calon-pengganti-94edc5.html',
        'urlToImage': 'assets/Casemiro.jpg',
        'source': {'name': 'Bola.net'},
        'publishedAt': '2025-10-31T...',
      },
      {
        'title': 'MU Siapkan Rp 1,5 T untuk Tebus Camavinga',
        'description': 'Berita transfer pemain bintang.',
        'url':
            'https://sport.detik.com/sepakbola/liga-inggris/d-8185503/mu-siapkan-rp-1-5-t-untuk-tebus-camavinga',
        'urlToImage': 'assets/Camavinga.jpeg',
        'source': {'name': 'Detik Sport'},
        'publishedAt': '2025-10-31T...',
      },
    ];
    return rawData.map((data) => NewsModel.fromJson(data)).toList();
  }

  Future<List<MatchModel>> fetchStaticMatches() async {
    return [
      MatchModel(
        date: "Sabtu, 1 November",
        time: "2025-11-01T12:30:00Z",
        homeTeam: "Fulham",
        awayTeam: "Wolves",
        homeLogo: "",
        awayLogo: "",
        score: null,
      ),
      MatchModel(
        date: "Sabtu, 1 November",
        time: "2025-11-01T15:00:00Z",
        homeTeam: "Man City",
        awayTeam: "Burnley",
        homeLogo: "",
        awayLogo: "",
        score: null,
      ),
      MatchModel(
        date: "Sabtu, 1 November",
        time: "2025-11-01T15:00:00Z",
        homeTeam: "Arsenal",
        awayTeam: "Newcastle",
        homeLogo: "",
        awayLogo: "",
        score: null,
      ),
      MatchModel(
        date: "Sabtu, 1 November",
        time: "2025-11-01T17:30:00Z",
        homeTeam: "Chelsea",
        awayTeam: "Spurs",
        homeLogo: "",
        awayLogo: "",
        score: null,
      ),
      MatchModel(
        date: "Minggu, 2 November",
        time: "2025-11-02T14:00:00Z",
        homeTeam: "Liverpool",
        awayTeam: "Everton",
        homeLogo: "",
        awayLogo: "",
        score: null,
      ),
      MatchModel(
        date: "Minggu, 2 November",
        time: "2025-11-02T14:00:00Z",
        homeTeam: "Aston Villa",
        awayTeam: "Leicester",
        homeLogo: "",
        awayLogo: "",
        score: null,
      ),
      MatchModel(
        date: "Minggu, 2 November",
        time: "2025-11-02T16:30:00Z",
        homeTeam: "Man United",
        awayTeam: "Nottm Forest",
        homeLogo: "",
        awayLogo: "",
        score: null,
      ),
      MatchModel(
        date: "Senin, 3 November",
        time: "2025-11-03T20:00:00Z",
        homeTeam: "West Ham",
        awayTeam: "Brighton",
        homeLogo: "",
        awayLogo: "",
        score: null,
      ),
      MatchModel(
        date: "Sabtu, 8 November",
        time: "2025-11-08T15:00:00Z",
        homeTeam: "Spurs",
        awayTeam: "Wolves",
        homeLogo: "",
        awayLogo: "",
        score: null,
      ),
      MatchModel(
        date: "Sabtu, 8 November",
        time: "2025-11-08T17:30:00Z",
        homeTeam: "Chelsea",
        awayTeam: "Liverpool",
        homeLogo: "",
        awayLogo: "",
        score: null,
      ),
    ];
  }

  Future<List<TransferModel>> fetchTransfers() async {
    final url = Uri.parse('https://$_apiSportsHost/transfers?player=18928');

    debugPrint('Fetching transfers from: $url');

    final headers = Map<String, String>.from(_apiHeaders);
    if (headers['x-apisports-key'] == null ||
        headers['x-apisports-key']!.isEmpty) {
      debugPrint('fetchTransfers: missing API key in headers');
      return [];
    }

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 15));

      debugPrint('Transfers API status code: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('Transfers API error: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return [];
      }

      final data = json.decode(response.body);
      debugPrint('Transfers API response decoded successfully');

      if (data is! Map || data['response'] is! List) {
        debugPrint('Transfers: Invalid response structure');
        return [];
      }

      final responseList = data['response'] as List;
      if (responseList.isEmpty) {
        debugPrint('Transfers: response array is empty');
        return [];
      }

      final List<TransferModel> transferList = [];

      for (final playerObj in responseList) {
        if (playerObj is! Map) {
          debugPrint('Transfers: playerObj is not a Map');
          continue;
        }

        final playerName =
            (playerObj['player'] is Map && playerObj['player']['name'] != null)
            ? playerObj['player']['name'] as String
            : 'P. Crouch';

        final transfers = (playerObj['transfers'] is List)
            ? (playerObj['transfers'] as List)
            : [];

        debugPrint(
          'Found ${transfers.length} transfer records for $playerName',
        );

        for (final t in transfers) {
          if (t is! Map) continue;

          try {
            final teams = (t['teams'] is Map)
                ? (t['teams'] as Map)
                : <String, dynamic>{};
            final outTeam = (teams['out'] is Map)
                ? (teams['out'] as Map)
                : <String, dynamic>{};
            final inTeam = (teams['in'] is Map)
                ? (teams['in'] as Map)
                : <String, dynamic>{};

            final transfer = TransferModel(
              playerName: playerName,
              fromClub: outTeam['name']?.toString() ?? '-',
              toClub: inTeam['name']?.toString() ?? '-',
              status: t['type']?.toString() ?? '-',
              transferDate: t['date']?.toString() ?? '-',
              outTeamLogo: outTeam['logo']?.toString() ?? '',
              inTeamLogo: inTeam['logo']?.toString() ?? '',
            );

            transferList.add(transfer);
            debugPrint(
              'Parsed transfer: ${transfer.fromClub} → ${transfer.toClub}',
            );
          } catch (e) {
            debugPrint('Failed to parse transfer entry: $e');
          }
        }
      }

      debugPrint('Total transfers parsed: ${transferList.length}');
      return transferList;
    } catch (e, st) {
      debugPrint('Error fetching transfers: $e');
      debugPrint('Stack trace: $st');
      return [];
    }
  }
}
