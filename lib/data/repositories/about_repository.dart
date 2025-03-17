import 'dart:convert';

import 'package:http/http.dart' show Response;

import '../../utils/command/result.dart';
import '../../utils/extensions/date.dart';
import '../../utils/handlers/log_handler.dart';
import '../../utils/helpers/helper.dart';

class AboutRepository {
  Future<Result<List<(String, String)>>> getAllTags() async {
    final value = await githubAPIQuery('/git/refs/tags');
    final json = jsonDecode(value.body);
    if (json == null) {
      return Result.error(Exception('Rate limited. Please come back later.'));
    }
    if (json is! List) {
      if (json['status'] == 404) {
        LogHandler.log('JSON received is not a list', LogLevel.error);
        return Result.error(Exception('Something is wrong when trying to get version list.'));
      } else {
        return const Result.ok([]);
      }
    }

    return Result.ok(json.map((e) {
      final tag = e['ref'].toString().trim().split('/').last;
      final sha = e['object']['sha'].toString().trim().substring(0, 7);
      return (tag, sha);
    }).toList());
  }

  Future<Result<String>> getNewestVersion() async {
    final hasInternet = await checkInternetConnection();
    if (!hasInternet) return Result.error(Exception('No internet connection'));

    final result = await getAllTags();
    String newestTag;

    switch (result) {
      case Ok():
        final tags = result.value.map((e) => e.$1).toList();
        if (tags.isEmpty) return Result.error(Exception('No tags exists'));
        newestTag = tags.last;
        return Result.ok(newestTag);
      case Error():
        return Result.error(result.error);
    }
  }

  Future<(String, String)> getRelease(String tag, String sha) async {
    final res = await githubAPIQuery('/releases/tags/$tag');
    final json = jsonDecode(res.body);

    if (json == null) throw Exception('Rate limited. Please come back later.');
    if (json is! Map) throw Exception('Something is wrong, JSON received is not a map.');

    LogHandler.log('Got release of: t=$tag, sha=$sha');
    final timeUploaded = DateTime.parse(json['published_at'] as String).toDateString();
    return (json['body'] as String, timeUploaded);
  }

  Future<(String, String)> getNote(String tag, String sha) async {
    // final filename = _dev ? 'release_note.md' : 'dev_changes.md';
    const filename = 'dev_changes.md';

    LogHandler.log('Getting markdown of: t=$tag, sha=$sha');
    Response res = await githubAPIQuery('/contents/$filename?ref=$sha');
    dynamic json = jsonDecode(res.body);

    if (json == null) throw Exception('Rate limited. Please come back later.');
    if (json is! Map) throw Exception('Something is wrong, JSON received is not a map.');

    if (json['content'] == null) {
      LogHandler.log('dev_changes.md not found, getting release instead');
      return getRelease(tag, sha);
    }

    final content = utf8.decode(base64Decode(
      (json['content'] as String).replaceAll('\n', ''),
    ));

    LogHandler.log('Getting time of commit ($sha)');
    res = await githubAPIQuery('/commits/$sha');
    json = jsonDecode(res.body);

    if (json == null) throw Exception('Rate limited. Please come back later.');
    if (json is! Map) throw Exception('Something is wrong, JSON received is not a map.');

    final timeUploaded = DateTime.parse(json['commit']['committer']['date'] as String).toDateString();

    return (content, timeUploaded);
  }
}
