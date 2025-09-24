import 'package:cinevibe_desktop/model/search_result.dart';
import 'package:cinevibe_desktop/utils/base_pagination.dart';
import 'package:cinevibe_desktop/utils/base_table_design.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_desktop/providers/actor_provider.dart';
import 'package:cinevibe_desktop/model/actor.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/screens/actor_details_screen.dart';

class ActorListScreen extends StatefulWidget {
  const ActorListScreen({super.key});

  @override
  State<ActorListScreen> createState() => _ActorListScreenState();
}

class _ActorListScreenState extends State<ActorListScreen> {
  late ActorProvider actorProvider;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();

  SearchResult<Actor>? actors;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  // Search for actors with ENTER key, not only when button is clicked
  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "FirstName": firstNameController.text,
      "LastName": lastNameController.text,
      "FullName": fullNameController.text,
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true, // Ensure backend returns total count
    };
    debugPrint(filter.toString());
    var actors = await actorProvider.get(filter: filter);
    debugPrint(actors.items?.firstOrNull?.fullName);
    setState(() {
      this.actors = actors;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  void initState() {
    super.initState();
    // Delay to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      actorProvider = context.read<ActorProvider>();
      await _performSearch(page: 0);
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Actors",
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
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: customTextField(
                  label: "Search by Full Name",
                  controller: fullNameController,
                  prefixIcon: Icons.search,
                  hintText: "Enter full name",
                  onSubmitted: _performSearch,
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
                text: "Add Actor",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActorDetailsScreen(),
                      settings: const RouteSettings(name: 'ActorDetailsScreen'),
                    ),
                  );
                },
                icon: Icons.add,
                backgroundColor: const Color(0xFF004AAD),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty =
        actors == null || actors!.items == null || actors!.items!.isEmpty;
    final int totalCount = actors?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTableDesign(
            icon: Icons.person_rounded,
            title: "Actors Management",
            width: 1200,
            height: 500,
            columnWidths: [250, 250, 150, 150, 200], // First Name, Last Name, Movies Count, Status, Actions
            columns: [
              DataColumn(
                label: Text(
                  "First Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Last Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Movies Count",
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
                : actors!.items!
                      .map(
                        (e) => DataRow(
                          onSelectChanged: (value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ActorDetailsScreen(actor: e),
                                settings: const RouteSettings(
                                  name: 'ActorDetailsScreen',
                                ),
                              ),
                            );
                          },
                          cells: [
                            DataCell(
                              Center(
                                child: Text(
                                  e.firstName,
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
                                child: Text(
                                  e.lastName,
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
                                    color: const Color(0xFFF7B61B).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFF7B61B).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${e.movieCount} movies',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF7B61B),
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                            height: 1.0, // Remove extra line height
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
                      )
                      .toList(),
            emptyIcon: Icons.person_outlined,
            emptyText: "No actors found",
            emptySubtext: "Try adjusting your search criteria or add a new actor to get started.",
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
}
