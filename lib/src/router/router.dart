import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as images;
import 'package:plugfox_badges_faas/src/feature/coderanks.dart';
import 'package:shelf/shelf.dart' as shelf;

Map<String, List<int>> _cache = <String, List<int>>{};

Future<shelf.Response> router(shelf.Request request) {
  if (request.method != 'GET') return _notFound();
  try {
    switch (request.url.path.trim().toLowerCase()) {
      case 'dart_rank':
        return getDartCodeRanks();
      case 'dart_rank.svg':
        return getDartCodeRanksBadge();
      case '':
      case '/':
      default:
        return _notFound();
    }
  } on Object catch (error) {
    return _internalServerError(error);
  }
}

Future<shelf.Response> _notFound() {
  final bytes = jsonEncode(<String, Object>{
    'error': 'Not found',
  }).codeUnits;
  return Future<shelf.Response>.value(shelf.Response.notFound(
    bytes,
    headers: <String, String>{
      'Content-Length': bytes.length.toString(),
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-cache',
    },
  ));
}

Future<shelf.Response> _internalServerError(Object error) {
  final bytes = jsonEncode(<String, Object>{
    'error': error.toString(),
  }).codeUnits;
  return Future<shelf.Response>.value(shelf.Response.internalServerError(
    body: bytes,
    headers: <String, String>{
      'Content-Length': bytes.length.toString(),
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-cache',
    },
  ));
}

Future<shelf.Response> getDartCodeRanks() async {
  final List<int> bytes;
  final fromCache = _cache['dart_rank'];
  if (fromCache != null) {
    bytes = fromCache;
  } else {
    final rank = await getDartRankFromCodeRank();
    bytes = jsonEncode(rank.toJson()).codeUnits;
    _cache['dart_rank'] = bytes;
  }
  return shelf.Response.ok(
    bytes,
    headers: <String, String>{
      'Content-Length': bytes.length.toString(),
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'public, max-age=86400',
    },
  );
}

Future<shelf.Response> getDartCodeRanksBadge() async {
  final List<int> bytes;
  final fromCache = _cache['dart_rank.svg'];
  if (fromCache != null) {
    bytes = fromCache;
  } else {
    final rank = await getDartRankFromCodeRank();
    final badge = generateTopRankDartBadge(rank.rank.toString(), rank.location);
    bytes = badge.codeUnits;
    _cache['dart_rank.svg'] = bytes;
  }
  return shelf.Response.ok(
    bytes,
    headers: <String, String>{
      'Content-Length': bytes.length.toString(),
      'Content-Type': 'image/svg+xml; charset=utf-8',
      'Cache-Control': 'public, max-age=86400',
    },
  );
}

Future<shelf.Response> getCodeRanksSummaryImage(shelf.Request request) async {
  const badgeUrl = 'https://cr-ss-service.azurewebsites.net/api/ScreenShot'
      '?widget=summary'
      '&width=495'
      '&username=plugfox'
      '&skills=dart'
      '&branding=false'
      '&layout=horizontal';
  final bytes = await Stream<http.Response>.fromFuture(
    http.get(Uri.parse(badgeUrl)).timeout(const Duration(seconds: 25)),
  )
      .map<List<int>>(
        (rsp) => rsp.statusCode != 200
            ? throw UnsupportedError(
                'Status code from coderanks is ${rsp.statusCode}')
            : rsp.bodyBytes,
      )
      .map<images.Image?>(images.decodeImage)
      .cast<images.Image>()
      .map<images.Image>((img) => images.copyResize(img, width: 495))
      .map<images.Image>((img) => images.copyCrop(img, 0, 0, 495, 196))
      .map<List<int>>(images.encodePng)
      .first;
  return shelf.Response.ok(
    bytes,
    headers: <String, String>{
      'Content-Length': bytes.length.toString(),
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=86400',
    },
  );
}
