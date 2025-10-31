// lib/models/transfer_model.dart

// Model-only file: no Flutter UI imports needed here.

class TransferModel {
  final String playerName;
  final String fromClub;
  final String toClub;
  final String status;
  final String transferDate;
  final String outTeamLogo;
  final String inTeamLogo;

  TransferModel({
    required this.playerName,
    required this.fromClub,
    required this.toClub,
    required this.status,
    required this.transferDate,
    required this.outTeamLogo,
    required this.inTeamLogo,
  });
}
