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
  // Menggunakan List non-nullable karena ApiService akan mengembalikan [] jika gagal.
  late Future<List<StandingModel>> _standingsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _standingsFuture = _fetchData();
  }

  // Debug helper: fetch raw JSON and show in dialog (useful when device shows different results)
  // This debug helper intentionally uses the BuildContext to show dialogs after
  // awaiting a network call. The usage is guarded by a mounted check and we
  // capture the context in a local variable.
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

  // Method untuk memanggil API dan mengonversi data
  Future<List<StandingModel>> _fetchData() async {
    final rawData = await _apiService.fetchStandings();

    // fetchStandings() di ApiService sudah mengembalikan List<StandingModel> atau List kosong [].
    return rawData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Klasemen Liga Inggris'),
        actions: [
          // Debug button only present in debug builds - helpful to inspect API response on-device
          IconButton(
            tooltip: 'Debug API',
            icon: const Icon(Icons.bug_report),
            onPressed: () => _showRawResponseDebug(context),
          ),
        ],
      ),
      // FutureBuilder menunggu data dari API
      body: FutureBuilder<List<StandingModel>>(
        future: _standingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Menangani error koneksi (misalnya, jika API key salah atau server down)
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error: ${snapshot.error}. Cek koneksi atau API Key Anda.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          // Menangani data sukses (data pasti ada, tapi mungkin kosong [])
          else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            // DataTable perlu scroll horizontal dan vertikal. Kita bungkus dengan
            // SingleChildScrollView horizontal yang memuat SingleChildScrollView
            // vertikal yang berisi DataTable. Ini memungkinkan melihat semua baris.
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
    // Kolom-kolom standar: Rank (#), Tim, Main (P), Menang (W), Seri (D), Kalah (L), Gol Memasukkan (GF), Gol Kemasukan (GA), Selisih Gol (GD), Poin (Pts)
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
                      // Tampilkan logo dari URL (menggunakan Image.network)
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
                // Data Statistik
                DataCell(Text(s.played.toString())),
                DataCell(Text(s.win.toString())),
                DataCell(Text(s.draw.toString())),
                DataCell(Text(s.lose.toString())),
                DataCell(Text(s.goalsFor.toString())),
                DataCell(Text(s.goalsAgainst.toString())),
                DataCell(Text(s.goalsDiff.toString())),
                // Poin
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
