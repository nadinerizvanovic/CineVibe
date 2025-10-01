import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_mobile/providers/movie_provider.dart';
import 'package:cinevibe_mobile/providers/user_provider.dart';
import 'package:cinevibe_mobile/model/movie.dart';
import 'dart:convert';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  bool _isLoadingRecommendation = false;
  bool _isLoadingMovies = false;
  int _selectedCategoryId = 1; // 1 = In Theaters, 2 = Upcoming, 3 = Classics
  Movie? _recommendedMovie;
  List<Movie> _movies = [];
  late MovieProvider _movieProvider;

  @override
  void initState() {
    super.initState();
    _movieProvider = Provider.of<MovieProvider>(context, listen: false);
    _loadRecommendation();
    _loadMovies();
  }

  Future<void> _loadRecommendation() async {
    if (UserProvider.currentUser == null) return;

    setState(() {
      _isLoadingRecommendation = true;
    });

    try {
      final recommendation = await _movieProvider.getRecommendation(UserProvider.currentUser!.id);

      if (mounted) {
        setState(() {
          _recommendedMovie = recommendation;
          _isLoadingRecommendation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendation = false;
        });
        // Silently fail for recommendations - not critical
        print("Failed to load recommendation: $e");
      }
    }
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoadingMovies = true;
    });

    try {
      final result = await _movieProvider.get(
        filter: {
          'categoryId': _selectedCategoryId,
          'isActive': true,
          'page': 0,
          'pageSize': 100,
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        setState(() {
          _movies = result.items ?? [];
          _isLoadingMovies = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMovies = false;
        });
        print("Failed to load movies: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadRecommendation();
          await _loadMovies();
        },
        color: const Color(0xFF004AAD),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recommended for You Section
              _buildRecommendedSection(),
              
              const SizedBox(height: 24),
              
              // Category Switch
              _buildCategorySwitch(),
              
              const SizedBox(height: 16),
              
              // Movies List
              _buildMoviesList(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recommended for You',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Recommended Movie Card
          _isLoadingRecommendation
              ? _buildLoadingCard()
              : _recommendedMovie != null
                  ? _buildRecommendedMovieCard(_recommendedMovie!)
                  : _buildNoRecommendationCard(),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AAD)),
        ),
      ),
    );
  }

  Widget _buildNoRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF004AAD).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.movie_filter_outlined,
              size: 48,
              color: Color(0xFF004AAD),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Recommendations Yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Watch some movies to get personalized recommendations!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedMovieCard(Movie movie) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster on the left
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: movie.poster != null
                  ? Image.memory(
                      base64Decode(movie.poster!),
                      width: 100,
                      height: 140,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 100,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF004AAD).withOpacity(0.3),
                            const Color(0xFF1E40AF).withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.movie_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            
            // Movie Details on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Genre and Category Tags in one row
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (movie.genreName != null && movie.genreName!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF004AAD).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            movie.genreName!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF004AAD),
                            ),
                          ),
                        ),
                      if (movie.categoryName != null && movie.categoryName!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7B61B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            movie.categoryName!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF7B61B),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Director and Duration in one row
                  Row(
                    children: [
                      // Director
                      if (movie.directorName != null && movie.directorName!.isNotEmpty) ...[
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            movie.directorName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      // Duration
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.duration} min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  
                  // Book Tickets Button
                  Container(
                    width: double.infinity,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF004AAD).withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // TODO: Navigate to movie details/screening selection
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Movie details coming soon!'),
                              backgroundColor: const Color(0xFF004AAD),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_activity_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                            SizedBox(width: 8),
                            Text(
                              'More Details',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySwitch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSwitchButton(
              text: 'In Theaters',
              isSelected: _selectedCategoryId == 1,
              onTap: () {
                setState(() {
                  _selectedCategoryId = 1;
                });
                _loadMovies();
              },
            ),
          ),
          Expanded(
            child: _buildSwitchButton(
              text: 'Upcoming',
              isSelected: _selectedCategoryId == 2,
              onTap: () {
                setState(() {
                  _selectedCategoryId = 2;
                });
                _loadMovies();
              },
            ),
          ),
          Expanded(
            child: _buildSwitchButton(
              text: 'Classics',
              isSelected: _selectedCategoryId == 3,
              onTap: () {
                setState(() {
                  _selectedCategoryId = 3;
                });
                _loadMovies();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004AAD) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildMoviesList() {
    if (_isLoadingMovies) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AAD)),
        ),
      );
    }

    if (_movies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF004AAD).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.movie_filter_outlined,
                size: 48,
                color: Color(0xFF004AAD),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Movies Found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedCategoryId == 1
                  ? 'No movies in theaters at the moment.'
                  : _selectedCategoryId == 2
                      ? 'No upcoming movies at the moment.'
                      : 'No classic movies available.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _movies.map((movie) => _buildMovieCard(movie)).toList(),
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster on the left
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: movie.poster != null
                  ? Image.memory(
                      base64Decode(movie.poster!),
                      width: 100,
                      height: 140,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 100,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF004AAD).withOpacity(0.3),
                            const Color(0xFF1E40AF).withOpacity(0.3),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.movie_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            
            // Movie Details on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Genre and Category Tags in one row
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (movie.genreName != null && movie.genreName!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF004AAD).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            movie.genreName!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF004AAD),
                            ),
                          ),
                        ),
                      if (movie.categoryName != null && movie.categoryName!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7B61B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            movie.categoryName!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF7B61B),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Director and Duration in one row
                  Row(
                    children: [
                      // Director
                      if (movie.directorName != null && movie.directorName!.isNotEmpty) ...[
                        const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            movie.directorName!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      // Duration
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.duration} min',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  
                  // More Details Button
                  Container(
                    width: double.infinity,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF004AAD).withOpacity(0.3),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // TODO: Navigate to movie details/screening selection
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Movie details coming soon!'),
                              backgroundColor: const Color(0xFF004AAD),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_activity_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'More Details',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

