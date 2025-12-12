// lib/features/events/data/datasources/eventos_local_data_source.dart

import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/evento_model.dart';
import '../models/recordatorio_enviado_model.dart';

/// Fuente de datos local para eventos usando SQLite
abstract class EventosLocalDataSource {
  Future<EventoModel> crearEvento(EventoModel evento);
  Future<EventoModel> obtenerEvento(String id);
  Future<List<EventoModel>> obtenerTodosLosEventos();
  Future<EventoModel> actualizarEvento(EventoModel evento);
  Future<void> eliminarEvento(String id);

  Future<void> registrarRecordatorioEnviado(
    RecordatorioEnviadoModel recordatorio,
  );
  Future<RecordatorioEnviadoModel?> obtenerUltimoRecordatorio(String eventoId);
  Future<int> contarOcurrenciasEnviadas(String eventoId);
  Future<List<RecordatorioEnviadoModel>> obtenerRecordatoriosDeEvento(
    String eventoId,
  );
}

class EventosLocalDataSourceImpl implements EventosLocalDataSource {
  final DatabaseHelper databaseHelper;

  EventosLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<EventoModel> crearEvento(EventoModel evento) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(
        DatabaseHelper.tableEventos,
        evento.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return evento;
    } catch (e) {
      throw Exception('Error al crear evento: $e');
    }
  }

  @override
  Future<EventoModel> obtenerEvento(String id) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableEventos,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        throw Exception('Evento no encontrado');
      }

      return EventoModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error al obtener evento: $e');
    }
  }

  @override
  Future<List<EventoModel>> obtenerTodosLosEventos() async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableEventos,
        orderBy: 'fecha ASC',
      );

      return maps.map((map) => EventoModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener eventos: $e');
    }
  }

  @override
  Future<EventoModel> actualizarEvento(EventoModel evento) async {
    try {
      final db = await databaseHelper.database;
      final rowsAffected = await db.update(
        DatabaseHelper.tableEventos,
        evento.toMap(),
        where: 'id = ?',
        whereArgs: [evento.id],
      );

      if (rowsAffected == 0) {
        throw Exception('Evento no encontrado para actualizar');
      }

      return evento;
    } catch (e) {
      throw Exception('Error al actualizar evento: $e');
    }
  }

  @override
  Future<void> eliminarEvento(String id) async {
    try {
      final db = await databaseHelper.database;
      final rowsDeleted = await db.delete(
        DatabaseHelper.tableEventos,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (rowsDeleted == 0) {
        throw Exception('Evento no encontrado para eliminar');
      }
    } catch (e) {
      throw Exception('Error al eliminar evento: $e');
    }
  }

  @override
  Future<void> registrarRecordatorioEnviado(
    RecordatorioEnviadoModel recordatorio,
  ) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(
        DatabaseHelper.tableRecordatoriosEnviados,
        recordatorio.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error al registrar recordatorio enviado: $e');
    }
  }

  @override
  Future<RecordatorioEnviadoModel?> obtenerUltimoRecordatorio(
    String eventoId,
  ) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableRecordatoriosEnviados,
        where: 'evento_id = ?',
        whereArgs: [eventoId],
        orderBy: 'fecha_hora_enviado DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return RecordatorioEnviadoModel.fromMap(maps.first);
    } catch (e) {
      throw Exception('Error al obtener último recordatorio: $e');
    }
  }

  @override
  Future<int> contarOcurrenciasEnviadas(String eventoId) async {
    try {
      final db = await databaseHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableRecordatoriosEnviados} WHERE evento_id = ?',
        [eventoId],
      );

      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      throw Exception('Error al contar ocurrencias: $e');
    }
  }

  @override
  Future<List<RecordatorioEnviadoModel>> obtenerRecordatoriosDeEvento(
    String eventoId,
  ) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableRecordatoriosEnviados,
        where: 'evento_id = ?',
        whereArgs: [eventoId],
        orderBy: 'fecha_hora_enviado DESC',
      );

      return maps.map((map) => RecordatorioEnviadoModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener recordatorios del evento: $e');
    }
  }
}
