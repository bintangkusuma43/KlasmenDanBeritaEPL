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
        title: const Text(
          'Klasemen Liga Inggris',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Debug API',
            icon: const Icon(Icons.bug_report),
            onPressed: () => _showRawResponseDebug(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[900]!, Colors.black],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[850]!, Colors.grey[900]!],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.yellow.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterStandings,
                decoration: InputDecoration(
                  hintText: 'Cari tim favorit Anda...',
                  hintStyle: TextStyle(color: Colors.white38),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.search, color: Colors.black),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.yellow),
                          onPressed: () {
                            _searchController.clear();
                            _filterStandings('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<StandingModel>>(
                future: _standingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.yellow,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Memuat klasemen...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 50,
                            ),
                            const SizedBox(height: 15),
                            Text(
                              'Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Cek koneksi atau API Key Anda.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    if (_searchController.text.isNotEmpty &&
                        _filteredStandings.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.white30,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Tim tidak ditemukan',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildStandingsTable(_filteredStandings),
                      ),
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.table_chart,
                            size: 80,
                            color: Colors.white30,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Tidak ada data klasemen',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandingsTable(List<StandingModel> standings) {
    final columns = ['#', 'Tim', 'P', 'W', 'D', 'L', 'GF', 'GA', 'GD', 'Pts'];

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[850]!, Colors.grey[900]!],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.yellow.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: DataTable(
          columnSpacing: 12.0,
          headingRowHeight: 50,
          dataRowMinHeight: 55,
          dataRowMaxHeight: 55,
          headingRowColor: WidgetStateProperty.all(
            Colors.yellow.withOpacity(0.2),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey[850]!, Colors.grey[900]!],
            ),
          ),
          columns: columns
              .map(
                (label) => DataColumn(
                  label: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.yellow,
                        letterSpacing: 0.5,
                      ),
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
        ),
      ),
    );
  }
}
