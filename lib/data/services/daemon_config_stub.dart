const String kDefaultDaemonUrl = 'http://127.0.0.1:20443';

String resolveDefaultDaemonUrl({Map<String, String>? environment}) {
  const envUrl = String.fromEnvironment('ACR_DAEMON_URL');
  var trimmed = envUrl.trim();
  while (trimmed.endsWith('/')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }
  if (trimmed.isNotEmpty) {
    return trimmed;
  }
  return kDefaultDaemonUrl;
}

String? resolveDaemonApiToken({
  Map<String, String>? environment,
  String? homeDirectory,
}) {
  const envToken = String.fromEnvironment('ACR_API_TOKEN');
  final trimmed = envToken.trim();
  if (trimmed.isNotEmpty) return trimmed;
  return null;
}
