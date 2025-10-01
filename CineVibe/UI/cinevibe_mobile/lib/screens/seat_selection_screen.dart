import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_mobile/model/screening.dart';
import 'package:cinevibe_mobile/model/screening_with_seats.dart';
import 'package:cinevibe_mobile/providers/screening_provider.dart';
import 'package:intl/intl.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Screening screening;

  const SeatSelectionScreen({super.key, required this.screening});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  late ScreeningProvider _screeningProvider;
  ScreeningWithSeats? _screeningWithSeats;
  Map<String, List<SeatWithTicketInfo>> _groupedSeats = {};
  Set<int> _selectedSeatIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _screeningProvider = Provider.of<ScreeningProvider>(context, listen: false);
    _loadScreeningSeats();
  }

  Future<void> _loadScreeningSeats() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _screeningProvider.getScreeningWithSeats(widget.screening.id);
      
      if (mounted) {
        setState(() {
          _screeningWithSeats = result;
          if (result != null) {
            _groupedSeats = _groupSeatsByRow(result.seats);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
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

  void _toggleSeat(SeatWithTicketInfo seat) {
    if (seat.isOccupied || !seat.isActive) return;

    setState(() {
      if (_selectedSeatIds.contains(seat.id)) {
        _selectedSeatIds.remove(seat.id);
      } else {
        _selectedSeatIds.add(seat.id);
      }
    });
  }

  double _calculateTotalPrice() {
    return _selectedSeatIds.length * widget.screening.price;
  }

  List<String> _getSelectedSeatNumbers() {
    if (_screeningWithSeats == null) return [];
    
    return _selectedSeatIds.map((seatId) {
      final seat = _screeningWithSeats!.seats.firstWhere((s) => s.id == seatId);
      return seat.seatNumber;
    }).toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Select Your Seats',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: const Color(0xFF004AAD),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AAD)),
              ),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildScreeningInfo(),
                            const SizedBox(height: 16),
                            _buildLegend(),
                            const SizedBox(height: 20),
                            _buildScreen(),
                            const SizedBox(height: 20),
                            _buildSeatGrid(),
                            SizedBox(height: _selectedSeatIds.isNotEmpty ? 220 : 40), // Dynamic space for bottom bar
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
      bottomSheet: _selectedSeatIds.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFE53E3E),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Error Loading Seats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadScreeningSeats,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AAD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreeningInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.screening.movieTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.meeting_room_outlined,
                widget.screening.hallName,
                const Color(0xFF004AAD),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.movie_filter_outlined,
                widget.screening.screeningTypeName,
                const Color(0xFF3B82F6),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(
                Icons.schedule_outlined,
                DateFormat('MMM d, HH:mm').format(widget.screening.startTime),
                const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                Icons.attach_money_outlined,
                '\$${widget.screening.price.toStringAsFixed(2)}/seat',
                const Color(0xFFF7B61B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFF004AAD),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Legend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildLegendItem(const Color(0xFF3B82F6), 'Standard'),
              _buildLegendItem(const Color(0xFFEC4899), 'Love Seat'),
              _buildLegendItem(const Color(0xFF10B981), 'Wheelchair'),
              _buildLegendItem(const Color(0xFF004AAD), 'Selected'),
              _buildLegendItem(const Color(0xFFEF4444), 'Occupied'),
              _buildLegendItem(const Color(0xFF6B7280), 'Disabled'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.chair_rounded,
            size: 14,
            color: Colors.white,
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

  Widget _buildScreen() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF004AAD).withOpacity(0.15),
            const Color(0xFF004AAD).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF004AAD).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Text(
        'SCREEN',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF004AAD),
          letterSpacing: 3,
        ),
      ),
    );
  }

  Widget _buildSeatGrid() {
    if (_groupedSeats.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
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
            const Icon(
              Icons.chair_outlined,
              size: 64,
              color: Color(0xFF64748B),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Seats Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      );
    }

    var sortedRows = _groupedSeats.keys.toList()..sort();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: sortedRows.map((rowLetter) {
            return _buildSeatRow(rowLetter, _groupedSeats[rowLetter]!);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSeatRow(String rowLetter, List<SeatWithTicketInfo> rowSeats) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // Row label
          Container(
            width: 28,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF004AAD).withOpacity(0.15),
                  const Color(0xFF004AAD).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF004AAD).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                rowLetter,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004AAD),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Seats
          ...rowSeats.map((seat) => Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _buildSeat(seat),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildSeat(SeatWithTicketInfo seat) {
    final isSelected = _selectedSeatIds.contains(seat.id);
    final seatColor = _getSeatColor(seat, isSelected);
    final seatNumber = seat.seatNumber.substring(1); // Remove row letter

    return GestureDetector(
      onTap: () => _toggleSeat(seat),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              seatColor,
              seatColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: seatColor.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : [
            BoxShadow(
              color: seatColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Seat icon background
            Center(
              child: Icon(
                Icons.chair_rounded,
                size: 18,
                color: _getIconColor(seatColor).withOpacity(0.3),
              ),
            ),
            // Seat number
            Center(
              child: Text(
                seatNumber,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _getIconColor(seatColor),
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
              const Positioned(
                top: 2,
                right: 2,
                child: Icon(
                  Icons.person,
                  size: 10,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getSeatColor(SeatWithTicketInfo seat, bool isSelected) {
    if (!seat.isActive) {
      return const Color(0xFF6B7280); // Gray for disabled
    }

    if (seat.isOccupied) {
      return const Color(0xFFEF4444); // Red for occupied
    }

    if (isSelected) {
      return const Color(0xFF004AAD); // Dark blue for selected
    }

    // Available seats by type
    switch (seat.seatTypeId) {
      case 1: // Standard
        return const Color(0xFF3B82F6); // Light blue
      case 2: // Love Seat
        return const Color(0xFFEC4899); // Pink
      case 3: // Wheelchair
        return const Color(0xFF10B981); // Green
      default:
        return const Color(0xFF3B82F6); // Default to standard
    }
  }

  Color _getIconColor(Color seatColor) {
    // Calculate luminance to determine if text should be white or black
    double luminance = (0.299 * seatColor.red + 0.587 * seatColor.green + 0.114 * seatColor.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Widget _buildBottomBar() {
    final totalPrice = _calculateTotalPrice();
    final selectedSeats = _getSelectedSeatNumbers();
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selected seats info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF004AAD).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF004AAD).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.event_seat,
                      color: Color(0xFF004AAD),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selectedSeats.length} Seat${selectedSeats.length > 1 ? 's' : ''} Selected',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedSeats.join(', '),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF004AAD),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Proceed to Payment Button
              Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF004AAD).withOpacity(0.4),
                      spreadRadius: 0,
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // TODO: Navigate to payment screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Proceeding to payment for ${selectedSeats.length} seat(s) - \$${totalPrice.toStringAsFixed(2)}'),
                          backgroundColor: const Color(0xFF10B981),
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
                            Icons.payment,
                            color: Colors.white,
                            size: 22,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Proceed to Payment',
                            style: TextStyle(
                              fontSize: 18,
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
      ),
    );
  }
}

