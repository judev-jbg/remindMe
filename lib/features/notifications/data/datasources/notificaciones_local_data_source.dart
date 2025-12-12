// lib/features/notifications/data/datasources/notificaciones_local_data_source.dart

import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_helper.dart';
import '../models/notificacion_log_model.dart';

/// Fuente de datos local para notificaciones usando SQLite
abstract class NotificacionesLocalDataSource {
  Future<void> crearNotificacion(NotificacionLogModel notificacion);
  Future<List<NotificacionLogModel>> obtenerUltimasNotificaciones(int limite);
  Future<List<NotificacionLogModel>> obtenerNotificacionesFiltradas({
    bool? soloMarcadas,
    int limite = 20,
  });
  Future<void> marcarNotificacion(String id, bool marcada);
  Future<void> marcarTodasComoLeidas();
  Future<void> limpiarNotificacionesAntiguas();
}

class NotificacionesLocalDataSourceImpl
    implements NotificacionesLocalDataSource {
  final DatabaseHelper databaseHelper;

  NotificacionesLocalDataSourceImpl(this.databaseHelper);

  @override
  Future<void> crearNotificacion(NotificacionLogModel notificacion) async {
    try {
      final db = await databaseHelper.database;
      await db.insert(
        DatabaseHelper.tableNotificacionesLog,
        notificacion.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Error al crear notificación: $e');
    }
  }

  @override
  Future<List<NotificacionLogModel>> obtenerUltimasNotificaciones(
    int limite,
  ) async {
    try {
      final db = await databaseHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableNotificacionesLog,
        orderBy: 'fecha_hora DESC',
        limit: limite,
      );

      return maps.map((map) => NotificacionLogModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener notificaciones: $e');
    }
  }

  @override
  Future<List<NotificacionLogModel>> obtenerNotificacionesFiltradas({
    bool? soloMarcadas,
    int limite = 20,
  }) async {
    try {
      final db = await databaseHelper.database;

      String? where;
      List<dynamic>? whereArgs;

      if (soloMarcadas != null) {
        where = 'marcada = ?';
        whereArgs = [soloMarcadas ? 1 : 0];
      }

      final maps = await db.query(
        DatabaseHelper.tableNotificacionesLog,
        where: where,
        whereArgs: whereArgs,
        orderBy: 'fecha_hora DESC',
        limit: limite,
      );

      return maps.map((map) => NotificacionLogModel.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Error al obtener notificaciones filtradas: $e');
    }
  }

  @override
  Future<void> marcarNotificacion(String id, bool marcada) async {
    try {
      final db = await databaseHelper.database;
      await db.update(
        DatabaseHelper.tableNotificacionesLog,
        {'marcada': marcada ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error al marcar notificación: $e');
    }
  }

  @override
  Future<void> marcarTodasComoLeidas() async {
    try {
      final db = await databaseHelper.database;
      await db.update(DatabaseHelper.tableNotificacionesLog, {'marcada': 1});
    } catch (e) {
      throw Exception('Error al marcar todas como leídas: $e');
    }
  }

  @override
  Future<void> limpiarNotificacionesAntiguas() async {
    try {
      final db = await databaseHelper.database;

      // Calcular fecha límite (15 días atrás)
      final fechaLimite = DateTime.now().subtract(const Duration(days: 15));
      final fechaLimiteMillis = fechaLimite.millisecondsSinceEpoch;

      // Obtener ID de las últimas 50 notificaciones
      final ultimasNotificaciones = await db.query(
        DatabaseHelper.tableNotificacionesLog,
        columns: ['id'],
        orderBy: 'fecha_hora DESC',
        limit: 50,
      );

      final idsAMantener = ultimasNotificaciones
          .map((map) => "'${map['id']}'")
          .join(',');

      // Eliminar notificaciones antiguas que no estén en las últimas 50
      if (idsAMantener.isNotEmpty) {
        await db.delete(
          DatabaseHelper.tableNotificacionesLog,
          where: 'fecha_hora < ? AND id NOT IN ($idsAMantener)',
          whereArgs: [fechaLimiteMillis],
        );
      } else {
        // Si no hay notificaciones recientes, eliminar todas las antiguas
        await db.delete(
          DatabaseHelper.tableNotificacionesLog,
          where: 'fecha_hora < ?',
          whereArgs: [fechaLimiteMillis],
        );
      }
    } catch (e) {
      throw Exception('Error al limpiar notificaciones antiguas: $e');
    }
  }
}
