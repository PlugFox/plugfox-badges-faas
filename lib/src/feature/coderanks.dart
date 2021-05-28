import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

typedef JsonMap = Map<String, Object?>;

Future<Rank> getDartRankFromCodeRank() async {
  const user = 'plugfox';
  const badgesUrl = 'https://api.codersrank.io/v2/users/$user/badges';
  //final from = DateTime.now().subtract(Duration(days: 366));
  //final historyUrl =
  //    'https://api.codersrank.io/v2/users/$user/tech_score_history?from='
  //    '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}T00:00:00Z';
  final client = http.Client();

  http.Response response;
  JsonMap json;
  Iterable<Object?> collection;
  // Получим информацию из баджа
  response = await client
      .get(Uri.parse(badgesUrl))
      .timeout(const Duration(seconds: 5));
  json = jsonDecode(response.body) as JsonMap;
  collection = json['badges'] as Iterable<Object?>;
  final dartBadge = collection
      .whereType<JsonMap>()
      .firstWhere((m) => m['language'] == 'Dart');
  final rank = dartBadge['rank'] as int;
  final location = dartBadge['location_name'] as String;

  // Получим информацию из истории
  //response = await client
  //    .get(Uri.parse(historyUrl))
  //    .timeout(const Duration(seconds: 5));
  //json = jsonDecode(response.body) as JsonMap;
  //collection = json['scores'] as Iterable<Object?>;
  //final score = collection
  //    .whereType<JsonMap>()
  //    .map<double>((e) =>
  //        (e['languages'] as Iterable<Object?>).whereType<JsonMap>().firstWhere(
  //              (e) => e['language'] == 'Dart',
  //              orElse: () => <String, Object?>{},
  //            )['score'] as double? ??
  //        .0)
  //    .reduce(math.max);
  return Rank(
    location: location,
    language: 'Dart',
    rank: rank,
    score: 0,
  );
}

@immutable
class Rank {
  final int rank;
  final String location;
  final double score;
  final String language;

  Rank({
    required this.rank,
    required this.location,
    required this.score,
    required this.language,
  });

  JsonMap toJson() => <String, Object>{
        'rank': rank,
        'location': location,
        'score': score,
        'language': language,
      };
}

String generateTopRankDartBadge(String rank, String location) => '''
<svg xmlns="http://www.w3.org/2000/svg" width="126" height="195.5" viewBox="0 0 126 195.5">
<rect x="0.5" y="0.5" width="125" height="194.5" rx="5"
style="fill:#fffefe;stroke:#e4e2e2;stroke-linecap:round;stroke-linejoin:round"/>
<text
transform="translate(35.9 42.6)"
style="font-size:21px;fill:#5194f0;font-family:SegoeUI-Bold, Segoe UI;font-weight:700">
<tspan style="letter-spacing:-0.08984375em">T</tspan>
<tspan x="10.4" y="0">op $rank</tspan>
</text>
<text
transform="translate(61 98.4)"
style="font-size:21px;fill:#5194f0;font-family:SegoeUI-Bold, Segoe UI;font-weight:700">Da<tspan x="26.8" y="0"
style="letter-spacing:0.02880859375em">r</tspan>
<tspan x="35.7" y="0">t</tspan>
</text>
<text
transform="translate(12.5 141.5)"
style="font-size:21px;fill:#5194f0;font-family:SegoeUI-Bold, Segoe UI;font-weight:700">De<tspan x="26.8" y="0"
style="letter-spacing:-0.009765625em">v</tspan>
<tspan x="38" y="0">eloper</tspan>
<tspan x="19.4" y="25.2">$location</tspan>
</text>
<path d="M31.4,108.8,29.6,107l-4.4-4.4a7.5,7.5,0,0,1-1.5-2.4,5,5,0,0,1-.4-1.3h.2l2.4.8,3.5,1.3,6.3,2.2,2.3.8,3.9,1.4h.2l2.9-1.3,1.7-.8c-.3,1-.7,2-1,3a14.2,14.2,0,0,1-.7,2.2v.2Z"
style="fill:#55dcc9"/>
<path d="M46.7,103.4l-1.7.8-2.9,1.3h-.2L38,104.1l-2.3-.8-6.3-2.2-3.5-1.3L23.5,99h-.3a10.6,10.6,0,0,1-.2-2.5V79.8l1-.7,9.9-6.5a1.8,1.8,0,0,1,2-.2l1.1.8,4.1,4,.2.3a24.1,24.1,0,0,1,.8,2.5H23.2l23.3,23.3Z"
style="fill:#00d1b7"/>
<path d="M46.7,103.4h-.2L23.2,80h19v.2a8.8,8.8,0,0,1,.5,1.5l1.1,2.9c.6,1.9,1.3,3.7,1.9,5.6s.8,2,1.1,3l1.8,5a1.7,1.7,0,0,1,0,1,25.2,25.2,0,0,0-1.5,3.4,3,3,0,0,0-.4.8Z"
style="fill:#0082c7"/>
<path d="M46.7,103.4a3,3,0,0,1,.4-.8,25.2,25.2,0,0,1,1.5-3.4,1.7,1.7,0,0,0,0-1l-1.8-5c-.3-1-.7-2-1.1-3s-1.3-3.7-1.9-5.6l-1.1-2.9a8.8,8.8,0,0,0-.5-1.5V80a6.4,6.4,0,0,1,1.9.8,6.9,6.9,0,0,1,2.4,1.8h.1l4.5,4.5.6.6c.1.1.1.1.1.3v13.5c0,.2-.1.2-.2.3l-4.7,1.5Z"
style="fill:#01a4e3"/>
<path d="M23,79.8V96.3a10.6,10.6,0,0,0,.2,2.5h0L20.7,98h-.2l-4.2-4.2a3.1,3.1,0,0,1-.9-1.8,1.7,1.7,0,0,1,.4-1.2l1.4-2.2,5.7-8.6Z"
style="fill:#0082c7"/>
</svg>
''';
