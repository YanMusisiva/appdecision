import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/models.dart';

class LocalStore {
  Database? _database;

  Future<Database> get database async => _database ??= await openDatabase(
    p.join(await getDatabasesPath(), 'eclat.db'),
    version: 2,
    onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    onCreate: (db, version) async {
      await db.execute(
        'CREATE TABLE sessions (quiz_id TEXT PRIMARY KEY, version INTEGER NOT NULL, current_index INTEGER NOT NULL, answers_json TEXT NOT NULL, updated_at TEXT NOT NULL)',
      );
      await db.execute(
        'CREATE TABLE results (id TEXT PRIMARY KEY, kind TEXT NOT NULL, version INTEGER NOT NULL, created_at TEXT NOT NULL, scores_json TEXT NOT NULL, label TEXT)',
      );
      await db.execute(
        'CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      );
      await db.execute('CREATE TABLE favorites (id TEXT PRIMARY KEY)');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS favorites (id TEXT PRIMARY KEY)',
        );
      }
    },
  );

  Future<void> saveSession(
    String quizId,
    int version,
    int index,
    Map<String, int> answers,
  ) async {
    final db = await database;
    await db.transaction(
      (txn) => txn.insert('sessions', {
        'quiz_id': quizId,
        'version': version,
        'current_index': index,
        'answers_json': jsonEncode(answers),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace),
    );
  }

  Future<({int index, Map<String, int> answers})?> loadSession(
    String quizId,
    int version,
  ) async {
    final rows = await (await database).query(
      'sessions',
      where: 'quiz_id = ? AND version = ?',
      whereArgs: [quizId, version],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final decoded = jsonDecode(
      rows.first['answers_json']! as String,
    ) as Map<String, dynamic>;
    return (
      index: rows.first['current_index']! as int,
      answers: decoded.map((k, v) => MapEntry(k, v as int)),
    );
  }

  Future<void> clearSession(String quizId) async => (await database).delete(
    'sessions',
    where: 'quiz_id = ?',
    whereArgs: [quizId],
  );

  Future<void> addResult(SavedResult result) async =>
      (await database).insert('results', {
        'id': result.id,
        'kind': result.kind.name,
        'version': result.version,
        'created_at': result.createdAt.toUtc().toIso8601String(),
        'scores_json': jsonEncode(result.scores),
        'label': result.label,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

  Future<List<SavedResult>> results() async {
    final rows = await (await database).query(
      'results',
      orderBy: 'created_at DESC',
    );
    return rows.map(_resultFromRow).toList();
  }

  SavedResult _resultFromRow(Map<String, Object?> row) {
    final decoded =
        (jsonDecode(row['scores_json']! as String) as Map<String, dynamic>).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        );
    return SavedResult(
      id: row['id']! as String,
      kind: QuizKind.values.byName(row['kind']! as String),
      version: row['version']! as int,
      createdAt: DateTime.parse(row['created_at']! as String).toLocal(),
      scores: decoded,
      label: row['label'] as String?,
    );
  }

  Future<void> deleteResult(String id) async =>
      (await database).delete('results', where: 'id = ?', whereArgs: [id]);
  Future<String?> setting(String key) async {
    final rows = await (await database).query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first['value'] as String;
  }

  Future<void> setSetting(String key, String value) async =>
      (await database).insert('settings', {
        'key': key,
        'value': value,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
  Future<Set<String>> favorites() async => (await database)
      .query('favorites')
      .then((rows) => rows.map((r) => r['id']! as String).toSet());
  Future<void> toggleFavorite(String id) async {
    final db = await database;
    final exists =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM favorites WHERE id = ?', [
            id,
          ]),
        )! >
        0;
    exists
        ? await db.delete('favorites', where: 'id = ?', whereArgs: [id])
        : await db.insert('favorites', {'id': id});
  }

  Future<String> exportJson() async {
    final db = await database;
    return const JsonEncoder.withIndent('  ').convert({
      'schemaVersion': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'results': await db.query('results'),
      'settings': await db.query('settings'),
      'favorites': await db.query('favorites'),
    });
  }

  Future<int> importJson(String source) async {
    if (source.length > 2 * 1024 * 1024) {
      throw const FormatException('Le fichier dépasse la limite de 2 Mo.');
    }
    final root = jsonDecode(source);
    if (root is! Map<String, dynamic> ||
        root['schemaVersion'] != 1 ||
        root['results'] is! List) {
      throw const FormatException('Format d’export non reconnu.');
    }
    final parsed = <Map<String, Object?>>[];
    for (final item in root['results'] as List) {
      if (item is! Map ||
          item['id'] is! String ||
          item['kind'] is! String ||
          !QuizKind.values.map((e) => e.name).contains(item['kind']) ||
          item['version'] is! int ||
          item['created_at'] is! String ||
          item['scores_json'] is! String) {
        throw const FormatException('Un résultat importé est invalide.');
      }
      final scores = jsonDecode(item['scores_json'] as String);
      if (scores is! Map ||
          scores.values.any((v) => v is! num || v < 0 || v > 100)) {
        throw const FormatException('Des scores importés sont invalides.');
      }
      parsed.add(Map<String, Object?>.from(item));
    }
    final db = await database;
    var added = 0;
    await db.transaction((txn) async {
      for (final row in parsed) {
        final id = await txn.insert(
          'results',
          row,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        if (id != 0) added++;
      }
    });
    return added;
  }

  Future<void> deleteAll() async {
    final db = await database;
    await db.transaction((txn) async {
      for (final table in ['sessions', 'results', 'settings', 'favorites']) {
        await txn.delete(table);
      }
    });
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
