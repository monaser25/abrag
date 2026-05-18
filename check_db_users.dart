import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final env = await _readEnvFile();
  final supabaseUrl = env['SUPABASE_URL'];
  final supabaseAnonKey = env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null ||
      supabaseUrl.isEmpty ||
      supabaseAnonKey == null ||
      supabaseAnonKey.isEmpty) {
    stderr.writeln('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
    exitCode = 1;
    return;
  }

  final users = await _fetchUserProfiles(supabaseUrl, supabaseAnonKey);

  stdout.writeln('Users count: ${users.length}');
  for (final user in users) {
    stdout.writeln(
      'email: ${user['email'] ?? '-'} | role: ${user['role'] ?? '-'} | '
      'id: ${user['id'] ?? '-'} | created_at: ${user['created_at'] ?? '-'}',
    );
  }
}

Future<List<Map<String, dynamic>>> _fetchUserProfiles(
  String supabaseUrl,
  String supabaseAnonKey,
) async {
  final normalizedUrl = supabaseUrl.replaceFirst(RegExp(r'/$'), '');
  final uri = Uri.parse('$normalizedUrl/rest/v1/user_profiles').replace(
    queryParameters: {
      'select': 'email,role,id,created_at',
      'order': 'created_at.desc',
    },
  );

  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    request.headers
      ..set('apikey', supabaseAnonKey)
      ..set(HttpHeaders.authorizationHeader, 'Bearer $supabaseAnonKey')
      ..set(HttpHeaders.acceptHeader, 'application/json');

    final response = await request.close();
    final body = await utf8.decodeStream(response);

    if (response.statusCode < HttpStatus.ok ||
        response.statusCode >= HttpStatus.multipleChoices) {
      throw HttpException(
        'Supabase request failed (${response.statusCode}): $body',
        uri: uri,
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! List) {
      throw const FormatException(
        'Expected Supabase to return a list of users',
      );
    }

    return decoded.whereType<Map>().map((item) {
      return item.cast<String, dynamic>();
    }).toList();
  } finally {
    client.close(force: true);
  }
}

Future<Map<String, String>> _readEnvFile() async {
  final file = File('.env');
  if (!await file.exists()) {
    return const {};
  }

  final values = <String, String>{};
  final lines = await file.readAsLines();

  for (final rawLine in lines) {
    final line = rawLine.trim();
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }

    final separatorIndex = line.indexOf('=');
    if (separatorIndex <= 0) {
      continue;
    }

    final key = line.substring(0, separatorIndex).trim();
    final value = line.substring(separatorIndex + 1).trim();
    values[key] = _stripOptionalQuotes(value);
  }

  return values;
}

String _stripOptionalQuotes(String value) {
  if (value.length < 2) {
    return value;
  }

  final first = value[0];
  final last = value[value.length - 1];

  if ((first == '"' && last == '"') || (first == "'" && last == "'")) {
    return value.substring(1, value.length - 1);
  }

  return value;
}
