import 'models.dart';

class ScoreEngine {
  const ScoreEngine();

  ScoreResult calculate(List<Question> questions, Map<String, int> answers) {
    final totals = <String, double>{};
    final counts = <String, int>{};
    final expected = <String, int>{};
    for (final question in questions) {
      expected.update(question.dimension, (v) => v + 1, ifAbsent: () => 1);
      final answer = answers[question.id];
      if (answer == null || answer < 1 || answer > 5) continue;
      final oriented = question.reversed ? 6 - answer : answer;
      totals.update(
        question.dimension,
        (v) => v + oriented,
        ifAbsent: () => oriented.toDouble(),
      );
      counts.update(question.dimension, (v) => v + 1, ifAbsent: () => 1);
    }
    final scores = <String, double>{};
    final incomplete = <String>{};
    for (final entry in expected.entries) {
      final count = counts[entry.key] ?? 0;
      if (count != entry.value) incomplete.add(entry.key);
      if (count > 0) {
        final mean = totals[entry.key]! / count;
        scores[entry.key] = ((mean - 1) / 4) * 100;
      }
    }
    return ScoreResult(scores: scores, incomplete: incomplete);
  }

  PersonalityResult personality(
    List<Question> questions,
    Map<String, int> answers,
  ) {
    final raw = calculate(questions, answers);
    final letters = <String, String?>{};
    final neutral = <String>{};
    final soft = <String>{};
    for (final axis in const ['EI', 'SN', 'TF', 'JP']) {
      final score = raw.scores[axis];
      if (score == null || raw.incomplete.contains(axis) || score == 50) {
        letters[axis] = null;
        neutral.add(axis);
      } else {
        letters[axis] = score > 50 ? axis[0] : axis[1];
        if (score >= 45 && score <= 55) soft.add(axis);
      }
    }
    return PersonalityResult(
      axes: raw.scores,
      letters: letters,
      neutralAxes: neutral,
      softAxes: soft,
    );
  }
}
