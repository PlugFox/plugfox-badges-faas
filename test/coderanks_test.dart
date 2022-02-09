import 'package:plugfox_badges_faas/src/coderanks.dart';
import 'package:test/test.dart';

void main() => group(
      'Coderanks',
      () {
        test('getDartRankFromCodeRank', () async {
          final result = await getDartRankFromCodeRank();
          expect(result, const TypeMatcher<Rank>());
          expect(result.score >= 0, isTrue);
          expect(result.rank >= 0, isTrue);
        });
      },
    );
