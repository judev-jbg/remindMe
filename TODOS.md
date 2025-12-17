# TODOs Pendientes

Este documento lista todos los TODOs encontrados en el proyecto que requieren atención futura.

## 📋 Lista de TODOs

### 1. Timeline - Obtener ocurrencias reales
**Archivo**: `lib/features/timeline/presentation/pages/timeline_page.dart:569`

**Código actual**:
```dart
proximoRecordatorio = RecordatorioCalculator.calcularProximoRecordatorio(
  evento,
  0, // TODO: Obtener ocurrencias reales
);
```

**Descripción**:
Actualmente se pasa `0` como número de ocurrencias al calcular el próximo recordatorio. Se debe implementar lógica para obtener el número real de ocurrencias ya programadas/enviadas para el evento.

**Prioridad**: Media

**Impacto**:
Para eventos con recurrencia, esto podría afectar el cálculo correcto del próximo recordatorio si ya han ocurrido algunas notificaciones.

---

### 2. Navegación al tocar notificación
**Archivo**: `lib/core/services/notification_service.dart:75`

**Código actual**:
```dart
void _onNotificationTapped(NotificationResponse response) {
  // TODO: Navegar a la pantalla del evento
  // Error silencioso en producción - notification tap detected
}
```

**Descripción**:
Cuando el usuario toca una notificación, actualmente no se navega a ninguna pantalla específica. Se debe implementar navegación al detalle del evento relacionado con la notificación.

**Prioridad**: Alta

**Impacto**:
Mejora significativa en la experiencia de usuario. Los usuarios esperan que al tocar una notificación se abra la información relevante del evento.

**Implementación sugerida**:
1. Parsear el payload de la notificación para obtener el ID del evento
2. Usar el AppRouter para navegar a una pantalla de detalle del evento
3. Considerar si la app está en background o foreground para manejar la navegación correctamente

---

### 3. Lógica de días de la semana para recurrencia semanal
**Archivo**: `lib/features/events/domain/services/recordatorio_calculator.dart:138`

**Código actual**:
```dart
case TipoRecurrencia.semanal:
  // Avanzar X semanas
  final siguienteSemana = fechaActual.add(
    Duration(days: 7 * evento.intervalo!),
  );

  // TODO: Implementar lógica de diasSemana para filtrar días específicos
  return siguienteSemana;
```

**Descripción**:
La entidad Evento tiene un campo `diasSemana` (List<int>?) que permite especificar días específicos de la semana para eventos recurrentes semanales (por ejemplo: solo lunes, miércoles y viernes). Esta lógica aún no está implementada.

**Prioridad**: Baja

**Impacto**:
Funcionalidad avanzada para usuarios que necesitan recordatorios semanales en días específicos. Actualmente solo soporta recurrencia cada X semanas sin filtrar por días.

**Implementación sugerida**:
1. Verificar si `evento.diasSemana` tiene valores
2. Al calcular la siguiente fecha, validar que el día de la semana resultante esté en la lista
3. Si no está, buscar el próximo día válido dentro de las X semanas especificadas

---

## 📊 Resumen

| Prioridad | Cantidad |
|-----------|----------|
| Alta      | 1        |
| Media     | 1        |
| Baja      | 1        |
| **Total** | **3**    |

---

## ✅ Acciones Recomendadas

### Inmediatas (Alta Prioridad)
1. Implementar navegación al tocar notificaciones para mejorar UX

### Próxima Versión (Media Prioridad)
2. Implementar tracking de ocurrencias reales para eventos recurrentes

### Futuras (Baja Prioridad)
3. Implementar filtrado por días de la semana para recurrencia semanal

---

**Última actualización**: 2025-12-17
