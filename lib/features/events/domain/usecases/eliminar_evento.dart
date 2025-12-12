// lib/features/events/domain/usecases/eliminar_evento.dart

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/eventos_repository.dart';

/// Caso de uso para eliminar un evento
class EliminarEvento {
  final EventosRepository repository;

  EliminarEvento(this.repository);

  Future<Either<Failure, void>> call(String eventoId) async {
    if (eventoId.trim().isEmpty) {
      return const Left(ValidationFailure('ID de evento inválido'));
    }

    return await repository.eliminarEvento(eventoId);
  }
}
