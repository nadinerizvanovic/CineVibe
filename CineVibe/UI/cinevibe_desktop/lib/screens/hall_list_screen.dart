import 'package:cinevibe_desktop/model/search_result.dart';
import 'package:cinevibe_desktop/utils/base_pagination.dart';
import 'package:cinevibe_desktop/utils/base_table_design.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_desktop/providers/hall_provider.dart';
import 'package:cinevibe_desktop/model/hall.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/screens/hall_seat_list_screen.dart';
import 'package:cinevibe_desktop/screens/hall_add_edit_screen.dart';

class HallListScreen extends StatefulWidget {
  const HallListScreen({super.key});

  @override
  State<HallListScreen> createState() => _HallListScreenState();
}

class _HallListScreenState extends State<HallListScreen> {
  late HallProvider hallProvider;

  TextEditingController nameController = TextEditingController();

  SearchResult<Hall>? halls;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      hallProvider = context.read<HallProvider>();
      await _performSearch(page: 0);
    });
  }

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "Name": nameController.text.isNotEmpty ? nameController.text : null,
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true,
    };
    debugPrint(filter.toString());
    var hallsResult = await hallProvider.get(filter: filter);
    debugPrint(hallsResult.items?.firstOrNull?.name);
    setState(() {
      this.halls = hallsResult;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Halls",
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
              label: "Search by Name",
              controller: nameController,
              prefixIcon: Icons.search,
              hintText: "Enter hall name",
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
            text: "Add Hall",
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HallAddEditScreen(),
                  settings: const RouteSettings(name: 'HallAddEditScreen'),
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
    final isEmpty = halls == null || halls!.items == null || halls!.items!.isEmpty;
    final int totalCount = halls?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTableDesign(
            icon: Icons.meeting_room_rounded,
            title: "Halls Management",
            width: 1200,
            height: 500,
            columnWidths: [250, 120, 120, 120, 400], // Name, Seat Count, Status, Created Date, Actions
            columns: [
              DataColumn(
                label: Text(
                  "Hall Name",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Seat Count",
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
                  "Created Date",
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
                : halls!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                 
                                    Text(
                                      e.name,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${e.seatCount} seats',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF3B82F6),
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
                              Center(
                                child: Text(
                                  '${e.createdAt.day}/${e.createdAt.month}/${e.createdAt.year}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // View Seats Button
                                  MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => HallSeatListScreen(hall: e),
                                            settings: const RouteSettings(
                                              name: 'HallSeatListScreen',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                              Icons.chair_rounded,
                                              size: 14,
                                              color: const Color(0xFF10B981),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'View Seats',
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
                                            builder: (context) => HallAddEditScreen(hall: e),
                                            settings: const RouteSettings(
                                              name: 'HallAddEditScreen',
                                            ),
                                          ),
                                        );
                                        if (result == true) {
                                          await _performSearch(page: _currentPage);
                                        }
                                      },
                                      child: Container(
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
            emptyIcon: Icons.meeting_room_outlined,
            emptyText: "No halls found",
            emptySubtext: "Try adjusting your search criteria to find halls.",
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
