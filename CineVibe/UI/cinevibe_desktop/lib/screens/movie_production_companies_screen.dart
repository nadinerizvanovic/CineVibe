import 'package:cinevibe_desktop/model/production_company.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:flutter/material.dart';
import 'package:cinevibe_desktop/model/movie.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/providers/movie_provider.dart';
import 'package:cinevibe_desktop/providers/production_company_provider.dart';
import 'package:cinevibe_desktop/utils/base_searchable_dropdown.dart';
import 'package:provider/provider.dart';

class MovieProductionCompaniesScreen extends StatefulWidget {
  final Movie movie;

  const MovieProductionCompaniesScreen({super.key, required this.movie});

  @override
  State<MovieProductionCompaniesScreen> createState() => _MovieProductionCompaniesScreenState();
}

class _MovieProductionCompaniesScreenState extends State<MovieProductionCompaniesScreen> {
  late MovieProvider movieProvider;
  late ProductionCompanyProvider productionCompanyProvider;
  List<ProductionCompany> allCompanies = [];
  List<ProductionCompany> movieCompanies = [];
  List<ProductionCompany> selectedCompanies = [];
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    movieProvider = Provider.of<MovieProvider>(context, listen: false);
    productionCompanyProvider = Provider.of<ProductionCompanyProvider>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => isLoading = true);
      
      // Load all production companies
      final companiesResult = await productionCompanyProvider.get(filter: {"pageSize": 1000});
      allCompanies = companiesResult.items ?? [];
      
      // Load movie production companies
      movieCompanies = await movieProvider.getMovieProductionCompanies(widget.movie.id);
      
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

  Future<void> _assignCompanies() async {
    if (selectedCompanies.isEmpty) return;

    setState(() => isSaving = true);
    try {
      // Store the count before clearing
      final assignedCount = selectedCompanies.length;
      
      for (final company in selectedCompanies) {
        await movieProvider.assignProductionCompanyToMovie(widget.movie.id, company.id);
      }
      
      // Refresh movie production companies
      movieCompanies = await movieProvider.getMovieProductionCompanies(widget.movie.id);
      
      setState(() {
        selectedCompanies.clear();
        isSaving = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$assignedCount production company(ies) assigned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error assigning production companies: $e'),
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

  Future<void> _removeCompany(ProductionCompany company) async {
    try {
      final success = await movieProvider.removeProductionCompanyFromMovie(widget.movie.id, company.id);
      if (success) {
        setState(() {
          movieCompanies.removeWhere((c) => c.id == company.id);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${company.name} removed from movie'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove production company'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing production company: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Movie Production Companies - ${widget.movie.title}",
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
                        _buildCurrentCompaniesSection(),
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
            const Color(0xFFF7B61B).withOpacity(0.05),
            const Color(0xFFF7B61B).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF7B61B).withOpacity(0.1),
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
              color: const Color(0xFFF7B61B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF7B61B).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.business_outlined,
              size: 32,
              color: Color(0xFFF7B61B),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Production Companies',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Assign and manage production companies for "${widget.movie.title}"',
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
                    color: const Color(0xFFF7B61B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF7B61B).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${movieCompanies.length} company(ies) assigned',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF7B61B),
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
                  Icons.business_center_outlined,
                  size: 24,
                  color: Color(0xFF004AAD),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Assign New Production Companies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Filter out already assigned companies
          ProductionCompanySearchableDropdown(
            companies: allCompanies.where((company) => 
              !movieCompanies.any((movieCompany) => movieCompany.id == company.id)
            ).toList(),
            selectedCompanies: selectedCompanies,
            onChanged: (companies) {
              setState(() {
                selectedCompanies = companies;
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
                onPressed: selectedCompanies.isEmpty || isSaving
                    ? null
                    : _assignCompanies,
                icon: Icons.business_center,
                backgroundColor: const Color(0xFFF7B61B),
                isLoading: isSaving,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentCompaniesSection() {
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
                  Icons.business,
                  size: 24,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Current Production Companies',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (movieCompanies.isEmpty)
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
                      Icons.business_outlined,
                      size: 48,
                      color: Color(0xFF64748B),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No production companies assigned to this movie',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Use the section above to assign production companies',
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
              children: movieCompanies.map((company) => _buildCompanyCard(company)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(ProductionCompany company) {
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF7B61B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF7B61B).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.business,
              size: 20,
              color: Color(0xFFF7B61B),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (company.country != null)
                Text(
                  company.country!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _removeCompany(company),
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
