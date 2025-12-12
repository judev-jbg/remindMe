// lib/features/events/domain/usecases/obtener_todos_los_eventos.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/evento.dart';
import '../repositories/eventos_repository.dart';

/// Caso de uso para obtener todos los eventos
class ObtenerTodosLosEventos {
  final EventosRepository repository;

  ObtenerTodosLosEventos(this.repository);

  Future<Either<Failure, List<Evento>>> call() async {
    return await repository.obtenerTodosLosEventos();
  }
}
