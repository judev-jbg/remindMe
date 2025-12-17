# RemindMe 📅

Una aplicación de recordatorios elegante y minimalista para gestionar eventos importantes como cumpleaños, aniversarios, mesarios y eventos personalizados con notificaciones inteligentes.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.9.0-02569B?logo=flutter)
![License](https://img.shields.io/badge/license-MIT-green)

## 📱 Características

### Gestión de Eventos

- **Múltiples tipos de eventos**: Cumpleaños, Aniversarios, Mesarios y eventos personalizados
- **Formulario inteligente**: Validación automática de fechas y horarios
- **Tarjetas visuales elegantes**: Diseño con gradientes y visualización clara de información
- **Edición y eliminación**: Gestión completa de eventos con confirmación
- **Cálculo automático**: Muestra años y meses transcurridos desde eventos importantes

### Timeline Inteligente

- **Vista de 7 slots**: 3 eventos pasados, hoy y 3 futuros
- **Navegación intuitiva**: Desplazamiento suave entre fechas
- **Agrupación automática**: Organiza eventos por relevancia temporal
- **Indicadores visuales**: Diferencia clara entre eventos pasados, actuales y futuros

### Sistema de Notificaciones

- **Recordatorios confiables**: Utiliza `android_alarm_manager_plus` para alarmas exactas en Android
- **Programación inteligente**: Ajusta recordatorios al tiempo del evento si la hora calculada está en el pasado
- **Múltiples opciones de aviso**: 5, 15, 30 minutos, 1 hora, 1 día, 1 semana antes
- **Historial completo**: Registro de todas las notificaciones enviadas
- **Notificaciones persistentes**: Funcionan incluso con la app cerrada

### Interfaz de Usuario

- **Temas claro/oscuro**: Soporte completo de Material Design 3
- **Animaciones fluidas**: Transiciones suaves y naturales
- **Responsive**: Se adapta a diferentes tamaños de pantalla
- **Localización**: Soporte completo en español (es_ES)
- **Bottom sheets informativos**: Detalles completos del evento al tocar las tarjetas

### Historial y Registro

- **Log de notificaciones**: Auditoría completa de todas las acciones
- **Marca como leído**: Gestión de notificaciones vistas
- **Filtros**: Visualización organizada del historial

---

## 🏗️ Arquitectura

El proyecto implementa **Clean Architecture** con separación clara de responsabilidades en tres capas:

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                     │
│  (UI, Cubits, Pages, Widgets)                   │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│           Domain Layer                           │
│  (Entities, Use Cases, Repositories Abstracts)  │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│           Data Layer                             │
│  (Repositories Impl, Data Sources, Models)      │
└─────────────────────────────────────────────────┘
```

### Estructura del Proyecto

```
lib/
├── core/                              # Capa compartida
│   ├── constants/                     # Colores, gradientes
│   ├── database/                      # SQLite helper
│   ├── navigation/                    # GoRouter, shell navigation
│   ├── services/                      # Servicios de notificaciones y alarmas
│   ├── theme/                         # Temas Material 3
│   └── widgets/                       # Widgets reutilizables
│
├── features/                          # Módulos por funcionalidad
│   ├── events/                        # Feature de eventos
│   │   ├── data/                      # Implementación de datos
│   │   ├── domain/                    # Lógica de negocio
│   │   └── presentation/              # UI y estado
│   ├── notifications/                 # Feature de notificaciones
│   ├── settings/                      # Feature de configuración
│   └── timeline/                      # Feature de línea de tiempo
│
├── main.dart                          # Punto de entrada
└── injection_container.dart           # Inyección de dependencias
```

### Patrones de Diseño

- **Repository Pattern**: Abstracción de fuentes de datos
- **Use Case Pattern**: Encapsulación de lógica de negocio
- **BLoC/Cubit Pattern**: Gestión de estado reactiva
- **Dependency Injection**: GetIt para inversión de dependencias
- **Service Locator**: Registro centralizado de servicios
- **Entity/Model Separation**: Separación entre entidades de dominio y modelos de datos

---

## 🛠️ Tecnologías

### Frameworks y Librerías Principales

**Estado y Arquitectura**

- `flutter_bloc: ^9.1.1` - Gestión de estado con BLoC/Cubit
- `get_it: ^8.2.0` - Service locator para inyección de dependencias
- `injectable: ^2.3.2` - Generación de código para DI

**Almacenamiento**

- `sqflite: ^2.3.0` - Base de datos SQLite local
- `shared_preferences: ^2.2.2` - Almacenamiento clave-valor

**Navegación**

- `go_router: ^16.2.1` - Enrutamiento declarativo moderno

**Notificaciones**

- `flutter_local_notifications: ^19.4.2` - Notificaciones locales
- `android_alarm_manager_plus: ^4.0.2` - Alarmas exactas confiables en Android
- `timezone: ^0.10.1` - Soporte de zonas horarias

**UI y Animaciones**

- `flutter_animate: ^4.2.0` - Librería de animaciones
- `lottie: ^3.3.2` - Animaciones Lottie
- `flutter_staggered_animations: ^1.1.1` - Animaciones escalonadas

**Utilidades**

- `equatable: ^2.0.5` - Igualdad de valores para entidades
- `intl: ^0.20.2` - Internacionalización y formateo
- `dartz: ^0.10.1` - Programación funcional (Either)
- `uuid: ^4.5.1` - Generación de UUIDs

---

## 🚀 Instalación

### Requisitos Previos

- Flutter SDK `^3.9.0`
- Dart SDK `^3.9.0`
- Android Studio / VS Code
- Dispositivo Android (API 21+) o iOS

### Pasos de Instalación

1. **Clonar el repositorio**

```bash
git clone https://github.com/judev-jbg/remindme.git
cd remindme
```

2. **Instalar dependencias**

```bash
flutter pub get
```

3. **Generar código de inyección de dependencias**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Configurar iconos y splash screen**

```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

5. **Ejecutar la aplicación**

```bash
flutter run
```

---

## 📊 Base de Datos

### Esquema SQLite (Versión 2)

**Tabla: eventos**

```sql
CREATE TABLE eventos (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  fecha INTEGER NOT NULL,
  tipo TEXT NOT NULL,
  notas TEXT,
  tiene_recordatorio INTEGER NOT NULL DEFAULT 0,
  estado TEXT NOT NULL DEFAULT 'habilitado',
  tiempo_aviso_antes TEXT,
  hora_evento INTEGER,
  fecha_hora_inicial_recordatorio INTEGER,
  tipo_recurrencia TEXT NOT NULL DEFAULT 'ninguna',
  intervalo INTEGER,
  dias_semana TEXT,
  fecha_finalizacion INTEGER,
  max_ocurrencias INTEGER,
  fecha_creacion INTEGER NOT NULL,
  fecha_actualizacion INTEGER
);
```

**Tabla: recordatorios_enviados**

```sql
CREATE TABLE recordatorios_enviados (
  id TEXT PRIMARY KEY,
  evento_id TEXT NOT NULL,
  fecha_hora_enviado INTEGER NOT NULL,
  fue_visto INTEGER NOT NULL DEFAULT 0,
  tipo TEXT NOT NULL,
  FOREIGN KEY (evento_id) REFERENCES eventos (id) ON DELETE CASCADE
);
```

**Tabla: notificaciones_log**

```sql
CREATE TABLE notificaciones_log (
  id TEXT PRIMARY KEY,
  tipo TEXT NOT NULL,
  titulo TEXT NOT NULL,
  detalle TEXT NOT NULL,
  fecha_hora INTEGER NOT NULL,
  marcada INTEGER NOT NULL DEFAULT 0
);
```

---

## 🔔 Sistema de Notificaciones

### Flujo de Programación

1. **Usuario crea/edita evento** → `EventosCubit.crearEvento()`
2. **Validación de datos** → `Evento.esValido`
3. **Cálculo de fechas de recordatorio** → `RecordatorioCalculator.calcularProximoRecordatorio()`
4. **Programación de alarmas** → `AlarmService.scheduleAlarm()`
5. **Callback en isolate** → `AlarmService._alarmCallback()`
6. **Notificación mostrada** → `NotificationService.showNotification()`
7. **Registro en base de datos** → `_registrarNotificacionEnLog()`

### Lógica Inteligente

- **Validación de tiempo**: Si el recordatorio calculado está en el pasado, se programa a la hora del evento
- **Aislamiento de callbacks**: Los callbacks de alarma se ejecutan en isolates separados para confiabilidad
- **Persistencia**: Todas las notificaciones se registran en la base de datos
- **Cancelación automática**: Al editar/eliminar eventos, se cancelan notificaciones previas

### Anotaciones AOT

```dart
@pragma('vm:entry-point')
static void _alarmCallback(int id) async {
  // Callback ejecutado por android_alarm_manager_plus
}
```

---

## 🎨 Temas y Personalización

### Paleta de Colores

**Tema Claro**

- Primary: `#5956E8` (Purple)
- Background: `#FFFFFF`
- Surface: `#F5F5F5`
- Error: `#D32F2F`

**Tema Oscuro**

- Primary: `#8B88FF` (Light Purple)
- Background: `#121212`
- Surface: `#1E1E1E`
- Error: `#CF6679`

### Gradientes para Tarjetas

Las tarjetas de eventos utilizan gradientes dinámicos basados en el índice:

- Gradient 1: Purple to Blue
- Gradient 2: Pink to Orange
- Gradient 3: Teal to Cyan
- Gradient 4: Orange to Red
- Gradient 5: Indigo to Purple

---

## 📝 Casos de Uso Principales

### Crear Evento

```dart
final useCase = getIt<CrearEvento>();
await useCase(evento);
```

### Programar Notificaciones

```dart
final useCase = getIt<ProgramarNotificacionesEvento>();
await useCase(evento);
```

### Obtener Timeline

```dart
timelineCubit.cargarTimelineInicial();
```

### Cambiar Tema

```dart
themeCubit.setThemeMode(ThemeMode.dark);
```

---

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage

# Ver reporte de cobertura
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📱 Permisos Requeridos

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<!-- Notificaciones -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>

<!-- Alarmas exactas (Android 12+) -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>

<!-- Wake lock para alarmas -->
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

### iOS (`ios/Runner/Info.plist`)

```xml
<!-- Notificaciones locales -->
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

---

## 🐛 Problemas Conocidos y Soluciones

### Android 14+ Notificaciones No Funcionan

**Solución**: Se implementó `android_alarm_manager_plus` con anotaciones `@pragma('vm:entry-point')` para AOT compilation.

### Recordatorio en el Pasado

**Solución**: Sistema ajusta automáticamente el recordatorio a la hora del evento si la opción seleccionada genera un tiempo pasado.

### Notificaciones No Aparecen en Historial

**Solución**: Implementado registro en base de datos dentro del callback de alarma en isolate separado.

---

## 🔄 Historial de Cambios

### v1.0.0 (2025-12-17)

**Añadido**

- Sistema completo de gestión de eventos (CRUD)
- Timeline de 7 slots con eventos pasados, actuales y futuros
- Historial de notificaciones con marcado de leído
- Soporte de temas claro/oscuro persistente
- Validación inteligente de formularios
- Bottom sheet con detalles de eventos

**Arreglado**

- Programación de recordatorios cuando el tiempo calculado está en el pasado
- Registro de notificaciones en base de datos desde callback de alarma
- Validación de eventos tipo "Otro" con fechas pasadas
- Anotaciones AOT para compilación Android

**Mejorado**

- Diseño de tarjetas de eventos con cálculo de tiempo transcurrido
- Sistema de notificaciones con android_alarm_manager_plus
- Experiencia de usuario en formulario de eventos

---

## 👨‍💻 Desarrollo

### Ejecutar en modo debug

```bash
flutter run
```

### Compilar para producción

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ipa --release
```

### Generar código

```bash
# Inyección de dependencias
flutter pub run build_runner build

# Watch mode (regenera automáticamente)
flutter pub run build_runner watch
```

### Limpiar proyecto

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

---

## 📞 Contacto

**Proyecto**: [RemindMe](https://github.com/judev-jbg/remindme)

---

## 🙏 Agradecimientos

- Flutter Team por el excelente framework
- Comunidad de Flutter por las librerías open source
- Material Design 3 por las guías de diseño

---

**Hecho con ❤️ usando Flutter**
