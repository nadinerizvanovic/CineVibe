import 'dart:convert';
import 'dart:typed_data';
import 'package:cinevibe_mobile/providers/user_provider.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Helper for base64 image handling
  static ImageProvider? getUserImageProvider(String? picture) {
    if (picture == null || picture.isEmpty) {
      return null;
    }
    try {
      Uint8List bytes = base64Decode(picture);
      return MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = UserProvider.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user data available'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          // Modern Sliver App Bar
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF004AAD),
                      const Color(0xFF1E40AF),
                      const Color(0xFF3B82F6),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Profile Picture on the left
                        Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    spreadRadius: 0,
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                backgroundImage: getUserImageProvider(user.picture),
                                child: user.picture == null || user.picture!.isEmpty
                                    ? const Icon(
                                        Icons.person,
                                        size: 40,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                            // Online status indicator
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: user.isActive ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  user.isActive ? Icons.check : Icons.close,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        
                        // User Information on the right
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // User Name
                              Text(
                                '${user.firstName} ${user.lastName}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              
                              // Username
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '@${user.username}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              
                              // Email with icon
                              Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      user.email,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Modern Content Cards
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.location_city,
                        title: 'City',
                        value: user.cityName,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.person_outline,
                        title: 'Gender',
                        value: user.genderName,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Personal Information Card with modern design
                _buildModernInfoCard(
                  title: 'Personal Information',
                  icon: Icons.person_outline,
                  children: [
                    _buildModernInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'First Name',
                      value: user.firstName,
                    ),
                    _buildModernInfoRow(
                      icon: Icons.badge_outlined,
                      label: 'Last Name',
                      value: user.lastName,
                    ),
                    _buildModernInfoRow(
                      icon: Icons.alternate_email,
                      label: 'Username',
                      value: user.username,
                    ),
                    _buildModernInfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user.email,
                    ),
                    if (user.phoneNumber != null)
                      _buildModernInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: user.phoneNumber!,
                      ),
                  ],
                ),
                
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Modern stat card for quick info
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Modern info card with enhanced design
  Widget _buildModernInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF004AAD).withOpacity(0.1),
                        const Color(0xFF1E40AF).withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF004AAD),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  // Modern info row with icons
  Widget _buildModernInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF004AAD).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF004AAD),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
