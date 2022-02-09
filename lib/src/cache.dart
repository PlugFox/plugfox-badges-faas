import 'dart:async';
import 'dart:typed_data';

import 'package:gcloud/storage.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:l/l.dart';
import 'package:plugfox_badges_faas/src/client.dart';

const String _kProject = 'plugfox-badges-faas';
const String _kBucketName = 'plugfox-badges';

/// Кэш хранящий в себе результаты предидущего вычисления
final Map<String, List<int>?> _dataCache = <String, List<int>?>{};

/// Google Cloud Storage проекта
Bucket? __bucket;
Future<Bucket> get _bucket async => __bucket ??= await auth
    .clientViaMetadataServer(baseClient: httpClient)
    .then<Storage>((client) => Storage(client, _kProject))
    .then<Bucket>((storage) => storage.bucket(_kBucketName));

FutureOr<List<int>?> getCache(String objectName) async =>
    _dataCache[objectName] ??= await _bucket.then<List<int>?>((bucket) async {
      final ObjectInfo info;
      try {
        info = await bucket.info(objectName);
      } on Exception {
        l.w('Ошибка получения кэша "gs://$_kBucketName/$objectName", вероятно объект не существует');
        return null;
      }
      final bytesBuilder = BytesBuilder();
      if (info.updated.add(const Duration(days: 1)).isBefore(DateTime.now())) {
        return null;
      }
      await bucket.read(objectName).forEach(bytesBuilder.add);
      l.i('Объект "gs://$_kBucketName/$objectName" успешно восстановлен из кэша Cloud Storage');
      return bytesBuilder.takeBytes();
    });

Future<void> setCache(String objectName, List<int> bytes) async {
  _dataCache['objectName'] = bytes;
  await _bucket.then<void>((bucket) => bucket.writeBytes(objectName, bytes));
  l.i('Объект "gs://$_kBucketName/$objectName" успешно помещен кэш Cloud Storage');
}
