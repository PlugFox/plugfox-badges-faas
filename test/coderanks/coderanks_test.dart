import 'package:test/test.dart';

import '../../lib/src/feature/coderanks.dart';

void coderanksTest() => group(
      'Coderanks',
      () {
        test('getDartRankFromCodeRank', () async {
          final result = await getDartRankFromCodeRank();
          expect(result, TypeMatcher<Rank>());
          expect(result.score >= 0, isTrue);
          expect(result.rank >= 0, isTrue);
        });
      },
    );
