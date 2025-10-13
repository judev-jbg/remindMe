// lib/features/events/presentation/pages/events_page.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/widgets/gradient_card.dart';
import '../../../../core/widgets/animated_snackbar.dart';
import '../../../../core/widgets/bottom_modal.dart';

/// Página de gestión de eventos con funcionalidades CRUD
/// Placeholder temporal hasta implementar la funcionalidad completa
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final List<String> _events = [
    'Cumpleaños de María',
    'Aniversario de boda',
    'Reunión de trabajo',
    'Cita médica',
    'Evento de prueba',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _events.isEmpty ? _buildEmptyState() : _buildEventsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateEventModal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text('No tienes eventos', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer evento tocando el botón +',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key(_events[index]),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                return await _showDeleteConfirmation(index);
              } else if (direction == DismissDirection.endToStart) {
                _showEditModal(index);
                return false;
              }
              return false;
            },
            background: _buildDismissBackground(
              color: Colors.red,
              icon: Icons.delete,
              alignment: Alignment.centerLeft,
            ),
            secondaryBackground: _buildDismissBackground(
              color: Colors.orange,
              icon: Icons.edit,
              alignment: Alignment.centerRight,
            ),
            child: GradientCard(
              gradient: AppGradients.getEventCardGradient(index),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _events[index],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fecha: ${DateTime.now().add(Duration(days: index)).toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: Colors.white, size: 32),
    );
  }

  Future<bool> _showDeleteConfirmation(int index) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${_events[index]}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        _events.removeAt(index);
      });

      if (mounted) {
        AnimatedSnackbar.showSuccess(
          context: context,
          message: 'Evento eliminado correctamente',
        );
      }
    }

    return result ?? false;
  }

  void _showEditModal(int index) {
    BottomModal.show(
      context: context,
      child: _buildEventModal(
        title: 'Editar Evento',
        initialValue: _events[index],
        onSave: (value) {
          setState(() {
            _events[index] = value;
          });
          AnimatedSnackbar.showSuccess(
            context: context,
            message: 'Evento actualizado correctamente',
          );
        },
      ),
    );
  }

  void _showCreateEventModal() {
    BottomModal.show(
      context: context,
      child: _buildEventModal(
        title: 'Crear Evento',
        onSave: (value) {
          setState(() {
            _events.add(value);
          });
          AnimatedSnackbar.showSuccess(
            context: context,
            message: 'Evento creado correctamente',
          );
        },
      ),
    );
  }

  Widget _buildEventModal({
    required String title,
    String initialValue = '',
    required Function(String) onSave,
  }) {
    final controller = TextEditingController(text: initialValue);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Nombre del evento',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 24),
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
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      onSave(controller.text);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
