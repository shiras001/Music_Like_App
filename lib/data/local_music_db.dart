import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/entities.dart';

class LocalMusicDb {
  static final LocalMusicDb instance = LocalMusicDb._internal();
  static const _dbName = 'music_like.db';
  static const _dbVersion = 1;

  Database? _db;

  LocalMusicDb._internal();

  Future<Database> get database async {
    _db ??= await _openDb();
    return _db!;
  }

  Future<Database> _openDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, _dbName);
    return openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tracks (
            id TEXT PRIMARY KEY,
            file_path TEXT UNIQUE,
            title TEXT,
            artist TEXT,
            album TEXT,
            duration_ms INTEGER,
            file_format TEXT,
            artwork_thumb_path TEXT,
            lyrics_path TEXT,
            is_local INTEGER,
            parsed_at INTEGER,
            parse_state INTEGER
          );
        ''');
        await db.execute('CREATE INDEX idx_tracks_path ON tracks(file_path);');
      },
    );
  }

  Future<void> upsertSongs(List<Song> songs, {int parseState = 1}) async {
    if (songs.isEmpty) return;
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final batch = db.batch();
    for (final song in songs) {
      final filePath = song.localPath ?? song.id;
      batch.insert(
        'tracks',
        {
          'id': song.id,
          'file_path': filePath,
          'title': song.title,
          'artist': song.artist,
          'album': song.album,
          'duration_ms': song.duration.inMilliseconds,
          'file_format': song.fileFormat,
          'artwork_thumb_path': song.artworkUrl,
          'lyrics_path': song.lyricsPath,
          'is_local': song.isLocal ? 1 : 0,
          'parsed_at': parseState == 1 ? now : null,
          'parse_state': parseState,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Song>> fetchAllSongs() async {
    final db = await database;
    final rows = await db.query('tracks', orderBy: 'title COLLATE NOCASE');
    return rows.map(_mapRowToSong).toList();
  }

  Future<Song?> getSongById(String id) async {
    final db = await database;
    final rows = await db.query('tracks', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    return _mapRowToSong(rows.first);
  }

  Future<void> updateSongMetadata(String songId, Map<String, dynamic> data) async {
    final db = await database;
    if (data.isEmpty) return;

    final updateData = <String, dynamic>{};
    if (data['title'] != null) updateData['title'] = data['title'];
    if (data['artist'] != null) updateData['artist'] = data['artist'];
    if (data['album'] != null) updateData['album'] = data['album'];
    if (data['artworkUrl'] != null) updateData['artwork_thumb_path'] = data['artworkUrl'];
    if (data['lyricsPath'] != null) updateData['lyrics_path'] = data['lyricsPath'];
    if (data['fileFormat'] != null) updateData['file_format'] = data['fileFormat'];
    if (data['durationMs'] != null) updateData['duration_ms'] = data['durationMs'];

    if (updateData.isEmpty) return;
    updateData['parse_state'] = 1;
    updateData['parsed_at'] = DateTime.now().millisecondsSinceEpoch;

    await db.update('tracks', updateData, where: 'id = ?', whereArgs: [songId]);
  }

  Future<void> deleteSong(String songId) async {
    final db = await database;
    await db.delete('tracks', where: 'id = ?', whereArgs: [songId]);
  }

  Future<void> clearLibrary() async {
    final db = await database;
    await db.delete('tracks');
  }

  Future<Set<String>> getExistingLocalPaths(List<String> paths) async {
    if (paths.isEmpty) return {};
    final db = await database;
    final existing = <String>{};

    const chunkSize = 900; // SQLite parameter limit safety
    for (var i = 0; i < paths.length; i += chunkSize) {
      final chunk = paths.sublist(i, i + chunkSize > paths.length ? paths.length : i + chunkSize);
      final placeholders = List.filled(chunk.length, '?').join(',');
      final rows = await db.query(
        'tracks',
        columns: ['file_path'],
        where: 'file_path IN ($placeholders)',
        whereArgs: chunk,
      );
      for (final row in rows) {
        final path = row['file_path'] as String?;
        if (path != null) existing.add(path);
      }
    }
    return existing;
  }

  Future<List<String>> getUnparsedFilePaths({int limit = 100}) async {
    final db = await database;
    final rows = await db.query(
      'tracks',
      columns: ['file_path'],
      where: 'parse_state = ? OR parse_state IS NULL',
      whereArgs: [0],
      limit: limit,
    );
    return rows
        .map((row) => row['file_path'] as String?)
        .whereType<String>()
        .toList();
  }

  Song _mapRowToSong(Map<String, dynamic> row) {
    return Song(
      id: row['id'] as String,
      title: (row['title'] as String?) ?? 'Unknown Title',
      artist: (row['artist'] as String?) ?? 'Unknown Artist',
      album: (row['album'] as String?) ?? 'Unknown Album',
      artworkUrl: row['artwork_thumb_path'] as String?,
      duration: Duration(milliseconds: (row['duration_ms'] as int?) ?? 0),
      fileFormat: (row['file_format'] as String?) ?? 'UNKNOWN',
      isLocal: (row['is_local'] as int? ?? 1) == 1,
      localPath: row['file_path'] as String?,
      lyricsPath: row['lyrics_path'] as String?,
    );
  }
}

/// Optional clean-up helper for legacy copied files.
Future<void> deleteLegacyCopiedMusicDir() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final musicDir = Directory(p.join(dir.path, 'Music'));
    if (await musicDir.exists()) {
      await musicDir.delete(recursive: true);
    }
  } catch (_) {
    // ignore cleanup errors
  }
}
