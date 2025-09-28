import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_desktop/model/screening.dart';
import 'package:cinevibe_desktop/model/movie.dart';
import 'package:cinevibe_desktop/model/hall.dart';
import 'package:cinevibe_desktop/model/screening_type.dart';
import 'package:cinevibe_desktop/providers/screening_provider.dart';
import 'package:cinevibe_desktop/providers/movie_provider.dart';
import 'package:cinevibe_desktop/providers/hall_provider.dart';
import 'package:cinevibe_desktop/providers/screening_type_provider.dart';
import 'package:cinevibe_desktop/utils/base_date_picker.dart';
import 'package:cinevibe_desktop/utils/base_dropdown.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';

class ScreeningAddEditScreen extends StatefulWidget {
  final Screening? screening; // null for add, non-null for edit

  const ScreeningAddEditScreen({super.key, this.screening});

  @override
  State<ScreeningAddEditScreen> createState() => _ScreeningAddEditScreenState();
}

class _ScreeningAddEditScreenState extends State<ScreeningAddEditScreen> {
  late ScreeningProvider screeningProvider;
  late MovieProvider movieProvider;
  late HallProvider hallProvider;
  late ScreeningTypeProvider screeningTypeProvider;

  DateTime? selectedDate;
  String? selectedTime;
  Movie? selectedMovie;
  Hall? selectedHall;
  ScreeningType? selectedScreeningType;
  bool isActive = true;

  List<Movie> movies = [];
  List<Hall> halls = [];
  List<ScreeningType> screeningTypes = [];
  List<Screening> allScreenings = [];

  bool isLoading = false;
  bool isSaving = false;
  String? validationError;

