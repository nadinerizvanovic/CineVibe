import 'package:flutter/material.dart';
import 'package:cinevibe_desktop/model/ticket.dart';
import 'package:cinevibe_desktop/layouts/master_screen.dart';

class TicketDetailsScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailsScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Ticket Details",
      showBackButton: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTicketHeader(),
              const SizedBox(height: 10),
              _buildTicketInfo(),
              const SizedBox(height: 10),
              _buildScreeningInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketHeader() {
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
          _buildTicketIcon(),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ticket #${ticket.id}',
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
                    ticket.movieTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF004AAD),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: ticket.isActive 
                        ? const Color(0xFF10B981).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ticket.isActive 
                          ? const Color(0xFF10B981).withOpacity(0.3)
                          : const Color(0xFFEF4444).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ticket.isActive ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: ticket.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        ticket.isActive ? 'Active Ticket' : 'Inactive Ticket',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ticket.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
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
    );
  }

  Widget _buildTicketIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
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
      child: CircleAvatar(
        radius: 60,
        backgroundColor: const Color(0xFF004AAD),
        child: Icon(
          Icons.confirmation_number_rounded,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTicketInfo() {
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
                  Icons.confirmation_number_outlined,
                  size: 24,
                  color: Color(0xFF004AAD),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Ticket Information',
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
          icon: Icons.person_outline,
          label: 'User',
          value: ticket.userFullName,
          color: const Color(0xFF3B82F6),
        ),
        _buildInfoCard(
          icon: Icons.chair_outlined,
          label: 'Seat Number',
          value: ticket.seatNumber,
          color: const Color(0xFF10B981),
        ),
        _buildInfoCard(
          icon: Icons.location_on_outlined,
          label: 'Hall',
          value: ticket.hallName,
          color: const Color(0xFFF59E0B),
        ),
        _buildInfoCard(
          icon: Icons.movie_outlined,
          label: 'Movie',
          value: ticket.movieTitle,
          color: const Color(0xFF8B5CF6),
        ),
        _buildInfoCard(
          icon: Icons.calendar_today_outlined,
          label: 'Created At',
          value: '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}',
          color: const Color(0xFFEF4444),
        ),
        _buildInfoCard(
          icon: Icons.access_time_outlined,
          label: 'Screening Time',
          value: '${ticket.screeningStartTime.day}/${ticket.screeningStartTime.month}/${ticket.screeningStartTime.year} ${ticket.screeningStartTime.hour.toString().padLeft(2, '0')}:${ticket.screeningStartTime.minute.toString().padLeft(2, '0')}',
          color: const Color(0xFF06B6D4),
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E293B),
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

  Widget _buildScreeningInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF7B61B).withOpacity(0.1),
                      const Color(0xFFF7B61B).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFF7B61B).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.movie_filter_outlined,
                  size: 20,
                  color: Color(0xFFF7B61B),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Screening Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF7B61B).withOpacity(0.1),
                  const Color(0xFFF7B61B).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF7B61B).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.movie_outlined,
                      size: 20,
                      color: const Color(0xFFF7B61B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ticket.movieTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_outlined,
                      size: 16,
                      color: const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${ticket.screeningStartTime.day}/${ticket.screeningStartTime.month}/${ticket.screeningStartTime.year} at ${ticket.screeningStartTime.hour.toString().padLeft(2, '0')}:${ticket.screeningStartTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${ticket.hallName} - Seat ${ticket.seatNumber}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.movie_filter_outlined,
                      size: 16,
                      color: const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ticket.screeningTypeName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
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
}
