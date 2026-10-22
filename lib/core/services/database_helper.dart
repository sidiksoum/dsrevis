import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../features/shared/data/sample_data.dart';
import 'database_factory.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dsrevis_local.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    await initializeDatabaseFactory();

    final path = kIsWeb
        ? filePath
        : join(await getDatabasesPath(), filePath);

    return await openDatabase(
      path,
      version: 9,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quiz_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          courseTitle TEXT NOT NULL,
          userId TEXT NOT NULL,
          score INTEGER NOT NULL,
          totalQuestions INTEGER NOT NULL,
          isOffline INTEGER NOT NULL,
          timestamp TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reading_history (
          courseTitle TEXT NOT NULL,
          userId TEXT NOT NULL,
          secondsRead INTEGER NOT NULL,
          lastReadTimestamp TEXT NOT NULL,
          PRIMARY KEY(courseTitle, userId)
        )
      ''');
    }
    if (oldVersion < 4) {
      try {
        await db.execute("ALTER TABLE courses ADD COLUMN userId TEXT NOT NULL DEFAULT 'guest'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE quiz_questions ADD COLUMN userId TEXT NOT NULL DEFAULT 'guest'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE quiz_history ADD COLUMN userId TEXT NOT NULL DEFAULT 'guest'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE reading_history ADD COLUMN userId TEXT NOT NULL DEFAULT 'guest'");
      } catch (_) {}
    }
    if (oldVersion < 5) {
      try {
        await db.execute("ALTER TABLE quiz_questions ADD COLUMN subjectLevel TEXT NOT NULL DEFAULT 'Sujet 1'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE quiz_questions ADD COLUMN subjectTitle TEXT NOT NULL DEFAULT 'Généralités'");
      } catch (_) {}
    }
    if (oldVersion < 6) {
      try {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS app_settings (
            id TEXT PRIMARY KEY,
            whatsappNumber TEXT NOT NULL
          )
        ''');
      } catch (_) {}
    }
    if (oldVersion < 7) {
      try {
        await db.execute("ALTER TABLE app_settings ADD COLUMN lastDatabaseUpdate TEXT NOT NULL DEFAULT ''");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE app_settings ADD COLUMN lastSyncTimestamp TEXT NOT NULL DEFAULT ''");
      } catch (_) {}
    }
    if (oldVersion < 8) {
      try {
        await db.execute("ALTER TABLE user_session ADD COLUMN country TEXT NOT NULL DEFAULT 'Côte d''Ivoire'");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE user_session ADD COLUMN antenne TEXT NOT NULL DEFAULT 'Antenne Bouaké'");
      } catch (_) {}
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_session (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        level TEXT NOT NULL,
        filiere TEXT NOT NULL,
        premium INTEGER NOT NULL,
        isActive INTEGER NOT NULL,
        country TEXT NOT NULL DEFAULT 'Côte d''Ivoire',
        antenne TEXT NOT NULL DEFAULT 'Antenne Bouaké'
      )
    ''');

    await db.execute('''
      CREATE TABLE academic_years (id TEXT PRIMARY KEY, name TEXT NOT NULL)
    ''');

    await db.execute('''
      CREATE TABLE filieres (id TEXT PRIMARY KEY, name TEXT NOT NULL)
    ''');

    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        filiere TEXT NOT NULL,
        summary TEXT NOT NULL,
        driveLink TEXT NOT NULL,
        premiumOnly INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_questions (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        courseTitle TEXT NOT NULL,
        subjectLevel TEXT NOT NULL DEFAULT 'Sujet 1',
        subjectTitle TEXT NOT NULL DEFAULT 'Généralités',
        prompt TEXT NOT NULL,
        type TEXT NOT NULL,
        options TEXT NOT NULL,
        correctAnswer TEXT NOT NULL,
        explanation TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE quiz_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseTitle TEXT NOT NULL,
        userId TEXT NOT NULL,
        score INTEGER NOT NULL,
        totalQuestions INTEGER NOT NULL,
        isOffline INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reading_history (
        courseTitle TEXT NOT NULL,
        userId TEXT NOT NULL,
        secondsRead INTEGER NOT NULL,
        lastReadTimestamp TEXT NOT NULL,
        PRIMARY KEY(courseTitle, userId)
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        id TEXT PRIMARY KEY,
        whatsappNumber TEXT NOT NULL,
        lastDatabaseUpdate TEXT NOT NULL DEFAULT '',
        lastSyncTimestamp TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<void> saveUserSession(Map<String, dynamic> user) async {
    final db = await instance.database;
    await db.insert('user_session', {
      'id': user['id'],
      'name': user['name'],
      'email': user['email'],
      'level': user['level'],
      'filiere': user['filiere'],
      'premium': (user['premium'] == true || user['premium'] == 1) ? 1 : 0,
      'isActive': (user['isActive'] == true || user['isActive'] == 1) ? 1 : 0,
      'country': user['country'] ?? "Côte d'Ivoire",
      'antenne': user['antenne'] ?? "Antenne Bouaké",
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<AppUser?> getUserSession() async {
    final db = await instance.database;
    final maps = await db.query('user_session');
    if (maps.isNotEmpty) {
      final userMap = maps.first;
      return AppUser(
        id: (userMap['id'] ?? 'guest') as String,
        name: userMap['name'] as String,
        email: userMap['email'] as String,
        level: userMap['level'] as String,
        filiere: userMap['filiere'] as String,
        premium: (userMap['premium'] as int) == 1,
        isActive: (userMap['isActive'] as int) == 1,
        country: (userMap['country'] ?? "Côte d'Ivoire") as String,
        antenne: (userMap['antenne'] ?? "Antenne Bouaké") as String,
      );
    }
    return null;
  }

  Future<void> clearUserSession() async {
    final db = await instance.database;
    await db.delete('user_session');
  }

  Future<void> saveYears(List<Map<String, dynamic>> years) async {
    final db = await instance.database;
    final batch = db.batch();
    batch.delete('academic_years');
    for (var y in years) {
      batch.insert('academic_years', y, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> saveFilieres(List<Map<String, dynamic>> filieres) async {
    final db = await instance.database;
    final batch = db.batch();
    batch.delete('filieres');
    for (var f in filieres) {
      batch.insert('filieres', f, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> saveCourses(List<Map<String, dynamic>> courses, String userId) async {
    final db = await instance.database;
    final batch = db.batch();
    batch.delete('courses', where: 'userId = ?', whereArgs: [userId]);
    for (var c in courses) {
      final rawId = (c['id'] ?? '').toString();
      final row = {
        'id': '${rawId}_$userId',
        'userId': userId,
        'title': (c['title'] ?? '').toString(),
        'category': (c['category'] ?? '').toString(),
        'filiere': (c['filiere'] ?? '').toString(),
        'summary': (c['summary'] ?? '').toString(),
        'driveLink': (c['driveLink'] ?? '').toString(),
        'premiumOnly': (c['premiumOnly'] == 1 || c['premiumOnly'] == true) ? 1 : 0,
      };
      batch.insert('courses', row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<void> saveQuizQuestions(List<Map<String, dynamic>> questions, String userId) async {
    final db = await instance.database;
    final batch = db.batch();
    batch.delete('quiz_questions', where: 'userId = ?', whereArgs: [userId]);
    for (var q in questions) {
      final rawId = (q['id'] ?? '').toString();
      final row = {
        'id': '${rawId}_$userId',
        'userId': userId,
        'courseTitle': (q['courseTitle'] ?? '').toString(),
        'subjectLevel': (q['subjectLevel'] ?? 'Sujet 1').toString(),
        'subjectTitle': (q['subjectTitle'] ?? 'Généralités').toString(),
        'prompt': (q['prompt'] ?? '').toString(),
        'type': (q['type'] ?? 'QCM').toString(),
        'options': (q['options'] ?? '[]').toString(),
        'correctAnswer': (q['correctAnswer'] ?? '').toString(),
        'explanation': (q['explanation'] ?? '').toString(),
      };
      batch.insert('quiz_questions', row, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<CourseItem>> getLocalCourses([String? userId]) async {
    final db = await instance.database;
    final res = await db.query(
      'courses',
      where: 'userId = ?',
      whereArgs: [userId ?? currentUser?.id ?? 'guest'],
    );
    return res.map((maps) => CourseItem(
      title: maps['title'] as String,
      category: maps['category'] as String,
      filiere: maps['filiere'] as String,
      summary: maps['summary'] as String,
      driveLink: maps['driveLink'] as String,
      premiumOnly: (maps['premiumOnly'] as int) == 1,
    )).toList();
  }

  Future<List<QuizQuestion>> getLocalQuizQuestions([String? userId]) async {
    final db = await instance.database;
    final res = await db.query(
      'quiz_questions',
      where: 'userId = ?',
      whereArgs: [userId ?? currentUser?.id ?? 'guest'],
    );
    return res.map((maps) {
      final List<dynamic> decodedOptions = jsonDecode(maps['options'] as String);
      return QuizQuestion(
        id: maps['id'] as String,
        courseTitle: maps['courseTitle'] as String,
        subjectLevel: (maps['subjectLevel'] ?? 'Sujet 1') as String,
        subjectTitle: (maps['subjectTitle'] ?? 'Généralités') as String,
        prompt: maps['prompt'] as String,
        type: maps['type'] as String,
        options: decodedOptions.map((e) => e.toString()).toList(),
        correctAnswer: maps['correctAnswer'] as String,
        explanation: maps['explanation'] as String,
      );
    }).toList();
  }

  Future<List<String>> getLocalCourseTitles([String? userId]) async {
    final courses = await getLocalCourses(userId);
    return courses.map((c) => c.title).toList();
  }

  Future<void> saveQuizResult(String courseTitle, int score, int total, bool isOffline, [String? userId]) async {
    final db = await instance.database;
    await db.insert('quiz_history', {
      'courseTitle': courseTitle,
      'userId': userId ?? currentUser?.id ?? 'guest',
      'score': score,
      'totalQuestions': total,
      'isOffline': isOffline ? 1 : 0,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<int> getBestScoreForCourse(String courseTitle, [String? userId]) async {
    final db = await instance.database;
    final res = await db.query(
      'quiz_history',
      columns: ['score', 'totalQuestions'],
      where: 'courseTitle = ? AND userId = ?',
      whereArgs: [courseTitle, userId ?? currentUser?.id ?? 'guest'],
    );
    if (res.isEmpty) return 0;
    int maxPct = 0;
    for (var r in res) {
      int score = r['score'] as int;
      int total = r['totalQuestions'] as int;
      if (total > 0) {
        int pct = ((score / total) * 100).toInt();
        if (pct > maxPct) maxPct = pct;
      }
    }
    return maxPct;
  }

  Future<int> getBestScorePercentageForCourse(String courseTitle, [String? userId]) async {
    return await getBestScoreForCourse(courseTitle, userId);
  }

  Future<Map<String, int>> getAllBestScores([String? userId]) async {
    final db = await instance.database;
    final res = await db.query(
      'quiz_history',
      where: 'userId = ?',
      whereArgs: [userId ?? currentUser?.id ?? 'guest'],
    );
    final Map<String, int> scores = {};
    for (var r in res) {
      String title = r['courseTitle'] as String;
      int score = r['score'] as int;
      int total = r['totalQuestions'] as int;
      if (total > 0) {
        int pct = ((score / total) * 100).toInt();
        if (!scores.containsKey(title) || pct > scores[title]!) {
          scores[title] = pct;
        }
      }
    }
    return scores;
  }

  Future<void> addReadingTime(String courseTitle, int seconds, [String? userId]) async {
    final db = await instance.database;
    final uId = userId ?? currentUser?.id ?? 'guest';
    final existing = await db.query(
      'reading_history',
      where: 'courseTitle = ? AND userId = ?',
      whereArgs: [courseTitle, uId],
    );
    if (existing.isEmpty) {
      await db.insert('reading_history', {
        'courseTitle': courseTitle,
        'userId': uId,
        'secondsRead': seconds,
        'lastReadTimestamp': DateTime.now().toIso8601String(),
      });
    } else {
      int currentSec = existing.first['secondsRead'] as int;
      await db.update(
        'reading_history',
        {
          'secondsRead': currentSec + seconds,
          'lastReadTimestamp': DateTime.now().toIso8601String(),
        },
        where: 'courseTitle = ? AND userId = ?',
        whereArgs: [courseTitle, uId],
      );
    }
  }

  Future<int> getReadingProgressPercentage(String courseTitle, [String? userId]) async {
    final db = await instance.database;
    final res = await db.query(
      'reading_history',
      where: 'courseTitle = ? AND userId = ?',
      whereArgs: [courseTitle, userId ?? currentUser?.id ?? 'guest'],
    );
    if (res.isEmpty) return 0;
    int seconds = res.first['secondsRead'] as int;
    const int targetSeconds = 300;
    int pct = ((seconds / targetSeconds) * 100).toInt();
    return pct > 100 ? 100 : pct;
  }

  Future<int> getTotalReadCoursesCount([String? userId]) async {
    final db = await instance.database;
    final res = await db.query(
      'reading_history',
      where: 'secondsRead >= ? AND userId = ?',
      whereArgs: [30, userId ?? currentUser?.id ?? 'guest'],
    );
    return res.length;
  }

  Future<int> getRevisionDaysStreak([String? userId]) async {
    final db = await instance.database;
    final res = await db.query(
      'reading_history',
      columns: ['lastReadTimestamp'],
      where: 'userId = ?',
      whereArgs: [userId ?? currentUser?.id ?? 'guest'],
    );
    return res.isNotEmpty ? 1 : 0;
  }

  Future<int> getOfflineQuizCount([String? userId]) async {
    final db = await instance.database;
    final res = await db.query(
      'quiz_history',
      where: 'userId = ? AND isOffline = 1',
      whereArgs: [userId ?? currentUser?.id ?? 'guest'],
    );
    return res.length;
  }

  Future<List<Map<String, dynamic>>> getTop3BestCourses([String? userId]) async {
    final scores = await getAllBestScores(userId);
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => {'title': e.key, 'score': e.value}).toList();
  }

  Future<List<Map<String, dynamic>>> getQuizHistory([String? userId]) async {
    final db = await instance.database;
    return await db.query(
      'quiz_history',
      where: 'userId = ?',
      whereArgs: [userId ?? currentUser?.id ?? 'guest'],
      orderBy: 'timestamp DESC',
    );
  }

  Future<void> saveWhatsappNumber(String number) async {
    final db = await instance.database;
    await db.insert(
      'app_settings',
      {'id': 'main', 'whatsappNumber': number},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> getWhatsappNumber() async {
    final db = await instance.database;
    final res = await db.query('app_settings', where: 'id = ?', whereArgs: ['main']);
    if (res.isNotEmpty && res.first['whatsappNumber'] != null) {
      return res.first['whatsappNumber'] as String;
    }
    return '2250798646697';
  }

  Future<void> saveLastDatabaseUpdate(String updateTimestamp) async {
    final db = await instance.database;
    await db.rawInsert('''
      INSERT INTO app_settings (id, whatsappNumber, lastDatabaseUpdate)
      VALUES ('main', '2250798646697', ?)
      ON CONFLICT(id) DO UPDATE SET lastDatabaseUpdate = excluded.lastDatabaseUpdate
    ''', [updateTimestamp]);
  }

  Future<String> getLastDatabaseUpdate() async {
    final db = await instance.database;
    final res = await db.query('app_settings', where: 'id = ?', whereArgs: ['main']);
    if (res.isNotEmpty && res.first['lastDatabaseUpdate'] != null) {
      return res.first['lastDatabaseUpdate'] as String;
    }
    return '';
  }

  Future<void> saveLastSyncTimestamp(String syncTimestamp) async {
    final db = await instance.database;
    await db.rawInsert('''
      INSERT INTO app_settings (id, whatsappNumber, lastSyncTimestamp)
      VALUES ('main', '2250798646697', ?)
      ON CONFLICT(id) DO UPDATE SET lastSyncTimestamp = excluded.lastSyncTimestamp
    ''', [syncTimestamp]);
  }

  Future<String> getLastSyncTimestamp() async {
    final db = await instance.database;
    final res = await db.query('app_settings', where: 'id = ?', whereArgs: ['main']);
    if (res.isNotEmpty && res.first['lastSyncTimestamp'] != null) {
      return res.first['lastSyncTimestamp'] as String;
    }
    return '';
  }

  Future<Map<String, String>> getSyncStatus() async {
    final lastDbUpdate = await getLastDatabaseUpdate();
    final lastSync = await getLastSyncTimestamp();
    return {
      'lastDatabaseUpdate': lastDbUpdate,
      'lastSyncTimestamp': lastSync,
    };
  }
}
