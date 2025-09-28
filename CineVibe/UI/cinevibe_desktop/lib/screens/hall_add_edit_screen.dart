import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_desktop/model/hall.dart';
import 'package:cinevibe_desktop/providers/hall_provider.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';

class HallAddEditScreen extends StatefulWidget {
  final Hall? hall; // null for add, non-null for edit

  const HallAddEditScreen({super.key, this.hall});

  @override
  State<HallAddEditScreen> createState() => _HallAddEditScreenState();
}

class _HallAddEditScreenState extends State<HallAddEditScreen> {
  late HallProvider hallProvider;
  late TextEditingController nameController;
  late bool isActive;
  late int rows;
  late int columns;
  bool isLoading = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hallProvider = context.read<HallProvider>();
    });
    
    // Initialize form fields
    nameController = TextEditingController(text: widget.hall?.name ?? '');
    isActive = widget.hall?.isActive ?? true;
    rows = 10; // Default values for new halls
    columns = 10;
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _saveHall() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a hall name'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    if (rows < 1 || rows > 50 || columns < 1 || columns > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Rows and columns must be between 1 and 50'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      bool success;
      
      if (widget.hall == null) {
        // Adding new hall
        var createdHall = await hallProvider.insert({
          "name": nameController.text.trim(),
          "isActive": isActive,
        });
        success = true;

        if (success) {
          // Generate seats for the new hall
          try {
            await hallProvider.generateSeatsForHall(createdHall.id, rows, columns);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Hall created successfully with seats generated!'),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Hall created successfully! You can generate seats from the hall list.'),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
          Navigator.of(context).pop(true);
        }
      } else {
        // Editing existing hall
        await hallProvider.update(widget.hall!.id, {
          "name": nameController.text.trim(),
          "isActive": isActive,
        });
        success = true;

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Hall updated successfully!'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          Navigator.of(context).pop(true);
        }
      }

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to save hall. Please try again.'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditMode = widget.hall != null;
    
    return MasterScreen(
      title: isEditMode ? "Edit Hall" : "Add New Hall",
      showBackButton: true,
      child: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF004AAD).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF004AAD).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isEditMode ? Icons.edit : Icons.add_circle_outline,
                      color: const Color(0xFF004AAD),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditMode ? 'Edit Hall' : 'Add New Hall',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          isEditMode 
                              ? 'Update hall information and settings'
                              : 'Create a new cinema hall with seat configuration',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Form fields
              _buildFormField(
                label: 'Hall Name',
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter hall name',
                    prefixIcon: const Icon(Icons.meeting_room, color: Color(0xFF004AAD)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF004AAD), width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status toggle
              _buildFormField(
                label: 'Status',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: Text(
                      isActive 
                          ? 'Hall is available for screenings'
                          : 'Hall is disabled and not available',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    value: isActive,
                    onChanged: (value) {
                      setState(() {
                        isActive = value;
                      });
                    },
                    activeColor: const Color(0xFF10B981),
                    inactiveThumbColor: const Color(0xFFEF4444),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Seat configuration (only for new halls)
              if (!isEditMode) ...[
                _buildFormField(
                  label: 'Seat Configuration',
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildNumberField(
                              label: 'Rows',
                              value: rows,
                              onChanged: (value) {
                                setState(() {
                                  rows = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildNumberField(
                              label: 'Columns',
                              value: columns,
                              onChanged: (value) {
                                setState(() {
                                  columns = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFF3B82F6),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Seat Layout Preview',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF3B82F6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'This will create ${rows * columns} seats (${rows} rows × ${columns} seats)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF3B82F6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ] else
                const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: isSaving ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _saveHall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004AAD),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              isEditMode ? 'Update Hall' : 'Create Hall',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
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

  Widget _buildFormField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '$value',
            prefixIcon: Icon(
              label.toLowerCase().contains('row') ? Icons.view_agenda : Icons.view_column,
              color: const Color(0xFF004AAD),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF004AAD), width: 2),
            ),
          ),
          onChanged: (value) {
            final intValue = int.tryParse(value);
            if (intValue != null && intValue > 0 && intValue <= 50) {
              onChanged(intValue);
            }
          },
        ),
      ],
    );
  }
}
