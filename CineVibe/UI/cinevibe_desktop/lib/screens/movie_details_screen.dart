import 'package:cinevibe_desktop/model/actor.dart';
import 'package:cinevibe_desktop/model/production_company.dart';
import 'package:flutter/material.dart';
import 'package:cinevibe_desktop/model/movie.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'dart:convert';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Movie Details",
      showBackButton: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMovieHeader(),
              const SizedBox(height: 20),
              _buildMovieInfo(),
              const SizedBox(height: 20),
              _buildActorsSection(),
              const SizedBox(height: 20),
              _buildProductionCompaniesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMovieHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF004AAD).withOpacity(0.05),
            const Color(0xFFF7B61B).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildMoviePoster(),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Movie #${movie.id}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF004AAD).withOpacity(0.15),
                        const Color(0xFF004AAD).withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF004AAD).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF004AAD),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${movie.duration} min',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: movie.isActive 
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: movie.isActive 
                              ? const Color(0xFF10B981).withOpacity(0.3)
                              : const Color(0xFFEF4444).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            movie.isActive ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: movie.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            movie.isActive ? 'Active Movie' : 'Inactive Movie',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: movie.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviePoster() {
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: movie.poster != null && movie.poster!.isNotEmpty
            ? Image.memory(
                base64Decode(movie.poster!),
                width: 120,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF004AAD),
                    child: const Icon(
                      Icons.movie_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                },
              )
            : Container(
                color: const Color(0xFF004AAD),
                child: const Icon(
                  Icons.movie_rounded,
                  size: 50,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildMovieInfo() {
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
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF004AAD).withOpacity(0.1),
                      const Color(0xFF004AAD).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF004AAD).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.movie_outlined,
                  size: 24,
                  color: Color(0xFF004AAD),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Movie Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoGrid(),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 4.0,
      children: [
        _buildInfoCard(
          icon: Icons.movie_outlined,
          label: 'Movie Title',
          value: movie.title,
          color: const Color(0xFF004AAD),
        ),
        _buildInfoCard(
          icon: Icons.schedule,
          label: 'Duration',
          value: '${movie.duration} minutes',
          color: const Color(0xFF10B981),
        ),
        _buildInfoCard(
          icon: Icons.calendar_today_outlined,
          label: 'Release Date',
          value: '${movie.releaseDate.day}/${movie.releaseDate.month}/${movie.releaseDate.year}',
          color: const Color(0xFFEF4444),
        ),
        _buildInfoCard(
          icon: Icons.category_outlined,
          label: 'Category',
          value: movie.categoryName ?? 'N/A',
          color: const Color(0xFF8B5CF6),
        ),
        _buildInfoCard(
          icon: Icons.movie_filter_outlined,
          label: 'Genre',
          value: movie.genreName ?? 'N/A',
          color: const Color(0xFFF7B61B),
        ),
        _buildInfoCard(
          icon: Icons.person_outline,
          label: 'Director',
          value: movie.directorName ?? 'N/A',
          color: const Color(0xFF06B6D4),
        ),
      ],
    );
  }

  Widget _buildActorsSection() {
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
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8B5CF6).withOpacity(0.1),
                      const Color(0xFF8B5CF6).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.person_outlined,
                  size: 24,
                  color: Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Actors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
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
                  '${movie.actorCount ?? 0} actors',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (movie.actors != null && movie.actors!.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: movie.actors!.map((actor) => _buildActorChip(actor)).toList(),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Text(
                  'No actors assigned to this movie',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductionCompaniesSection() {
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
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF7B61B).withOpacity(0.1),
                      const Color(0xFFF7B61B).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF7B61B).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  size: 24,
                  color: Color(0xFFF7B61B),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Production Companies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7B61B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFF7B61B).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${movie.productionCompanyCount ?? 0} companies',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF7B61B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (movie.productionCompanies != null && movie.productionCompanies!.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: movie.productionCompanies!.map((company) => _buildCompanyChip(company)).toList(),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: const Center(
                child: Text(
                  'No production companies assigned to this movie',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActorChip(Actor actor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        '${actor.firstName} ${actor.lastName}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFF8B5CF6),
        ),
      ),
    );
  }

  Widget _buildCompanyChip(ProductionCompany company) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF7B61B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF7B61B).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        company.name,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF7B61B),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF1E293B),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
