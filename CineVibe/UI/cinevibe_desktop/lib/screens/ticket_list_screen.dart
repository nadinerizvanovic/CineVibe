import 'package:cinevibe_desktop/model/search_result.dart';
import 'package:cinevibe_desktop/utils/base_pagination.dart';
import 'package:cinevibe_desktop/utils/base_table_design.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_desktop/providers/ticket_provider.dart';
import 'package:cinevibe_desktop/providers/hall_provider.dart';
import 'package:cinevibe_desktop/model/ticket.dart';
import 'package:cinevibe_desktop/model/hall.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:cinevibe_desktop/utils/base_dropdown.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/screens/ticket_details_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  late TicketProvider ticketProvider;
  late HallProvider hallProvider;

  TextEditingController movieTitleController = TextEditingController();
  TextEditingController userFullNameController = TextEditingController();
  int? selectedHallId;
  List<Hall> halls = [];

  SearchResult<Ticket>? tickets;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ticketProvider = context.read<TicketProvider>();
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
      "MovieName": movieTitleController.text.isNotEmpty ? movieTitleController.text : null,
      "UserFullName": userFullNameController.text.isNotEmpty ? userFullNameController.text : null,
      "HallId": selectedHallId,
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true,
    };
    debugPrint(filter.toString());
    var ticketsResult = await ticketProvider.get(filter: filter);
    debugPrint(ticketsResult.items?.firstOrNull?.movieTitle);
    setState(() {
      this.tickets = ticketsResult;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Tickets",
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
            child: customTextField(
              label: "Search by Customer",
              controller: userFullNameController,
              prefixIcon: Icons.person,
              hintText: "Enter user full name",
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
                ...halls.map((hall) => DropdownMenuItem<int?>(
                  value: hall.id,
                  child: Text("${hall.name} (${hall.seatCount} seats)"),
                )),
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
          customElevatedButton(
            text: "Search",
            onPressed: _performSearch,
            icon: Icons.search,
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final isEmpty = tickets == null || tickets!.items == null || tickets!.items!.isEmpty;
    final int totalCount = tickets?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTableDesign(
            icon: Icons.confirmation_number_rounded,
            title: "Tickets Management",
            width: 1400,
            height: 500,
            columnWidths: [270, 180, 60, 100, 140, 80, 120], // Movie, User, Seat, Hall, Screening Time, Type, Status, Actions
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
                  "Customer",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Seat",
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
                  "Screening Time",
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
                : tickets!.items!
                      .map(
                        (e) => DataRow(
                          onSelectChanged: (value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketDetailsScreen(ticket: e),
                                settings: const RouteSettings(
                                  name: 'TicketDetailsScreen',
                                ),
                              ),
                            );
                          },
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
                                  e.userFullName,
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
                                    e.seatNumber,
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
                                child: Text(
                                  '${e.screeningStartTime.day}/${e.screeningStartTime.month}/${e.screeningStartTime.year} ${e.screeningStartTime.hour.toString().padLeft(2, '0')}:${e.screeningStartTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 12,
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
                                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFF59E0B).withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    e.screeningTypeName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFF59E0B),
                                    ),
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
                                      color: const Color(0xFF10B981).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFF10B981).withOpacity(0.3),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
            emptyIcon: Icons.confirmation_number_outlined,
            emptyText: "No tickets found",
            emptySubtext: "Try adjusting your search criteria to find tickets.",
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
