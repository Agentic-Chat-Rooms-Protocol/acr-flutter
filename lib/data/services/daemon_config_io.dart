import 'dart:io';

const String kDefaultDaemonUrl = 'http://127.0.0.1:20443';
const String _defineDaemonUrl = String.fromEnvironment('ACR_DAEMON_URL');
const String _defineApiToken = String.fromEnvironment('ACR_API_TOKEN');

String normalizeDaemonUrl(String url) {
  var trimmed = url.trim();
  while (trimmed.endsWith('/')) {
    trimmed = trimmed.substring(0, trimmed.length - 1);
  }
  return trimmed;
}

String? _firstNonEmpty(Iterable<String?> candidates) {
  for (final candidate in candidates) {
    final trimmed = candidate?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
}

String resolveDefaultDaemonUrl({Map<String, String>? environment}) {
  final env = environment ?? Platform.environment;
  final envUrl = _firstNonEmpty([
    env['ACR_DAEMON_URL'],
    if (environment == null) _defineDaemonUrl,
  ]);
  if (envUrl != null) {
    final normalized = normalizeDaemonUrl(envUrl);
    if (normalized.isNotEmpty) {
      return normalized;
    }
  }
  return kDefaultDaemonUrl;
}

String? resolveDaemonApiToken({
  Map<String, String>? environment,
  String? homeDirectory,
}) {
  final env = environment ?? Platform.environment;
  final envToken = _firstNonEmpty([
    env['ACR_API_TOKEN'],
    if (environment == null) _defineApiToken,
  ]);
  if (envToken != null) {
    return envToken;
  }

  final home = homeDirectory != null
      ? _firstNonEmpty([homeDirectory])
      : _firstNonEmpty([env['HOME'], env['USERPROFILE']]);
  if (home == null) {
    return null;
  }

  final sep = Platform.pathSeparator;
  final tokenFile = File('$home$sep.acr${sep}api-token');
  try {
    if (!tokenFile.existsSync()) {
      return null;
    }
    final token = tokenFile.readAsStringSync().trim();
    return token.isNotEmpty ? token : null;
  } on IOException {
    return null;
  } on FormatException {
    return null;
  }
}
