import 'package:cinevibe_desktop/model/search_result.dart';
import 'package:cinevibe_desktop/utils/base_pagination.dart';
import 'package:cinevibe_desktop/utils/base_table_design.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_desktop/providers/review_provider.dart';
import 'package:cinevibe_desktop/model/review.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:cinevibe_desktop/utils/base_dropdown.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/screens/review_details_screen.dart';

class ReviewListScreen extends StatefulWidget {
  const ReviewListScreen({super.key});

  @override
  State<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends State<ReviewListScreen> {
  late ReviewProvider reviewProvider;

  TextEditingController movieTitleController = TextEditingController();
  TextEditingController userFullNameController = TextEditingController();
  int? selectedRating;

  SearchResult<Review>? reviews;
  int _currentPage = 0;
  int _pageSize = 5;
  final List<int> _pageSizeOptions = [5, 7, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reviewProvider = context.read<ReviewProvider>();
      await _performSearch(page: 0);
    });
  }

  Future<void> _performSearch({int? page, int? pageSize}) async {
    final int pageToFetch = page ?? _currentPage;
    final int pageSizeToUse = pageSize ?? _pageSize;
    var filter = {
      "MovieName": movieTitleController.text.isNotEmpty ? movieTitleController.text : null,
      "UserFullName": userFullNameController.text.isNotEmpty ? userFullNameController.text : null,
      "Rating": selectedRating,
      "page": pageToFetch,
      "pageSize": pageSizeToUse,
      "includeTotalCount": true,
    };
    debugPrint(filter.toString());
    var reviewsResult = await reviewProvider.get(filter: filter);
    debugPrint(reviewsResult.items?.firstOrNull?.movieTitle);
    setState(() {
      this.reviews = reviewsResult;
      _currentPage = pageToFetch;
      _pageSize = pageSizeToUse;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Reviews",
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
              label: "Filter by Rating",
              value: selectedRating,
              prefixIcon: Icons.star,
              hintText: "Select rating",
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.star_border, size: 16, color: const Color(0xFFF59E0B)),
                      SizedBox(width: 8),
                      Text("All Ratings"),
                    ],
                  ),
                ),
                ...List.generate(5, (index) => DropdownMenuItem<int?>(
                  value: index + 1,
                  child: Row(
                    children: [
                      ...List.generate(5, (starIndex) => Icon(
                        starIndex < index + 1 ? Icons.star : Icons.star_border,
                        size: 16,
                        color: const Color(0xFFF59E0B),
                      )),
                      SizedBox(width: 8),
                      Text("${index + 1} Star${index + 1 > 1 ? 's' : ''}"),
                    ],
                  ),
                )),
              ],
              onChanged: (value) {
                setState(() {
                  selectedRating = value;
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
    final isEmpty = reviews == null || reviews!.items == null || reviews!.items!.isEmpty;
    final int totalCount = reviews?.totalCount ?? 0;
    final int totalPages = (totalCount / _pageSize).ceil();
    final bool isFirstPage = _currentPage == 0;
    final bool isLastPage = _currentPage >= totalPages - 1 || totalPages == 0;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          BaseTableDesign(
            icon: Icons.star_rounded,
            title: "Reviews Management",
            width: 1400,
            height: 500,
            columnWidths: [250, 150, 130, 230, 100, 120], // Movie, User, Rating, Hall, Comment, Date, Actions
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
                  "Rating",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
           
              DataColumn(
                label: Text(
                  "Comment",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF004AAD),
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Date",
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
                : reviews!.items!
                      .map(
                        (e) => DataRow(
                          onSelectChanged: (value) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewDetailsScreen(review: e),
                                settings: const RouteSettings(
                                  name: 'ReviewDetailsScreen',
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
                                child: _buildStarRating(e.rating),
                              ),
                            ),
                
                            DataCell(
                              Center(
                                child: Text(
                                  e.comment ?? 'No comment',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E293B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
            emptyIcon: Icons.star_outline,
            emptyText: "No reviews found",
            emptySubtext: "Try adjusting your search criteria to find reviews.",
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

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: const Color(0xFFF59E0B),
        );
      }),
    );
  }
}
