import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_desktop/model/hall.dart';
import 'package:cinevibe_desktop/model/seat.dart';
import 'package:cinevibe_desktop/model/seat_type.dart';
import 'package:cinevibe_desktop/providers/seat_provider.dart';
import 'package:cinevibe_desktop/providers/seat_type_provider.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';
import 'package:cinevibe_desktop/screens/hall_seat_type_screen.dart';

class HallSeatListScreen extends StatefulWidget {
  final Hall hall;

  const HallSeatListScreen({super.key, required this.hall});

  @override
  State<HallSeatListScreen> createState() => _HallSeatListScreenState();
}

class _HallSeatListScreenState extends State<HallSeatListScreen> {
  late SeatProvider seatProvider;
  late SeatTypeProvider seatTypeProvider;

  List<Seat> seats = [];
  List<SeatType> seatTypes = [];
  Map<String, List<Seat>> groupedSeats = {};
  Map<int, SeatType> seatTypesMap = {};
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      seatProvider = context.read<SeatProvider>();
      seatTypeProvider = context.read<SeatTypeProvider>();
      await _loadSeats();
    });
  }

  Future<void> _loadSeats() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Load seat types first
      final typesResult = await seatTypeProvider.get(filter: {"pageSize": 1000});
      setState(() {
        seatTypes = typesResult.items ?? [];
        seatTypesMap = {for (var type in typesResult.items ?? []) type.id: type};
      });

      // Load seats grouped by row
      final groupedSeatsResult = await seatProvider.getSeatsGroupedByRow(widget.hall.id);
      setState(() {
        groupedSeats = groupedSeatsResult;
        seats = groupedSeatsResult.values.expand((x) => x).toList();
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

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "${widget.hall.name} - Seats",
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
                          'Error loading seats',
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
                          onPressed: _loadSeats,
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  : _buildSeatGrid(),
        ),
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
            children: seatTypes.map((seatType) => _buildLegendItem(seatType)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(SeatType seatType) {
    Color seatColor = _getSeatTypeColor(seatType.id);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: seatColor,
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
            Icons.chair_rounded,
            size: 12,
            color: _getTextColorForSeat(seatColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          seatType.name,
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
              'This hall doesn\'t have any seats configured.',
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

  Widget _buildSeatRow(String rowLetter, List<Seat> rowSeats) {
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

  Widget _buildSeat(Seat seat) {
    Color seatColor = _getSeatTypeColor(seat.seatTypeId);
    String seatNumber = seat.seatNumber.substring(1); // Remove row letter, keep number
    
    return Tooltip(
      message: '${seat.seatNumber} - ${seat.seatTypeName ?? "Standard"}\nClick to edit seat type',
      child: GestureDetector(
        onTap: () => _editSeatType(seat),
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
              // Edit indicator
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: seatColor,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 8,
                    color: seatColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeatTypeColor(int? seatTypeId) {
    if (seatTypeId == null) {
      return const Color(0xFF6B7280); // Default gray for seats without type
    }
    
    switch (seatTypeId) {
      case 1: // Standard
        return const Color(0xFF3B82F6); // Blue
      case 2: // Love Seat
        return const Color(0xFFEC4899); // Pink
      case 3: // Wheelchair
        return const Color(0xFF10B981); // Green
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  Color _getTextColorForSeat(Color seatColor) {
    // Calculate luminance to determine if text should be white or black
    double luminance = (0.299 * seatColor.red + 0.587 * seatColor.green + 0.114 * seatColor.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Future<void> _editSeatType(Seat seat) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => HallSeatTypeScreen(seat: seat),
        settings: const RouteSettings(name: 'HallSeatTypeScreen'),
      ),
    );

    // If the seat type was updated, reload the seats
    if (result == true) {
      await _loadSeats();
    }
  }
}
