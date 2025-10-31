import 'package:hive/hive.dart';

// PASTIKAN ANDA SUDAH MENJALANKAN 'build_runner'
part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  UserModel copyWith({
    int? id,
    String? nama,
    String? email,
    String? passwordHash,
    String? favoriteTeam,
    String? profilePhotoUrl,
    String? kesanSaran,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      favoriteTeam: favoriteTeam ?? this.favoriteTeam,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      kesanSaran: kesanSaran ?? this.kesanSaran,
    );
  }

  @HiveField(0)
  int? id;
  @HiveField(1)
  String nama;
  @HiveField(2)
  String email;
  @HiveField(3)
  String passwordHash;
  @HiveField(4)
  String favoriteTeam; // Field: Tim Jagoan
  @HiveField(5)
  String? profilePhotoUrl; // Field: URL Foto Profil
  @HiveField(6)
  String? kesanSaran; // Kesan dan saran kuliah (input saat registrasi)

  UserModel({
    this.id,
    required this.nama,
    required this.email,
    required this.passwordHash,
    required this.favoriteTeam,
    this.profilePhotoUrl,
    this.kesanSaran,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'favoriteTeam': favoriteTeam,
      'profilePhotoUrl': profilePhotoUrl,
      'kesanSaran': kesanSaran,
    };
  }
}
