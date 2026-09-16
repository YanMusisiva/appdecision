enum QuizKind { personality, intelligences }

class Question {
  const Question({
    required this.id,
    required this.quizId,
    required this.dimension,
    required this.text,
    required this.version,
    this.pole,
    this.reversed = false,
  });

  final String id;
  final String quizId;
  final String dimension;
  final String text;
  final int version;
  final String? pole;
  final bool reversed;
}

class ScoreResult {
  const ScoreResult({required this.scores, required this.incomplete});
  final Map<String, double> scores;
  final Set<String> incomplete;
}

class PersonalityResult {
  const PersonalityResult({
    required this.axes,
    required this.letters,
    required this.neutralAxes,
    required this.softAxes,
  });
  final Map<String, double> axes;
  final Map<String, String?> letters;
  final Set<String> neutralAxes;
  final Set<String> softAxes;

  String? get typeCode {
    const order = ['EI', 'SN', 'TF', 'JP'];
    if (order.any((axis) => letters[axis] == null)) return null;
    return order.map((axis) => letters[axis]).join();
  }

  List<String> get possibleTypes {
    var values = <String>[''];
    for (final axis in const ['EI', 'SN', 'TF', 'JP']) {
      final options = letters[axis] == null ? axis.split('') : [letters[axis]!];
      values = [
        for (final prefix in values)
          for (final value in options) '$prefix$value',
      ];
    }
    return values;
  }
}

class SavedResult {
  const SavedResult({
    required this.id,
    required this.kind,
    required this.version,
    required this.createdAt,
    required this.scores,
    this.label,
  });
  final String id;
  final QuizKind kind;
  final int version;
  final DateTime createdAt;
  final Map<String, double> scores;
  final String? label;
}
