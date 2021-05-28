import 'dart:async';
import 'dart:convert';

import 'package:functions_framework/functions_framework.dart';
import 'package:shelf/shelf.dart' as shelf;

import 'src/router/router.dart';

@CloudFunction(target: 'function')
Future<shelf.Response> plugfoxBadges(shelf.Request request) =>
    router(request).timeout(
      const Duration(seconds: 25),
      onTimeout: () {
        final body = jsonEncode(<String, Object>{
          'error': 'TimeoutException: The operation has timed-out in 25 sec.',
        }).codeUnits;
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
