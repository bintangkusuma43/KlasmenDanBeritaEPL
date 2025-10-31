import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/standing_model.dart';
import '../services/api_service.dart';

class StandingsScreen extends StatefulWidget {
  const StandingsScreen({super.key});

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen> {
  late Future<List<StandingModel>> _standingsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _standingsFuture = _fetchData();
  }

  Future<void> _showRawResponseDebug(BuildContext context) async {
    final localContext = context;

    final resp = await _apiService.fetchStandingsRaw();
    if (!mounted) return;

    if (resp == null) {
      showDialog(
        context: localContext,
        builder: (_) => AlertDialog(
          title: const Text('Debug: Standings API'),
          content: const Text('Gagal memanggil API. Cek log.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(localContext),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
      return;
    }

    final status = resp['status'];
    final body = resp['body'];

    final pretty = body is String
        ? body
        : const JsonEncoder.withIndent('  ').convert(body);

    showDialog(
      context: localContext,
      builder: (_) => AlertDialog(
        title: Text('Debug: Standings API (status: $status)'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(child: SelectableText(pretty)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(localContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<List<StandingModel>> _fetchData() async {
    final rawData = await _apiService.fetchStandings();

    return rawData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Klasemen Liga Inggris'),
        actions: [
          IconButton(
            tooltip: 'Debug API',
            icon: const Icon(Icons.bug_report),
            onPressed: () => _showRawResponseDebug(context),
          ),
        ],
      ),
      body: FutureBuilder<List<StandingModel>>(
        future: _standingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error: ${snapshot.error}. Cek koneksi atau API Key Anda.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: _buildStandingsTable(snapshot.data!),
              ),
            );
          } else {
            return const Center(
              child: Text('Tidak ada data klasemen yang tersedia.'),
            );
          }
        },
      ),
    );
  }

  Widget _buildStandingsTable(List<StandingModel> standings) {
    final columns = ['#', 'Tim', 'P', 'W', 'D', 'L', 'GF', 'GA', 'GD', 'Pts'];

    return DataTable(
      columnSpacing: 12.0,
      headingRowHeight: 40,
      dataRowMinHeight: 50,
      dataRowMaxHeight: 50,
      columns: columns
          .map(
            (label) => DataColumn(
              label: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              tooltip: label,
            ),
          )
          .toList(),

      rows: standings
          .map(
            (s) => DataRow(
              cells: [
                DataCell(Text(s.rank.toString())),
                DataCell(
                  Row(
                    children: [
                      Image.network(
                        s.teamLogo,
                        width: 24,
                        errorBuilder: (c, o, t) =>
                            const Icon(Icons.shield, size: 24),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: Text(
                          s.teamName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(s.played.toString())),
                DataCell(Text(s.win.toString())),
                DataCell(Text(s.draw.toString())),
                DataCell(Text(s.lose.toString())),
                DataCell(Text(s.goalsFor.toString())),
                DataCell(Text(s.goalsAgainst.toString())),
                DataCell(Text(s.goalsDiff.toString())),
                DataCell(
                  Text(
                    s.points.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.yellowAccent,
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
