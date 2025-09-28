import 'package:cinevibe_desktop/model/search_result.dart';
import 'package:cinevibe_desktop/utils/base_dropdown.dart';

import 'package:cinevibe_desktop/utils/base_pagination.dart';
import 'package:cinevibe_desktop/utils/base_table_design.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_desktop/providers/screening_provider.dart';
import 'package:cinevibe_desktop/providers/hall_provider.dart';
import 'package:cinevibe_desktop/model/screening.dart';
import 'package:cinevibe_desktop/model/hall.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:cinevibe_desktop/utils/base_date_picker.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/screens/screening_details_screen.dart';
import 'package:cinevibe_desktop/screens/screening_add_edit_screen.dart';

class ScreeningListScreen extends StatefulWidget {
  const ScreeningListScreen({super.key});

  @override
  State<ScreeningListScreen> createState() => _ScreeningListScreenState();
}

class _ScreeningListScreenState extends State<ScreeningListScreen> {
  late ScreeningProvider screeningProvider;
  late HallProvider hallProvider;

  TextEditingController movieTitleController = TextEditingController();
  int? selectedHallId;
  DateTime? selectedDateOfScreening;
  int? selectedScreeningTypeId;
  List<Hall> halls = [];

  SearchResult<Screening>? screenings;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      screeningProvider = context.read<ScreeningProvider>();
      hallProvider = context.read<HallProvider>();
      await _loadHalls();
      await _performSearch(page: 0);
    });
  }

  Future<void> _loadHalls() async {
    try {
      var hallsResult = await hallProvider.get();
      setState(() {
        halls = hallsResult.items ?? [];
      });
    } catch (e) {
      print("Error loading halls: $e");
    }
  }

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "MovieTitle": movieTitleController.text.isNotEmpty ? movieTitleController.text : null,
      "HallId": selectedHallId,
      "DateOfScreening": selectedDateOfScreening?.toIso8601String(),
      "ScreeningTypeId": selectedScreeningTypeId,
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true,
    };
    debugPrint(filter.toString());
    var screeningsResult = await screeningProvider.get(filter: filter);
    debugPrint(screeningsResult.items?.firstOrNull?.movieTitle);
    setState(() {
      this.screenings = screeningsResult;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Screenings",
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
              label: "Search by Movie Title",
              controller: movieTitleController,
              prefixIcon: Icons.search,
              hintText: "Enter movie title",
              onSubmitted: _performSearch,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: customDropdownField<int?>(
              label: "Filter by Hall",
              value: selectedHallId,
              prefixIcon: Icons.location_on,
              hintText: "Select a hall",
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text("All Halls"),
                ),
                ...(halls.map((hall) => DropdownMenuItem<int?>(
                  value: hall.id,
                  child: Text("${hall.name} (${hall.seatCount} seats)"),
                ))),
              ],
              onChanged: (value) {
                setState(() {
                  selectedHallId = value;
                });
                _performSearch();
              },
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: customDatePicker(
              context: context,
              placeholderText: "Date of Screening",
              value: selectedDateOfScreening,
              onChanged: (date) {
                setState(() {
                  selectedDateOfScreening = date;
                });
                _performSearch();
              },
              prefixIcon: Icons.calendar_today,
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
            text: "Add Screening",
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreeningAddEditScreen(),
                  settings: const RouteSettings(name: 'ScreeningAddEditScreen'),
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
    final isEmpty = screenings == null || screenings!.items == null || screenings!.items!.isEmpty;
    final int totalCount = screenings?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTableDesign(
            icon: Icons.movie_rounded,
            title: "Screenings Management",
            width: 1400,
            height: 500,
            columnWidths: [250, 110, 100, 140, 100, 100, 160], // Movie, Hall, Type, Start Time, Duration, Price, Occupied, Status, Actions
            columns: [
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
                  "Hall",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Type",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Start Time",
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
                  "Occupied",
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
                : screenings!.items!
                      .map(
                        (e) => DataRow(
                          cells: [
                            DataCell(
                              Center(
                                child: Text(
                                  e.movieTitle,
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
                                  e.hallName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
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
                                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    e.screeningTypeName,
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
                                child: Text(
'${e.startTime.day.toString().padLeft(2, '0')}.${e.startTime.month.toString().padLeft(2, '0')}.${e.startTime.year} '
'${e.startTime.hour.toString().padLeft(2, '0')}:${e.startTime.minute.toString().padLeft(2, '0')}'                                 
,style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
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
                                    color: const Color(0xFF10B981).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF10B981).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${e.movieDuration} min',
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFEF4444).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${e.occupiedSeatsCount}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFEF4444),
                                    ),
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
                                            builder: (context) => ScreeningDetailsScreen(screening: e),
                                            settings: const RouteSettings(
                                              name: 'ScreeningDetailsScreen',
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
                                            builder: (context) => ScreeningAddEditScreen(screening: e),
                                            settings: const RouteSettings(
                                              name: 'ScreeningAddEditScreen',
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            emptyIcon: Icons.movie_outlined,
            emptyText: "No screenings found",
            emptySubtext: "Try adjusting your search criteria to find screenings.",
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
