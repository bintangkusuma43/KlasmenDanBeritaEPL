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
  final TextEditingController _searchController = TextEditingController();
  List<StandingModel> _allStandings = [];
  List<StandingModel> _filteredStandings = [];

  @override
  void initState() {
    super.initState();
    _standingsFuture = _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStandings(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStandings = _allStandings;
      } else {
        _filteredStandings = _allStandings
            .where(
              (standing) =>
                  standing.teamName.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
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
    _allStandings = rawData;
    _filteredStandings = rawData;
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterStandings,
              decoration: InputDecoration(
                hintText: 'Cari tim...',
                prefixIcon: const Icon(Icons.search, color: Colors.yellow),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterStandings('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.yellow),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.yellow, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StandingModel>>(
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
                  if (_searchController.text.isNotEmpty && _filteredStandings.isEmpty) {
                    return const Center(
                      child: Text(
                        'Tim tidak ditemukan',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: _buildStandingsTable(_filteredStandings),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text('Tidak ada data klasemen yang tersedia.'),
                  );
                }
              },
            ),
          ),
        ],
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
