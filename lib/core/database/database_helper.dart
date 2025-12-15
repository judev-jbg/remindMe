// lib/core/database/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Helper para gestionar la base de datos SQLite
class DatabaseHelper {
  static const String _databaseName = 'remindme.db';
  static const int _databaseVersion = 2;

  // Nombres de tablas
  static const String tableEventos = 'eventos';
  static const String tableRecordatoriosEnviados = 'recordatorios_enviados';
  static const String tableNotificacionesLog = 'notificaciones_log';

  // Singleton
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  /// Obtiene la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea las tablas en la primera ejecución
  Future<void> _onCreate(Database db, int version) async {
    // Tabla de eventos
    await db.execute('''
      CREATE TABLE $tableEventos (
        id TEXT PRIMARY KEY,
        nombre TEXT NOT NULL,
        fecha INTEGER NOT NULL,
        tipo TEXT NOT NULL CHECK(tipo IN ('cumpleanos', 'mesario', 'aniversario', 'otro')),
        notas TEXT,
        hora_evento INTEGER,
        
        tiene_recordatorio INTEGER NOT NULL DEFAULT 0,
        estado TEXT NOT NULL DEFAULT 'habilitado' CHECK(estado IN ('habilitado', 'deshabilitado')),
        tiempo_aviso_antes TEXT CHECK(tiempo_aviso_antes IN ('cinco_minutos', 'quince_minutos', 'treinta_minutos', 'una_hora', 'dos_horas')),

        fecha_hora_inicial_recordatorio INTEGER,
        tipo_recurrencia TEXT CHECK(tipo_recurrencia IN ('ninguna', 'diaria', 'semanal', 'mensual', 'anual')),
        intervalo INTEGER,
        dias_semana TEXT,
        fecha_finalizacion INTEGER,
        max_ocurrencias INTEGER,
        
        fecha_creacion INTEGER NOT NULL,
        fecha_actualizacion INTEGER NOT NULL
      )
    ''');

    // Tabla de recordatorios enviados
    await db.execute('''
      CREATE TABLE $tableRecordatoriosEnviados (
        id TEXT PRIMARY KEY,
        evento_id TEXT NOT NULL,
        fecha_hora_enviado INTEGER NOT NULL,
        fue_visto INTEGER NOT NULL DEFAULT 0,
        tipo TEXT NOT NULL CHECK(tipo IN ('push', 'local')),
        FOREIGN KEY (evento_id) REFERENCES $tableEventos(id) ON DELETE CASCADE
      )
    ''');

    // Tabla de notificaciones log
    await db.execute('''
      CREATE TABLE $tableNotificacionesLog (
        id TEXT PRIMARY KEY,
        tipo TEXT NOT NULL CHECK(tipo IN ('eventoCreado', 'eventoEditado', 'eventoEliminado', 'recordatorioEnviado', 'timelineGenerado')),
        titulo TEXT NOT NULL,
        detalle TEXT NOT NULL,
        fecha_hora INTEGER NOT NULL,
        marcada INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Índices para optimizar consultas
    await db.execute('CREATE INDEX idx_eventos_fecha ON $tableEventos(fecha)');
    await db.execute(
      'CREATE INDEX idx_eventos_fecha_hora_recordatorio ON $tableEventos(fecha_hora_inicial_recordatorio)',
    );
    await db.execute(
      'CREATE INDEX idx_recordatorios_evento ON $tableRecordatoriosEnviados(evento_id)',
    );
    await db.execute(
      'CREATE INDEX idx_notificaciones_fecha ON $tableNotificacionesLog(fecha_hora DESC)',
    );
  }

  /// Maneja actualizaciones de esquema
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migración de v1 a v2: agregar columna tiempo_aviso_antes
    if (oldVersion < 2) {
      await db.execute('''
        ALTER TABLE $tableEventos
        ADD COLUMN tiempo_aviso_antes TEXT
        CHECK(tiempo_aviso_antes IN ('cinco_minutos', 'quince_minutos', 'treinta_minutos', 'una_hora', 'dos_horas'))
      ''');
    }
  }

  /// Cierra la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  /// Limpia todas las tablas (útil para testing)
  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete(tableNotificacionesLog);
    await db.delete(tableRecordatoriosEnviados);
    await db.delete(tableEventos);
  }
}
