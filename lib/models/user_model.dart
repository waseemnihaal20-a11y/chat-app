/// Represents a user in the chat application.
class UserModel {
  final String id;
  final String fullName;
  final String? username;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    this.username,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Creates a UserModel from JSON response (DummyJSON format)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      username: json['username'],
    );
  }

  /// Converts the UserModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Gets the initial letter for avatar display
  String get initial {
    if (fullName.isEmpty) return '?';
    return fullName[0].toUpperCase();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  /// Creates a copy of the UserModel with optional new values
  UserModel copyWith({
    String? id,
    String? fullName,
    String? username,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
