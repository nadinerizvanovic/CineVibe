import 'package:cinevibe_desktop/model/actor.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:flutter/material.dart';
import 'package:cinevibe_desktop/model/movie.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/providers/movie_provider.dart';
import 'package:cinevibe_desktop/providers/actor_provider.dart';
import 'package:cinevibe_desktop/utils/base_searchable_dropdown.dart';
import 'package:provider/provider.dart';

class MovieActorsScreen extends StatefulWidget {
  final Movie movie;

  const MovieActorsScreen({super.key, required this.movie});

  @override
  State<MovieActorsScreen> createState() => _MovieActorsScreenState();
}

class _MovieActorsScreenState extends State<MovieActorsScreen> {
  late MovieProvider movieProvider;
  late ActorProvider actorProvider;
  List<Actor> allActors = [];
  List<Actor> movieActors = [];
  List<Actor> selectedActors = [];
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    movieProvider = Provider.of<MovieProvider>(context, listen: false);
    actorProvider = Provider.of<ActorProvider>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);
      
      // Load all actors
      final actorsResult = await actorProvider.get(filter: {"pageSize": 1000});
      allActors = actorsResult.items ?? [];
      
      // Load movie actors
      movieActors = await movieProvider.getMovieActors(widget.movie.id);
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignActors() async {
    if (selectedActors.isEmpty) return;

    setState(() => isSaving = true);
    try {
      // Store the count before clearing
      final assignedCount = selectedActors.length;
      
      for (final actor in selectedActors) {
        await movieProvider.assignActorToMovie(widget.movie.id, actor.id);
      }
      
      // Refresh movie actors
      movieActors = await movieProvider.getMovieActors(widget.movie.id);
      
      setState(() {
        selectedActors.clear();
        isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$assignedCount actor(s) assigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error assigning actors: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveAndGoBack() async {
    // Navigate back with success flag to refresh movie list
    Navigator.pop(context, true);
  }

  Future<void> _removeActor(Actor actor) async {
    try {
      final success = await movieProvider.removeActorFromMovie(widget.movie.id, actor.id);
      if (success) {
        setState(() {
          movieActors.removeWhere((a) => a.id == actor.id);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${actor.firstName} ${actor.lastName} removed from movie'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove actor'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing actor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Movie Actors - ${widget.movie.title}",
      showBackButton: true,
      child: Stack(
        children: [
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildAssignSection(),
                        const SizedBox(height: 24),
                        _buildCurrentActorsSection(),
                        const SizedBox(height: 80), // Space for floating button
                      ],
                    ),
                  ),
                ),
          // Floating Save Button
          Positioned(
            bottom: 24,
            right: 24,
            child: customElevatedButton(
              text: "Save",
              onPressed: _saveAndGoBack,
              icon: Icons.save,
              backgroundColor: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.05),
            const Color(0xFF8B5CF6).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 32,
              color: Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Actors',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Assign and manage actors for "${widget.movie.title}"',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${movieActors.length} actor(s) assigned',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF004AAD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_add_outlined,
                  size: 24,
                  color: Color(0xFF004AAD),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Assign New Actors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Filter out already assigned actors
          ActorSearchableDropdown(
            actors: allActors.where((actor) => 
              !movieActors.any((movieActor) => movieActor.id == actor.id)
            ).toList(),
            selectedActors: selectedActors,
            onChanged: (actors) {
              setState(() {
                selectedActors = actors;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              customElevatedButton(
                text: "Assign Selected",
                onPressed: selectedActors.isEmpty || isSaving
                    ? null
                    : _assignActors,
                icon: Icons.person_add,
                backgroundColor: const Color(0xFF8B5CF6),
                isLoading: isSaving,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentActorsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.people_outline,
                  size: 24,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Current Actors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (movieActors.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.person_off_outlined,
                      size: 48,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No actors assigned to this movie',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Use the section above to assign actors',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: movieActors.map((actor) => _buildActorCard(actor)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildActorCard(Actor actor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
            child: Text(
              '${actor.firstName[0]}${actor.lastName[0]}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8B5CF6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${actor.firstName} ${actor.lastName}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _removeActor(actor),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
