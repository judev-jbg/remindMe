// lib/features/events/presentation/widgets/evento_form.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/evento.dart';

enum EventoFormMode { crear, editar }

/// Formulario completo para crear/editar eventos
class EventoForm extends StatefulWidget {
  final EventoFormMode modo;
  final Evento? eventoExistente;
  final Function(Map<String, dynamic>) onGuardar;

  const EventoForm({
    super.key,
    required this.modo,
    required this.onGuardar,
    this.eventoExistente,
  });

  @override
  State<EventoForm> createState() => _EventoFormState();
}

class _EventoFormState extends State<EventoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _notasController = TextEditingController();

  late DateTime _fechaSeleccionada;
  late TipoEvento _tipoSeleccionado;
  late bool _tieneRecordatorio;
  late EstadoEvento _estadoSeleccionado;
  TimeOfDay? _horaEvento;
  TiempoAvisoAntes? _tiempoAvisoAntes;

  bool get _puedeActivarRecordatorio {
    // Solo para tipo "Otro"
    if (_tipoSeleccionado != TipoEvento.otro) return true;

    // Si no hay hora seleccionada, no se puede activar
    if (_horaEvento == null) return false;

    // Construir fecha/hora del evento
    final fechaHoraEvento = DateTime(
      _fechaSeleccionada.year,
      _fechaSeleccionada.month,
      _fechaSeleccionada.day,
      _horaEvento!.hour,
      _horaEvento!.minute,
    );

    // El evento debe ser futuro
    return fechaHoraEvento.isAfter(DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.modo == EventoFormMode.editar &&
        widget.eventoExistente != null) {
      final evento = widget.eventoExistente!;
      _nombreController.text = evento.nombre;
      _notasController.text = evento.notas ?? '';
      _fechaSeleccionada = evento.fecha;
      _tipoSeleccionado = evento.tipo;
      _tieneRecordatorio = evento.tieneRecordatorio;
      _estadoSeleccionado = evento.estado;

      if (evento.horaEvento != null) {
        _horaEvento = TimeOfDay.fromDateTime(evento.horaEvento!);
      }

      _tiempoAvisoAntes = evento.tiempoAvisoAntes;
    } else {
      _fechaSeleccionada = DateTime.now();
      _tipoSeleccionado = TipoEvento.otro;
      _tieneRecordatorio = false;
      _estadoSeleccionado = EstadoEvento.habilitado;
      _tiempoAvisoAntes = null;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Text(
                widget.modo == EventoFormMode.crear
                    ? 'Crear Evento'
                    : 'Editar Evento',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),

              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del evento *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
                autofocus: widget.modo == EventoFormMode.crear,
              ),
              const SizedBox(height: 16),

              // Tipo de evento
              DropdownButtonFormField<TipoEvento>(
                initialValue: _tipoSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de evento *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: TipoEvento.values.map((tipo) {
                  return DropdownMenuItem(
                    value: tipo,
                    child: Row(
                      children: [
                        Icon(_getIconForTipo(tipo), size: 20),
                        const SizedBox(width: 8),
                        Text(tipo.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tipoSeleccionado = value!;
                    // Limpiar hora si no es tipo "Otro"
                    if (_tipoSeleccionado != TipoEvento.otro) {
                      _horaEvento = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Fecha
              InkWell(
                onTap: _seleccionarFecha,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Fecha *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat(
                      'EEEE, dd \'de\' MMMM \'de\' yyyy',
                      'es_ES',
                    ).format(_fechaSeleccionada),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Hora del evento (solo para tipo "Otro")
              if (_tipoSeleccionado == TipoEvento.otro) ...[
                InkWell(
                  onTap: _seleccionarHora,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Hora del evento *',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.access_time),
                      suffixIcon: _horaEvento != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _horaEvento = null;
                                });
                              },
                            )
                          : null,
                    ),
                    child: Text(
                      _horaEvento != null
                          ? _horaEvento!.format(context)
                          : 'Seleccionar hora',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Notas
              TextFormField(
                controller: _notasController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Recordatorio switch
              SwitchListTile(
                title: const Text('Activar recordatorio'),
                subtitle: Text(
                  !_puedeActivarRecordatorio && _tipoSeleccionado == TipoEvento.otro
                      ? 'El evento debe ser futuro para activar recordatorios'
                      : 'Recibe notificaciones para este evento',
                ),
                value: _tieneRecordatorio,
                onChanged: _puedeActivarRecordatorio
                    ? (value) {
                        setState(() {
                          _tieneRecordatorio = value;
                          // Si se desactiva el recordatorio, limpiar tiempo de aviso
                          if (!value) {
                            _tiempoAvisoAntes = null;
                          }
                        });
                      }
                    : null, // Deshabilitar si no se puede activar
                secondary: Icon(
                  _tieneRecordatorio
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                ),
              ),

              // Tiempo de aviso (solo para tipo "Otro" con recordatorio activo)
              if (_tipoSeleccionado == TipoEvento.otro && _tieneRecordatorio) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<TiempoAvisoAntes>(
                  initialValue: _tiempoAvisoAntes,
                  decoration: const InputDecoration(
                    labelText: 'Tiempo de aviso *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.alarm),
                    helperText: 'Cuándo deseas recibir la notificación',
                  ),
                  items: TiempoAvisoAntes.values.map((tiempo) {
                    return DropdownMenuItem(
                      value: tiempo,
                      child: Text(tiempo.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _tiempoAvisoAntes = value;
                    });
                  },
                  validator: (value) {
                    if (_tipoSeleccionado == TipoEvento.otro &&
                        _tieneRecordatorio &&
                        value == null) {
                      return 'Debes seleccionar el tiempo de aviso';
                    }
                    return null;
                  },
                ),
              ],

              // Estado (solo en modo edición y si tiene recordatorio)
              if (widget.modo == EventoFormMode.editar &&
                  _tieneRecordatorio) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<EstadoEvento>(
                  initialValue: _estadoSeleccionado,
                  decoration: const InputDecoration(
                    labelText: 'Estado del recordatorio',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.toggle_on),
                  ),
                  items: EstadoEvento.values.map((estado) {
                    return DropdownMenuItem(
                      value: estado,
                      child: Text(estado.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _estadoSeleccionado = value!;
                    });
                  },
                ),
              ],

              const SizedBox(height: 24),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _guardar,
                      child: Text(
                        widget.modo == EventoFormMode.crear
                            ? 'Crear'
                            : 'Actualizar',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        // Desactivar recordatorio si el evento ya no es futuro (solo para tipo Otro)
        if (_tipoSeleccionado == TipoEvento.otro && !_puedeActivarRecordatorio) {
          _tieneRecordatorio = false;
          _tiempoAvisoAntes = null;
        }
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaEvento ?? TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        _horaEvento = hora;
        // Desactivar recordatorio si el evento ya no es futuro (solo para tipo Otro)
        if (_tipoSeleccionado == TipoEvento.otro && !_puedeActivarRecordatorio) {
          _tieneRecordatorio = false;
          _tiempoAvisoAntes = null;
        }
      });
    }
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar hora para tipo "Otro"
    if (_tipoSeleccionado == TipoEvento.otro && _horaEvento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar una hora para eventos tipo "Otro"'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Construir DateTime con hora si es necesario
    DateTime? horaEvento;
    if (_horaEvento != null) {
      horaEvento = DateTime(
        _fechaSeleccionada.year,
        _fechaSeleccionada.month,
        _fechaSeleccionada.day,
        _horaEvento!.hour,
        _horaEvento!.minute,
      );
    }

    // Validar tiempo de aviso para tipo "Otro" con recordatorio
    if (_tipoSeleccionado == TipoEvento.otro &&
        _tieneRecordatorio &&
        _tiempoAvisoAntes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar el tiempo de aviso'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar que el recordatorio no sea en el pasado
    if (_tipoSeleccionado == TipoEvento.otro && _tieneRecordatorio && horaEvento != null && _tiempoAvisoAntes != null) {
      final fechaHoraRecordatorio = horaEvento.subtract(_tiempoAvisoAntes!.duration);
      if (fechaHoraRecordatorio.isBefore(DateTime.now()) || fechaHoraRecordatorio.isAtSameMomentAs(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'El recordatorio será programado para la hora del evento (${_horaEvento!.format(context)}) '
              'ya que la opción seleccionada genera un recordatorio en el pasado',
            ),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.orange,
          ),
        );
        // Continuar de todas formas pero el sistema ajustará el recordatorio
      }
    }

    // Preparar datos
    final data = <String, dynamic>{
      'nombre': _nombreController.text.trim(),
      'fecha': _fechaSeleccionada,
      'tipo': _tipoSeleccionado,
      'notas': _notasController.text.trim().isEmpty
          ? null
          : _notasController.text.trim(),
      'horaEvento': horaEvento,
      'tieneRecordatorio': _tieneRecordatorio,
      'estado': _estadoSeleccionado,
      'tiempoAvisoAntes': _tiempoAvisoAntes,
    };

    // Si es edición, pasar campos adicionales
    if (widget.modo == EventoFormMode.editar &&
        widget.eventoExistente != null) {
      data['fechaHoraInicialRecordatorio'] =
          widget.eventoExistente!.fechaHoraInicialRecordatorio;
      data['tipoRecurrencia'] = widget.eventoExistente!.tipoRecurrencia;
      data['intervalo'] = widget.eventoExistente!.intervalo;
      data['diasSemana'] = widget.eventoExistente!.diasSemana;
      data['fechaFinalizacion'] = widget.eventoExistente!.fechaFinalizacion;
      data['maxOcurrencias'] = widget.eventoExistente!.maxOcurrencias;
    }

    widget.onGuardar(data);
  }

  IconData _getIconForTipo(TipoEvento tipo) {
    switch (tipo) {
      case TipoEvento.cumpleanos:
        return Icons.cake_outlined;
      case TipoEvento.mesario:
        return Icons.favorite_outline;
      case TipoEvento.aniversario:
        return Icons.celebration_outlined;
      case TipoEvento.otro:
        return Icons.event_outlined;
    }
  }
}
