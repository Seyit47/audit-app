/// Server version and minimum supported client versions, from `GET /v1/version`.
class VersionInfo {
  const VersionInfo({
    required this.serverVersion,
    required this.minMobileVersion,
    required this.minAdminWebVersion,
    required this.environment,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) => VersionInfo(
    serverVersion: json['serverVersion'] as String,
    minMobileVersion: json['minMobileVersion'] as String,
    minAdminWebVersion: json['minAdminWebVersion'] as String,
    environment: json['environment'] as String,
  );

  final String serverVersion;
  final String minMobileVersion;
  final String minAdminWebVersion;
  final String environment;
}
