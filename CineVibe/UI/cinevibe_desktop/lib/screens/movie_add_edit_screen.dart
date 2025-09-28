import 'package:flutter/material.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/model/movie.dart';
import 'package:cinevibe_desktop/model/category.dart';
import 'package:cinevibe_desktop/model/genre.dart';
import 'package:cinevibe_desktop/model/director.dart';
import 'package:cinevibe_desktop/providers/movie_provider.dart';
import 'package:cinevibe_desktop/providers/category_provider.dart';
import 'package:cinevibe_desktop/providers/genre_provider.dart';
import 'package:cinevibe_desktop/providers/director_provider.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class MovieAddEditScreen extends StatefulWidget {
  final Movie? movie;

  const MovieAddEditScreen({super.key, this.movie});

  @override
  State<MovieAddEditScreen> createState() => _MovieAddEditScreenState();
}

class _MovieAddEditScreenState extends State<MovieAddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _trailerController = TextEditingController();

  DateTime? _releaseDate;
  int? _selectedCategoryId;
  int? _selectedGenreId;
  int? _selectedDirectorId;
  bool _isActive = true;
  String? _selectedImageBase64;

  late MovieProvider _movieProvider;
  late CategoryProvider _categoryProvider;
  late GenreProvider _genreProvider;
  late DirectorProvider _directorProvider;

  List<Category> _categories = [];
  List<Genre> _genres = [];
  List<Director> _directors = [];

  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.movie != null;
    _initializeData();
  }

  Future<void> _initializeData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _movieProvider = context.read<MovieProvider>();
      _categoryProvider = context.read<CategoryProvider>();
      _genreProvider = context.read<GenreProvider>();
      _directorProvider = context.read<DirectorProvider>();

      await Future.wait([
        _loadCategories(),
        _loadGenres(),
        _loadDirectors(),
      ]);

      if (_isEditing) {
        _populateForm();
      }
    });
  }

  Future<void> _loadCategories() async {
    try {
      final result = await _categoryProvider.get();
      if (result.items != null) {
        setState(() {
          _categories = result.items!;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadGenres() async {
    try {
      final result = await _genreProvider.get();
      if (result.items != null) {
        setState(() {
          _genres = result.items!;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadDirectors() async {
    try {
      final result = await _directorProvider.get();
      if (result.items != null) {
        setState(() {
          _directors = result.items!;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _populateForm() {
    final movie = widget.movie!;
    _titleController.text = movie.title;
    _descriptionController.text = movie.description ?? '';
    _durationController.text = movie.duration.toString();
    _trailerController.text = movie.trailer ?? '';
    _releaseDate = movie.releaseDate;
    _selectedCategoryId = movie.categoryId;
    _selectedGenreId = movie.genreId;
    _selectedDirectorId = movie.directorId;
    _isActive = movie.isActive;
    _selectedImageBase64 = movie.poster;

    setState(() {});
  }

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        
        setState(() {
          _selectedImageBase64 = base64String;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageBase64 = null;
    });
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate()) return;
    if (_releaseDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a release date')),
      );
      return;
    }
    if (_selectedCategoryId == null || _selectedGenreId == null || _selectedDirectorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category, genre, and director')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'duration': int.parse(_durationController.text),
        'trailer': _trailerController.text.trim().isEmpty
            ? null
            : _trailerController.text.trim(),
        'releaseDate': _releaseDate!.toIso8601String(),
        'categoryId': _selectedCategoryId!,
        'genreId': _selectedGenreId!,
        'directorId': _selectedDirectorId!,
        'isActive': _isActive,
        'poster': _selectedImageBase64,
      };

      if (_isEditing) {
        await _movieProvider.update(widget.movie!.id, request);
      } else {
        await _movieProvider.insert(request);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Movie updated successfully!'
                  : 'Movie created successfully!',
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: _isEditing ? 'Edit Movie' : 'Add Movie',
      showBackButton: true,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 900,
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
            child: Form(
              key: _formKey,
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
                          _isEditing ? Icons.edit : Icons.add_circle_outline,
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
                              _isEditing ? 'Edit Movie' : 'Add New Movie',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              _isEditing 
                                  ? 'Update movie information and settings'
                                  : 'Create a new movie for the cinema system',
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

                  _buildBasicInfoCard(),
                  const SizedBox(height: 40),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
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
                          onPressed: _isLoading ? null : _saveMovie,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004AAD),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _isEditing ? 'Update Movie' : 'Create Movie',
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
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            // First two rows: Poster spans both rows, Title/Duration on first row, Description on second row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster column - spans both rows
                _buildPosterColumn(),
                const SizedBox(width: 20),
                // Right side content
                Expanded(
                  child: Column(
                    children: [
                      // First row: Title and Duration
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _titleController,
                              decoration: customTextFieldDecoration(
                                'Movie Title',
                                prefixIcon: Icons.movie,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter a movie title';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: TextFormField(
                              controller: _durationController,
                              decoration: customTextFieldDecoration(
                                'Duration (minutes)',
                                prefixIcon: Icons.schedule,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter duration';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Second row: Description spans full width
                      TextFormField(
                        controller: _descriptionController,
                        decoration: customTextFieldDecoration(
                          'Description',
                          prefixIcon: Icons.description,
                        ),
                        maxLines: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _trailerController,
              decoration: customTextFieldDecoration(
                'Trailer URL',
                prefixIcon: Icons.play_circle_outline,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDateField(
                    'Release Date',
                    _releaseDate,
                    (date) => setState(() => _releaseDate = date),
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildDropdown(
                    'Category',
                    _selectedCategoryId,
                    _categories
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    (value) => setState(() => _selectedCategoryId = value),
                    Icons.category,
                    'Select Category',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    'Genre',
                    _selectedGenreId,
                    _genres
                        .map(
                          (g) => DropdownMenuItem(
                            value: g.id,
                            child: Text(g.name),
                          ),
                        )
                        .toList(),
                    (value) => setState(() => _selectedGenreId = value),
                    Icons.movie_filter,
                    'Select Genre',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildDropdown(
                    'Director',
                    _selectedDirectorId,
                    _directors
                        .map(
                          (d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.fullName),
                          ),
                        )
                        .toList(),
                    (value) => setState(() => _selectedDirectorId = value),
                    Icons.person,
                    'Select Director',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                    "Active",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: Text(
                    "Movie is available for screening and booking",
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  value: _isActive,
                  onChanged: (value) => setState(() => _isActive = value),
                  activeColor: const Color(0xFF10B981),
                  inactiveThumbColor: const Color(0xFFEF4444),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
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

  Widget _buildPosterColumn() {
    return Column(
      children: [
        Text(
          'Movie Poster',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 160,
          height: 190, // Height to span both rows (title + duration + description)
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _selectedImageBase64 != null && _selectedImageBase64!.isNotEmpty
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        base64Decode(_selectedImageBase64!),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFE2E8F0),
                            child: const Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                size: 50,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: _removeImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 50,
                          color: const Color(0xFF64748B),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap to select image",
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "JPG, PNG, GIF supported",
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }




  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onDateSelected,
    IconData icon,
  ) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                    : label,
                style: TextStyle(
                  color: selectedDate != null
                      ? Colors.black
                      : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    int? selectedValue,
    List<DropdownMenuItem<int>> items,
    Function(int?) onChanged,
    IconData icon,
    String hint,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonFormField<int>(
        value: selectedValue,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: InputBorder.none,
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        items: [
          DropdownMenuItem<int>(value: null, child: Text('Select $label')),
          ...items,
        ],
        onChanged: onChanged,
        validator: (value) {
          if (value == null) {
            return 'Please select a $label';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _trailerController.dispose();
    super.dispose();
  }
}