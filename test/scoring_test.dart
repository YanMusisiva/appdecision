import 'package:eclat_se_connaitre/content/content.dart';
import 'package:eclat_se_connaitre/core/models.dart';
import 'package:eclat_se_connaitre/core/scoring.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = ScoreEngine();
  test('volumes, dimensions et identifiants', () {
    expect(personalityQuestions, hasLength(80));
    expect(intelligenceQuestions, hasLength(56));
    expect(typeSummaries, hasLength(16));
    expect(intelligenceLabels, hasLength(7));
    final all = [...personalityQuestions, ...intelligenceQuestions];
    expect(all.map((q) => q.id).toSet(), hasLength(136));
    for (final axis in ['EI', 'SN', 'TF', 'JP']) {
      final qs = personalityQuestions.where((q) => q.dimension == axis);
      expect(qs, hasLength(20));
      expect(qs.where((q) => q.pole == axis[0]), hasLength(10));
      expect(qs.where((q) => q.pole == axis[1]), hasLength(10));
    }
  });
  test('cotation normale, inversée, extrêmes et invalides', () {
    const qs = [
      Question(id: 'a', quizId: 'x', dimension: 'D', text: '', version: 1),
      Question(
        id: 'b',
        quizId: 'x',
        dimension: 'D',
        text: '',
        version: 1,
        reversed: true,
      ),
    ];
    expect(engine.calculate(qs, {'a': 5, 'b': 1}).scores['D'], 100);
    expect(engine.calculate(qs, {'a': 1, 'b': 5}).scores['D'], 0);
    final invalid = engine.calculate(qs, {'a': 0, 'b': 6});
    expect(invalid.scores, isEmpty);
    expect(invalid.incomplete, contains('D'));
  });
  test('égalité et profil uniforme ne forcent aucune lettre', () {
    final ans = {for (final q in personalityQuestions) q.id: 3};
    final r = engine.personality(personalityQuestions, ans);
    expect(r.typeCode, isNull);
    expect(r.possibleTypes, hasLength(16));
    expect(r.neutralAxes, hasLength(4));
  });
  test('les 16 combinaisons sont générées', () {
    final generated = <String>{};
    for (var mask = 0; mask < 16; mask++) {
      final ans = <String, int>{};
      for (final q in personalityQuestions) {
        final n = ['EI', 'SN', 'TF', 'JP'].indexOf(q.dimension),
            ref = mask & (1 << n) != 0;
        ans[q.id] = ref ? (q.reversed ? 1 : 5) : (q.reversed ? 5 : 1);
      }
      generated.add(engine.personality(personalityQuestions, ans).typeCode!);
    }
    expect(generated, containsAll(typeSummaries.keys));
    expect(generated, hasLength(16));
  });
  test('dimensions incomplètes signalées', () {
    final r = engine.calculate(personalityQuestions, {
      personalityQuestions.first.id: 4,
    });
    expect(r.incomplete, containsAll(['EI', 'SN', 'TF', 'JP']));
  });
}