  final List<String> timeOptions = ['13:00', '17:30', '21:00'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      screeningProvider = context.read<ScreeningProvider>();
      movieProvider = context.read<MovieProvider>();
      hallProvider = context.read<HallProvider>();
      screeningTypeProvider = context.read<ScreeningTypeProvider>();
      
      await _loadData();
      _initializeForm();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load all data in parallel
      final futures = await Future.wait([
        movieProvider.get(filter: {"pageSize": 1000}),
        hallProvider.get(filter: {"pageSize": 1000}),
        screeningTypeProvider.get(filter: {"pageSize": 1000}),
        screeningProvider.get(filter: {"pageSize": 1000}),
      ]);

      setState(() {
        movies = (futures[0].items ?? []).cast<Movie>();
        halls = (futures[1].items ?? []).cast<Hall>();
        screeningTypes = (futures[2].items ?? []).cast<ScreeningType>();
        allScreenings = (futures[3].items ?? []).cast<Screening>();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading data: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _initializeForm() {
    if (widget.screening != null) {
      // Edit mode - populate form with existing data
      selectedDate = widget.screening!.startTime;
      selectedTime = '${widget.screening!.startTime.hour.toString().padLeft(2, '0')}:${widget.screening!.startTime.minute.toString().padLeft(2, '0')}';
      selectedMovie = movies.firstWhere((m) => m.id == widget.screening!.movieId, orElse: () => movies.first);
      selectedHall = halls.firstWhere((h) => h.id == widget.screening!.hallId, orElse: () => halls.first);
      selectedScreeningType = screeningTypes.firstWhere((st) => st.id == widget.screening!.screeningTypeId, orElse: () => screeningTypes.first);
      isActive = widget.screening!.isActive;
    } else {
      // Add mode - set defaults
      selectedDate = DateTime.now();
      selectedTime = '13:00';
    }
  }

  DateTime? _getCombinedDateTime() {
    if (selectedDate == null || selectedTime == null) return null;
    
    final timeParts = selectedTime!.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    return DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      hour,
      minute,
    );
  }

  String? _validateScreening() {
    if (selectedDate == null) return 'Please select a date';
    if (selectedTime == null) return 'Please select a time';
    if (selectedMovie == null) return 'Please select a movie';
    if (selectedHall == null) return 'Please select a hall';
    if (selectedScreeningType == null) return 'Please select a screening type';

    final combinedDateTime = _getCombinedDateTime();
    if (combinedDateTime == null) return 'Invalid date/time combination';

    // Check for conflicts with existing screenings
    final conflictingScreening = allScreenings.firstWhere(
      (screening) {
        // Skip the current screening if we're editing
        if (widget.screening != null && screening.id == widget.screening!.id) {
          return false;
        }
        
        return screening.hallId == selectedHall!.id &&
               screening.startTime.year == combinedDateTime.year &&
               screening.startTime.month == combinedDateTime.month &&
               screening.startTime.day == combinedDateTime.day &&
               screening.startTime.hour == combinedDateTime.hour &&
               screening.startTime.minute == combinedDateTime.minute;
      },
      orElse: () => Screening(
        id: -1, 
        startTime: DateTime.now(), 
        isActive: true, 
        createdAt: DateTime.now(),
        movieId: 0,
        movieTitle: '',
        movieDuration: 0,
        hallId: 0,
        hallName: '',
        screeningTypeId: 0,
        screeningTypeName: '',
        price: 0,
        endTime: DateTime.now(),
        occupiedSeatsCount: 0,
      ),
    );

    if (conflictingScreening.id != -1) {
      return 'A screening already exists at this time in ${selectedHall!.name}';
    }

    return null;
  }

  Future<void> _saveScreening() async {
    final validation = _validateScreening();
    if (validation != null) {
      setState(() {
        validationError = validation;
      });
      return;
    }

    setState(() {
      isSaving = true;
      validationError = null;
    });

    try {
      final combinedDateTime = _getCombinedDateTime()!;
      
      final screeningData = {
        "startTime": combinedDateTime.toIso8601String(),
        "isActive": isActive,
        "movieId": selectedMovie!.id,
        "hallId": selectedHall!.id,
        "screeningTypeId": selectedScreeningType!.id,
      };

      if (widget.screening == null) {
        // Adding new screening
        await screeningProvider.insert(screeningData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Screening created successfully!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        // Editing existing screening
        await screeningProvider.update(widget.screening!.id, screeningData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Screening updated successfully!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
      
      Navigator.of(context).pop(true);
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
    final bool isEditMode = widget.screening != null;
    
    return MasterScreen(
      title: isEditMode ? "Edit Screening" : "Add New Screening",
      showBackButton: true,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 700,
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
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AAD)),
                    ),
                  )
                : Column(
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
                                isEditMode ? 'Edit Screening' : 'Add New Screening',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              Text(
                                isEditMode 
                                    ? 'Update screening information and settings'
                                    : 'Create a new movie screening with time and hall assignment',
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

                    // Validation error
                    if (validationError != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: const Color(0xFFEF4444),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                validationError!,
                                style: const TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Form fields
                    _buildFormField(
                      label: 'Screening Date',
                      child: customDatePicker(
                        context: context,
                        placeholderText: "Select screening date",
                        value: selectedDate,
                        onChanged: (date) {
                          setState(() {
                            selectedDate = date;
                            validationError = null;
                          });
                        },
                        prefixIcon: Icons.calendar_today,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildFormField(
                      label: 'Screening Time',
                      child: customDropdownField<String>(
                        label: "Select time",
                        value: selectedTime,
                        items: timeOptions.map((time) => DropdownMenuItem<String>(
                          value: time,
                          child: Text(time),
                        )).toList(),
                        hintText: "Select time",
                        onChanged: (time) {
                          setState(() {
                            selectedTime = time;
                            validationError = null;
                          });
                        },
                        prefixIcon: Icons.access_time,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildFormField(
                      label: 'Movie',
                      child: customDropdownField<Movie>(
                        label: "Select movie",
                        value: selectedMovie,
                        items: [
                          const DropdownMenuItem<Movie>(
                            value: null,
                            child: Text("Select a movie"),
                          ),
                          ...movies.map((movie) => DropdownMenuItem<Movie>(
                            value: movie,
                            child: Text(movie.title),
                          )),
                        ],
                        hintText: "Select movie",
                        onChanged: (movie) {
                          setState(() {
                            selectedMovie = movie;
                            validationError = null;
                          });
                        },
                        prefixIcon: Icons.movie,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildFormField(
                      label: 'Hall',
                      child: customDropdownField<Hall>(
                        label: "Select hall",
                        value: selectedHall,
                        items: [
                          const DropdownMenuItem<Hall>(
                            value: null,
                            child: Text("Select a hall"),
                          ),
                          ...halls.map((hall) => DropdownMenuItem<Hall>(
                            value: hall,
                            child: Text(hall.name),
                          )),
                        ],
                        hintText: "Select hall",
                        onChanged: (hall) {
                          setState(() {
                            selectedHall = hall;
                            validationError = null;
                          });
                        },
                        prefixIcon: Icons.meeting_room,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildFormField(
                      label: 'Screening Type',
                      child: customDropdownField<ScreeningType>(
                        label: "Select screening type",
                        value: selectedScreeningType,
                        items: [
                          const DropdownMenuItem<ScreeningType>(
                            value: null,
                            child: Text("Select a screening type"),
                          ),
                          ...screeningTypes.map((type) => DropdownMenuItem<ScreeningType>(
                            value: type,
                            child: Text('${type.name} - \$${type.price.toStringAsFixed(2)}'),
                          )),
                        ],
                        hintText: "Select screening type",
                        onChanged: (type) {
                          setState(() {
                            selectedScreeningType = type;
                            validationError = null;
                          });
                        },
                        prefixIcon: Icons.movie_filter,
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
                                ? 'Screening is available for booking'
                                : 'Screening is disabled and not available',
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
                    const SizedBox(height: 40),

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
                            onPressed: isSaving ? null : _saveScreening,
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
                                    isEditMode ? 'Update Screening' : 'Create Screening',
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
}
