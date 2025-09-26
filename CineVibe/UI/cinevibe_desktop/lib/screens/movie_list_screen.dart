import 'package:cinevibe_desktop/model/search_result.dart';
import 'package:cinevibe_desktop/utils/base_pagination.dart';
import 'package:cinevibe_desktop/utils/base_table_design.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_desktop/providers/movie_provider.dart';
import 'package:cinevibe_desktop/providers/genre_provider.dart';
import 'package:cinevibe_desktop/model/movie.dart';
import 'package:cinevibe_desktop/model/genre.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:cinevibe_desktop/utils/base_dropdown.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/screens/movie_add_edit_screen.dart';
import 'package:cinevibe_desktop/screens/movie_details_screen.dart';
import 'package:cinevibe_desktop/screens/movie_actors_screen.dart';
import 'package:cinevibe_desktop/screens/movie_production_companies_screen.dart';
import 'dart:convert';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  late MovieProvider movieProvider;
  late GenreProvider genreProvider;

  TextEditingController titleController = TextEditingController();
  Genre? selectedGenre;
  List<Genre> genres = [];

  SearchResult<Movie>? movies;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      movieProvider = context.read<MovieProvider>();
      genreProvider = context.read<GenreProvider>();
      await _loadGenres();
      await _performSearch(page: 0);
    });
  }

  Future<void> _loadGenres() async {
    try {
      final genresResult = await genreProvider.get(filter: {"pageSize": 1000});
      setState(() {
        genres = genresResult.items ?? [];
      });
    } catch (e) {
      debugPrint('Error loading genres: $e');
    }
  }

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "Title": titleController.text.isNotEmpty ? titleController.text : null,
      "GenreId": selectedGenre?.id,
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true,
    };
    debugPrint(filter.toString());
    var moviesResult = await movieProvider.get(filter: filter);
    debugPrint(moviesResult.items?.firstOrNull?.title);
    setState(() {
      this.movies = moviesResult;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Movies",
      child: Center(
        child: Column(
          children: [
            _buildSearch(),
            Expanded(child: _buildResultView()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: customTextField(
              label: "Search by Title",
              controller: titleController,
              prefixIcon: Icons.search,
              hintText: "Enter movie title",
              onSubmitted: _performSearch,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: customDropdownField<Genre>(
              label: "Filter by Genre",
              value: selectedGenre,
              items: [
                DropdownMenuItem<Genre>(
                  value: null,
                  child: Text("All Genres"),
                ),
                ...genres.map((genre) => DropdownMenuItem<Genre>(
                  value: genre,
                  child: Text(genre.name),
                )),
              ],
              hintText: "All Genres",
              onChanged: (genre) {
                setState(() {
                  selectedGenre = genre;
                });
                _performSearch();
              },
              prefixIcon: Icons.movie_filter_outlined,
            ),
          ),
          SizedBox(width: 10),
          customElevatedButton(
            text: "Search",
            onPressed: _performSearch,
            icon: Icons.search,
          ),
          SizedBox(width: 10),
          customElevatedButton(
            text: "Add Movie",
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieAddEditScreen(),
                  settings: const RouteSettings(name: 'MovieAddEditScreen'),
                ),
              );
              if (result == true) {
                await _performSearch(page: 0);
              }
            },
            icon: Icons.add,
            backgroundColor: const Color(0xFF004AAD),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty = movies == null || movies!.items == null || movies!.items!.isEmpty;
    final int totalCount = movies?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTableDesign(
            icon: Icons.movie_rounded,
            title: "Movies Management",
            width: 1400,
            height: 500,
            columnWidths: [75, 250, 90, 90, 102, 400], // Poster, Title, Duration, Status, Genre, Actions
            columns: [
              DataColumn(
                label: Text(
                  "Poster",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Movie Title",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
                            DataColumn(
                label: Text(
                  "Genre",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Duration",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Status",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),

 
              DataColumn(
                label: Text(
                  "Actions",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
            ],
            rows: isEmpty
                ? []
                : movies!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Center(
                                child: _buildMoviePoster(e.poster),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Text(
                                  e.title,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              
                              ),
                            ),
                                                 DataCell(
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF8B5CF6).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    e.genreName ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF8B5CF6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF10B981).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${e.duration} min',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: e.isActive 
                                        ? const Color(0xFF10B981).withOpacity(0.1)
                                        : const Color(0xFFEF4444).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: e.isActive 
                                          ? const Color(0xFF10B981).withOpacity(0.3)
                                          : const Color(0xFFEF4444).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        e.isActive ? Icons.check_circle : Icons.cancel,
                                        size: 12,
                                        color: e.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        e.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: e.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
       
         
                            DataCell(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Details Button
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MovieDetailsScreen(movie: e),
                                            settings: const RouteSettings(
                                              name: 'MovieDetailsScreen',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFF10B981).withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.visibility_rounded,
                                              size: 14,
                                              color: const Color(0xFF10B981),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Details',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF10B981),
                                                height: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Edit Button
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MovieAddEditScreen(movie: e),
                                            settings: const RouteSettings(
                                              name: 'MovieAddEditScreen',
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          await _performSearch(page: _currentPage);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF004AAD).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFF004AAD).withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.edit_rounded,
                                              size: 14,
                                              color: const Color(0xFF004AAD),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Edit',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF004AAD),
                                                height: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Actors Button
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MovieActorsScreen(movie: e),
                                            settings: const RouteSettings(
                                              name: 'MovieActorsScreen',
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          await _performSearch(page: _currentPage);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF8B5CF6).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFF8B5CF6).withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.person_rounded,
                                              size: 14,
                                              color: const Color(0xFF8B5CF6),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Actors',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF8B5CF6),
                                                height: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Production Companies Button
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => MovieProductionCompaniesScreen(movie: e),
                                            settings: const RouteSettings(
                                              name: 'MovieProductionCompaniesScreen',
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          await _performSearch(page: _currentPage);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF7B61B).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFFF7B61B).withOpacity(0.2),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.business_rounded,
                                              size: 14,
                                              color: const Color(0xFFF7B61B),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Companies',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFFF7B61B),
                                                height: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            emptyIcon: Icons.movie_outlined,
            emptyText: "No movies found",
            emptySubtext: "Try adjusting your search criteria or add a new movie to get started.",
          ),
          SizedBox(height: 30),
          BasePagination(
            currentPage: _currentPage,
            totalPages: totalPages,
            onPrevious: isFirstPage
                ? null
                : () => _performSearch(page: _currentPage - 1),
            onNext: isLastPage
                ? null
                : () => _performSearch(page: _currentPage + 1),
            showPageSizeSelector: true,
            pageSize: _pageSize,
            pageSizeOptions: _pageSizeOptions,
            onPageSizeChanged: (newSize) {
              if (newSize != null && newSize != _pageSize) {
                _performSearch(page: 0, pageSize: newSize);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoviePoster(String? poster) {
    if (poster == null || poster.isEmpty) {
      return Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.movie_outlined,
          size: 32,
          color: Color(0xFF64748B),
        ),
      );
    }

    try {
      return Container(
        width: 60,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(poster),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFFE2E8F0),
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 32,
                  color: Color(0xFF64748B),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      return Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.broken_image_outlined,
          size: 32,
          color: Color(0xFF64748B),
        ),
      );
    }
  }
}
