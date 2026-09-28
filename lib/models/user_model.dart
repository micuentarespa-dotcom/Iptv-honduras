enum PlanType { BASE, COMPLETO }

class UserModel {
  final String id;
  final String username;
  final String fullName;
  final PlanType plan;
  final bool isDemo;
  final DateTime? expiresAt;
  final String hardwareId;
  final String deviceName;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.plan,
    required this.isDemo,
    this.expiresAt,
    required this.hardwareId,
    required this.deviceName,
  });

  bool get allowVod => plan == PlanType.COMPLETO && !isDemo;
  bool get allowLiveTv => true;
  bool get allowSports => true;

  factory UserModel.fromJson(Map<String, dynamic> json, String hardwareId, String deviceName) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      plan: json['plan'] == 'COMPLETO' ? PlanType.COMPLETO : PlanType.BASE,
      isDemo: json['isDemo'] ?? false,
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      hardwareId: hardwareId,
      deviceName: deviceName,
    );
  }
}
