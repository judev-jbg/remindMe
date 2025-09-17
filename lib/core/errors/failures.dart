// lib/core/errors/failures.dart

import 'package:equatable/equatable.dart';

/// Clase base para manejar errores en la aplicación
/// Utiliza el patrón Either para manejo funcional de errores
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Error de cache/almacenamiento local
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Error de validación
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Error de base de datos
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// Error desconocido
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
