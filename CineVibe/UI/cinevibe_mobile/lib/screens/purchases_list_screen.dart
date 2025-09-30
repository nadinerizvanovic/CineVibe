import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_mobile/providers/ticket_provider.dart';
import 'package:cinevibe_mobile/providers/user_provider.dart';
import 'package:cinevibe_mobile/model/ticket.dart';
import 'package:cinevibe_mobile/screens/ticket_details_screen.dart';
import 'dart:convert';

class PurchasesListScreen extends StatefulWidget {
  const PurchasesListScreen({super.key});

  @override
  State<PurchasesListScreen> createState() => _PurchasesListScreenState();
}

class _PurchasesListScreenState extends State<PurchasesListScreen>
    with SingleTickerProviderStateMixin {
  bool _isTicketsSelected = true;
  bool _isLoading = false;
  List<Ticket> _tickets = [];
  late TicketProvider _ticketProvider;

  @override
  void initState() {
    super.initState();
    _ticketProvider = Provider.of<TicketProvider>(context, listen: false);
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    if (UserProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _ticketProvider.get(
        filter: {
          'userId': UserProvider.currentUser!.id,
          'page': 0,
          'pageSize': 1000,
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        setState(() {
          _tickets = result.items ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog("Failed to load tickets: $e");
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text("Error"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF004AAD),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Switch Header
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSwitchButton(
                    text: 'Tickets',
                    isSelected: _isTicketsSelected,
                    onTap: () {
                      setState(() {
                        _isTicketsSelected = true;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildSwitchButton(
                    text: 'Snacks',
                    isSelected: !_isTicketsSelected,
                    onTap: () {
                      setState(() {
                        _isTicketsSelected = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Content based on selection
          Expanded(
            child: _isTicketsSelected ? _buildTicketsContent() : _buildSnacksContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004AAD) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketsContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AAD)),
        ),
      );
    }

    if (_tickets.isEmpty) {
      return _buildEmptyState(
        icon: Icons.confirmation_number_outlined,
        title: "No Tickets Found",
        description: "You haven't purchased any tickets yet.\nStart exploring movies to book your first ticket!",
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTickets,
      color: const Color(0xFF004AAD),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return _buildTicketCard(ticket);
        },
      ),
    );
  }

  Widget _buildSnacksContent() {
    return _buildEmptyState(
      icon: Icons.fastfood_outlined,
      title: "Snacks Coming Soon",
      description: "Snack ordering feature will be available soon.\nStay tuned for delicious movie treats!",
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF004AAD).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 64,
                color: const Color(0xFF004AAD),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TicketDetailsScreen(ticket: ticket),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with movie poster, title and status
                Row(
                  children: [
                    // Movie poster
                    Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ticket.moviePoster.isNotEmpty
                            ? Image.memory(
                                base64Decode(ticket.moviePoster),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.movie_outlined,
                                      color: Colors.grey,
                                      size: 24,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.movie_outlined,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Movie title and status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.movieTitle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: ticket.isActive 
                                  ? const Color(0xFF10B981).withOpacity(0.1)
                                  : const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: ticket.isActive 
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              ticket.isActive ? 'Active' : 'Inactive',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ticket.isActive 
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Ticket details
                _buildTicketDetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Hall',
                  value: ticket.hallName,
                ),
                const SizedBox(height: 8),
                _buildTicketDetailRow(
                  icon: Icons.event_seat_outlined,
                  label: 'Seat',
                  value: ticket.seatNumber,
                ),
                const SizedBox(height: 8),
                _buildTicketDetailRow(
                  icon: Icons.schedule_outlined,
                  label: 'Showtime',
                  value: _formatDateTime(ticket.screeningStartTime),
                ),
                const SizedBox(height: 8),
                _buildTicketDetailRow(
                  icon: Icons.movie_outlined,
                  label: 'Type',
                  value: ticket.screeningTypeName,
                ),
                const SizedBox(height: 16),

                // Footer with arrow
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004AAD).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF004AAD),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final ticketDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (ticketDate == today) {
      return 'Today at ${_formatTime(dateTime)}';
    } else if (ticketDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow at ${_formatTime(dateTime)}';
    } else {
      return '${_formatDate(dateTime)} at ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }
}
