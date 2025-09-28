import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_desktop/model/hall.dart';
import 'package:cinevibe_desktop/model/seat.dart';
import 'package:cinevibe_desktop/model/seat_type.dart';
import 'package:cinevibe_desktop/providers/seat_provider.dart';
import 'package:cinevibe_desktop/providers/seat_type_provider.dart';
import 'package:cinevibe_desktop/providers/hall_provider.dart';
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
  late HallProvider hallProvider;

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
      hallProvider = context.read<HallProvider>();
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
                  : Column(
                      children: [
                        if (seats.isEmpty) _buildGenerateSeatsButton(),
                        const SizedBox(height: 20),
                        _buildSeatGrid(),
                      ],
                    ),
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

  Widget _buildGenerateSeatsButton() {
    return Container(
      padding: const EdgeInsets.all(20),
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
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.add_circle_outline,
              size: 48,
              color: const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No seats configured',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This hall doesn\'t have any seats yet. Generate seats to get started.',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showGenerateSeatsDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'Generate Seats',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGenerateSeatsDialog() {
    int rows = 10;
    int seatsPerRow = 10;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Color(0xFF3B82F6),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Generate Seats',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          'For ${widget.hall.name}',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Configure the seat layout for this hall:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          label: 'Number of Rows',
                          value: rows,
                          onChanged: (value) {
                            setState(() {
                              rows = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildNumberField(
                          label: 'Seats per Row',
                          value: seatsPerRow,
                          onChanged: (value) {
                            setState(() {
                              seatsPerRow = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF3B82F6).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFF3B82F6),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'This will create ${rows * seatsPerRow} seats (${rows} rows × ${seatsPerRow} seats)',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF3B82F6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _generateSeats(rows, seatsPerRow);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Generate Seats',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '$value',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            final intValue = int.tryParse(value);
            if (intValue != null && intValue > 0 && intValue <= 50) {
              onChanged(intValue);
            }
          },
        ),
      ],
    );
  }

  Future<void> _generateSeats(int rows, int seatsPerRow) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF3B82F6)),
                const SizedBox(height: 20),
                const Text(
                  'Generating seats...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          );
        },
      );

      final success = await hallProvider.generateSeatsForHall(widget.hall.id, rows, seatsPerRow);
      
      // Hide loading dialog
      Navigator.of(context).pop();

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Seats generated successfully!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        // Reload the seats
        await _loadSeats();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to generate seats. Please try again.'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      // Hide loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
