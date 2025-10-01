import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_desktop/model/screening.dart';
import 'package:cinevibe_desktop/model/screening_with_seats.dart';
import 'package:cinevibe_desktop/model/movie.dart';
import 'package:cinevibe_desktop/providers/screening_provider.dart';
import 'package:cinevibe_desktop/providers/movie_provider.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'dart:convert';

class ScreeningDetailsScreen extends StatefulWidget {
  final Screening screening;

  const ScreeningDetailsScreen({super.key, required this.screening});

  @override
  State<ScreeningDetailsScreen> createState() => _ScreeningDetailsScreenState();
}

class _ScreeningDetailsScreenState extends State<ScreeningDetailsScreen> {
  late ScreeningProvider screeningProvider;
  late MovieProvider movieProvider;

  ScreeningWithSeats? screeningWithSeats;
  Movie? movie;
  Map<String, List<SeatWithTicketInfo>> groupedSeats = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      screeningProvider = context.read<ScreeningProvider>();
      movieProvider = context.read<MovieProvider>();
      await _loadScreeningSeats();
      await _loadMovie();
    });
  }

  Future<void> _loadScreeningSeats() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Load screening with seats and ticket information
      final result = await screeningProvider.getScreeningWithSeats(widget.screening.id);
      setState(() {
        screeningWithSeats = result;
        if (result != null) {
          groupedSeats = _groupSeatsByRow(result.seats);
        }
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadMovie() async {
    try {
      final movieResult = await movieProvider.getById(widget.screening.movieId);
      setState(() {
        movie = movieResult;
      });
    } catch (e) {
      // Movie loading is optional, don't set error state
      debugPrint('Error loading movie: $e');
    }
  }

  Map<String, List<SeatWithTicketInfo>> _groupSeatsByRow(List<SeatWithTicketInfo> seats) {
    Map<String, List<SeatWithTicketInfo>> grouped = {};
    for (var seat in seats) {
      String rowLetter = seat.seatNumber.substring(0, 1);
      if (!grouped.containsKey(rowLetter)) {
        grouped[rowLetter] = [];
      }
      grouped[rowLetter]!.add(seat);
    }
    
    // Sort seats within each row by seat number
    grouped.forEach((key, value) {
      value.sort((a, b) {
        int aNum = int.tryParse(a.seatNumber.substring(1)) ?? 0;
        int bNum = int.tryParse(b.seatNumber.substring(1)) ?? 0;
        return aNum.compareTo(bNum);
      });
    });
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Screening Details - ${widget.screening.movieTitle}",
      showBackButton: true,
      child: SingleChildScrollView(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading screening details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadScreeningSeats,
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildScreeningHeader(),
                        const SizedBox(height: 20),
                        _buildScreeningInfo(),
                        const SizedBox(height: 20),
                        _buildSeatGrid(),
                        
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildScreeningHeader() {
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
                  'Screening #${widget.screening.id}',
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
                    widget.screening.movieTitle,
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
                        '${widget.screening.movieDuration} min',
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
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF3B82F6).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        widget.screening.screeningTypeName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.screening.isActive 
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: widget.screening.isActive 
                              ? const Color(0xFF10B981).withOpacity(0.3)
                              : const Color(0xFFEF4444).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.screening.isActive ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: widget.screening.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.screening.isActive ? 'Active Screening' : 'Inactive Screening',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: widget.screening.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
        child: movie?.poster != null && movie!.poster!.isNotEmpty
            ? Image.memory(
                base64Decode(movie!.poster!),
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

  Widget _buildScreeningInfo() {
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
                'Screening Information',
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
          icon: Icons.meeting_room_outlined,
          label: 'Hall',
          value: widget.screening.hallName,
          color: const Color(0xFF004AAD),
        ),
        _buildInfoCard(
          icon: Icons.movie_filter_outlined,
          label: 'Screening Type',
          value: widget.screening.screeningTypeName,
          color: const Color(0xFF3B82F6),
        ),
        _buildInfoCard(
          icon: Icons.schedule_outlined,
          label: 'Start Time',
          value: '${widget.screening.startTime.hour.toString().padLeft(2, '0')}:${widget.screening.startTime.minute.toString().padLeft(2, '0')}',
          color: const Color(0xFF10B981),
        ),
        _buildInfoCard(
          icon: Icons.schedule_outlined,
          label: 'End Time',
          value: '${widget.screening.endTime.hour.toString().padLeft(2, '0')}:${widget.screening.endTime.minute.toString().padLeft(2, '0')}',
          color: const Color(0xFFEF4444),
        ),
        _buildInfoCard(
          icon: Icons.access_time_outlined,
          label: 'Duration',
          value: '${widget.screening.movieDuration} minutes',
          color: const Color(0xFF8B5CF6),
        ),
        _buildInfoCard(
          icon: Icons.attach_money_outlined,
          label: 'Price',
          value: '\$${widget.screening.price.toStringAsFixed(2)}',
          color: const Color(0xFFF7B61B),
        ),
      ],
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

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF004AAD),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Legend',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004AAD),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLegendItem(
                color: const Color(0xFF3B82F6),
                label: 'Standard',
                icon: Icons.chair_rounded,
              ),
              _buildLegendItem(
                color: const Color(0xFFEC4899),
                label: 'Love Seat',
                icon: Icons.chair_rounded,
              ),
              _buildLegendItem(
                color: const Color(0xFF10B981),
                label: 'Wheelchair',
                icon: Icons.chair_rounded,
              ),
              _buildLegendItem(
                color: const Color(0xFFEF4444),
                label: 'Occupied',
                icon: Icons.chair_rounded,
              ),
              _buildLegendItem(
                color: const Color(0xFF6B7280),
                label: 'Disabled',
                icon: Icons.chair_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black26, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 12,
            color: _getTextColorForSeat(color),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildSeatGrid() {
    if (groupedSeats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF004AAD).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.chair_outlined,
                size: 64,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No seats found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This screening doesn\'t have any seats configured.',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Screen representation
              Container(
                width: double.infinity,
                height: 80,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF004AAD).withOpacity(0.15),
                      const Color(0xFF004AAD).withOpacity(0.05),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF004AAD).withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF004AAD).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'SCREEN',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF004AAD),
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              
              // Seat grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSeatRows(),
              ),
              const SizedBox(height: 20),
            ],
          ),
          
          // Legend positioned at top right
          Positioned(
            top: 20,
            right: 20,
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatRows() {
    // Sort rows alphabetically (A, B, C, etc.)
    var sortedRows = groupedSeats.keys.toList()..sort();
    
    return Column(
      children: sortedRows.map((rowLetter) => _buildSeatRow(rowLetter, groupedSeats[rowLetter]!)).toList(),
    );
  }

  Widget _buildSeatRow(String rowLetter, List<SeatWithTicketInfo> rowSeats) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Row letter label
          Container(
            width: 36,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF004AAD).withOpacity(0.15),
                  const Color(0xFF004AAD).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF004AAD).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004AAD).withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                rowLetter,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF004AAD),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Seats in this row
          ...rowSeats.map((seat) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildSeat(seat),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSeat(SeatWithTicketInfo seat) {
    Color seatColor = _getSeatColor(seat);
    String seatNumber = seat.seatNumber.substring(1); // Remove row letter, keep number
    
    return Tooltip(
      message: seat.isOccupied 
          ? '${seat.seatNumber} - Occupied by ${seat.userFullName ?? "Unknown User"}'
          : '${seat.seatNumber} - ${seat.seatTypeName ?? "Standard"} (Available)',
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              seatColor,
              seatColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: seatColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Seat icon background
            Center(
              child: Icon(
                Icons.chair_rounded,
                size: 28,
                color: _getTextColorForSeat(seatColor).withOpacity(0.3),
              ),
            ),
            // Seat number
            Center(
              child: Text(
                seatNumber,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _getTextColorForSeat(seatColor),
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            // Occupied indicator
            if (seat.isOccupied)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getSeatColor(SeatWithTicketInfo seat) {
    if (!seat.isActive) {
      return const Color(0xFF6B7280); // Gray for disabled seats
    }

    if (seat.isOccupied) {
      return const Color(0xFFEF4444); // Red for occupied seats
    }

    switch (seat.seatTypeId) {
      case 1: // Standard
        return const Color(0xFF3B82F6); // Blue
      case 2: // Love Seat
        return const Color(0xFFEC4899); // Pink
      case 3: // Wheelchair
        return const Color(0xFF10B981); // Green
      default:
        return const Color(0xFF3B82F6); // Default blue for standard/unknown active seats
    }
  }

  Color _getTextColorForSeat(Color seatColor) {
    // Calculate luminance to determine if text should be white or black
    double luminance = (0.299 * seatColor.red + 0.587 * seatColor.green + 0.114 * seatColor.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
