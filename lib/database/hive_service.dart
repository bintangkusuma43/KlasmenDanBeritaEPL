import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';

class HiveService {
  final String userBoxName = 'userBox';
  Box get userBox => Hive.box(userBoxName);

  Future<void> insertUser(UserModel user) async {
    // Determine next id defensively: iterate values and attempt to read id if possible
    final values = userBox.values.toList();
    final nextId = values.isNotEmpty
        ? values
                  .map((v) {
                    try {
                      if (v is UserModel) return v.id ?? 0;
                      if (v is Map && v['id'] is int) return v['id'] as int;
                    } catch (_) {}
                    return 0;
                  })
                  .reduce((a, b) => a > b ? a : b) +
              1
        : 1;
    user.id ??= nextId;
    await userBox.put(user.email, user);
  }

  UserModel? getUserByEmail(String email) {
    final raw = userBox.get(email);
    if (raw == null) return null;
    if (raw is UserModel) return raw;
    if (raw is Map) {
      try {
        return UserModel(
          id: raw['id'] as int?,
          nama: raw['nama'] ?? '',
          email: raw['email'] ?? '',
          passwordHash: raw['passwordHash'] ?? '',
          favoriteTeam: raw['favoriteTeam'] ?? '-',
          profilePhotoUrl: raw['profilePhotoUrl'] as String?,
          kesanSaran: raw['kesanSaran'] as String?,
        );
      } catch (_) {}
    }
    return null;
  }

  UserModel? getUserById(int id) {
    try {
      for (final v in userBox.values) {
        if (v is UserModel && v.id == id) return v;
        if (v is Map && v['id'] == id) {
          return UserModel(
            id: v['id'] as int?,
            nama: v['nama'] ?? '',
            email: v['email'] ?? '',
            passwordHash: v['passwordHash'] ?? '',
            favoriteTeam: v['favoriteTeam'] ?? '-',
            profilePhotoUrl: v['profilePhotoUrl'] as String?,
            kesanSaran: v['kesanSaran'] as String?,
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
