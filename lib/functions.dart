import 'dart:async';
import 'dart:convert';

import 'package:functions_framework/functions_framework.dart';
import 'package:l/l.dart';
import 'package:plugfox_badges_faas/src/cache.dart';
import 'package:plugfox_badges_faas/src/coderanks.dart';
import 'package:shelf/shelf.dart' as shelf;

/// Таймаут
const int _timeout = 15;

@CloudFunction(target: 'function')
Future<shelf.Response> plugfoxBadges(shelf.Request request) =>
    Future<shelf.Response>.sync(() async {
      Future<List<int>> getBadge() => getDartRankFromCodeRank().then<List<int>>(
            (rank) => generateTopRankDartBadge(
              rank.rank.toString(),
              rank.location,
            ).codeUnits,
          );
      const badgeName = 'coders_rank.svg';
      var rankBytes = await getCache(badgeName);
      if (rankBytes == null) {
        rankBytes = await getBadge();
        // ignore: unawaited_futures
        setCache(badgeName, rankBytes)
            .catchError((Object error, StackTrace stackTrace) {
          l.e('Ошибка помещения в кэш полученных данных: "$error"', stackTrace);
          return;
        });
      }
      return shelf.Response.ok(
        rankBytes,
        headers: <String, String>{
          'Content-Length': rankBytes.length.toString(),
          'Content-Type': 'image/svg+xml; charset=utf-8',
          'Cache-Control': 'public, max-age=86400',
        },
      );
    }).catchError((Object error, StackTrace stackTrace) {
      final bytes = jsonEncode(<String, Object>{
        'error': error.toString(),
      }).codeUnits;
      l.e('Произошла непредвиденная ошибка "$error"', stackTrace);
      return Future<shelf.Response>.value(
        shelf.Response.internalServerError(
          body: bytes,
          headers: <String, String>{
            'Content-Length': bytes.length.toString(),
            'Content-Type': 'application/json; charset=utf-8',
            'Cache-Control': 'no-cache',
          },
        ),
      );
    }).timeout(
      const Duration(seconds: _timeout),
      onTimeout: () {
        final body = jsonEncode(<String, Object>{
          'error':
              'TimeoutException: The operation has timed-out in $_timeout sec.',
        }).codeUnits;
        l.e('Превышено время ожидания ответа на запрос');
        return shelf.Response.internalServerError(
          body: body,
          headers: <String, String>{
            'Content-Length': body.length.toString(),
            'Content-Type': 'application/json; charset=utf-8',
            'Cache-Control': 'no-cache',
          },
        );
      },
    );
