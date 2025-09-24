import 'package:cinevibe_desktop/main.dart';
import 'package:cinevibe_desktop/providers/user_provider.dart';
import 'package:cinevibe_desktop/screens/city_list_screen.dart';
import 'package:cinevibe_desktop/screens/actor_list_screen.dart';
import 'package:cinevibe_desktop/screens/category_list_screen.dart';
import 'package:cinevibe_desktop/screens/director_list_screen.dart';
import 'package:cinevibe_desktop/screens/production_company_list_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';


class MasterScreen extends StatefulWidget {
  const MasterScreen({
    super.key,
    required this.child,
    required this.title,
    this.showBackButton = false,
  });
  final Widget child;
  final String title;
  final bool showBackButton;

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Widget _buildUserAvatar() {
    final user = UserProvider.currentUser;
    final double radius = 22;
    ImageProvider? imageProvider;
    
    if (user?.picture != null && (user!.picture!.isNotEmpty)) {
      try {
        final sanitized = user.picture!.replaceAll(
          RegExp(r'^data:image/[^;]+;base64,'),
          '',
        );
        final bytes = base64Decode(sanitized);
        imageProvider = MemoryImage(bytes);
      } catch (_) {
        imageProvider = null;
      }
    }
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF004AAD),
        backgroundImage: imageProvider,
        child: imageProvider == null
            ? Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF004AAD),
                      const Color(0xFF1E40AF),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    _getUserInitials(user?.firstName, user?.lastName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  String _getUserInitials(String? firstName, String? lastName) {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isEmpty && l.isEmpty) return 'U';
    final a = f.isNotEmpty ? f[0] : '';
    final b = l.isNotEmpty ? l[0] : '';
    return (a + b).toUpperCase();
  }

  void _showProfileOverlay(BuildContext context) {
    final user = UserProvider.currentUser;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Profile',
      barrierColor: Colors.black54.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slideCurved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        
        return SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(
                top: kToolbarHeight + 16,
                right: 20,
              ),
              child: FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.2, -0.2),
                    end: Offset.zero,
                  ).animate(slideCurved),
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.9, end: 1.0).animate(curved),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 380,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF004AAD).withOpacity(0.15),
                              blurRadius: 32,
                              offset: const Offset(0, 16),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header with gradient background
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF004AAD).withOpacity(0.05),
                                      const Color(0xFFF7B61B).withOpacity(0.03),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildUserAvatar(),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user != null
                                                ? '${user.firstName} ${user.lastName}'
                                                : 'Guest User',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF1E293B),
                                              letterSpacing: -0.3,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFFF7B61B).withOpacity(0.15),
                                                  const Color(0xFFF7B61B).withOpacity(0.08),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFFF7B61B).withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              user?.username ?? 'guest',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF004AAD),
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                          width: 1,
                                        ),
                                      ),
                                      child: IconButton(
                                        onPressed: () => Navigator.of(context).maybePop(),
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 20,
                                        ),
                                        color: const Color(0xFF64748B),
                                        tooltip: 'Close',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Content section
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    // Email info card
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
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
                                              Icons.email_outlined,
                                              size: 20,
                                              color: Color(0xFF004AAD),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Email Address',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF64748B),
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  user?.email ?? 'No email provided',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Color(0xFF1E293B),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 20),
                                    
                                    // Action buttons
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 48,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF004AAD),
                                                  const Color(0xFF1E40AF),
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF004AAD).withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius: BorderRadius.circular(12),
                                                onTap: () {
                                                  Navigator.of(context).maybePop();
                                                  // Add profile settings navigation here
                                                },
                                                child: const Center(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.settings_rounded,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        'Profile Settings',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
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
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0xFF004AAD).withOpacity(0.1),
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.only(left: 8),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF004AAD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF004AAD).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.menu_rounded,
                  color: Color(0xFF004AAD),
                  size: 22,
                ),
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
                _animationController?.forward();
              },
            ),
          ),
        ),
        title: Row(
          children: [
            if (widget.showBackButton) ...[
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF004AAD),
                    size: 18,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
           
                    child: Text(
                      'Admin Dashboard',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const  Color(0xFF004AAD), // blue
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 24),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => _showProfileOverlay(context),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF004AAD).withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _buildUserAvatar(),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: 280,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: _slideAnimation != null
            ? AnimatedBuilder(
                animation: _slideAnimation!,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_slideAnimation!.value * 280, 0),
                    child: _buildDrawerContent(),
                  );
                },
              )
            : _buildDrawerContent(),
      ),
      body: Container(margin: const EdgeInsets.all(16), child: widget.child),
    );
  }

  Widget _buildDrawerContent() {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16, right: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF004AAD),
            const Color(0xFF1E40AF),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(6, 0),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/images/logo_large.png",
                    height: 56,
                    width: 106,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'CineVibe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7B61B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFF7B61B).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      color: const Color(0xFFF7B61B), // blue
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Navigation section - Scrollable
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // _modernDrawerTile(
                    //   context,
                    //   icon: Icons.analytics_outlined,
                    //   activeIcon: Icons.analytics,
                    //   label: 'Business Report',
                    //   screen: const BusinessReportScreen(),
                    // ),
                    // const SizedBox(height: 8),
                    // _modernDrawerTile(
                    //   context,
                    //   icon: Icons.festival,
                    //   activeIcon: Icons.festival,
                    //   label: 'Festivals',
                    //   screen: FestivalListScreen(),
                    // ),
                    // const SizedBox(height: 8),
                    // _modernDrawerTile(
                    //   context,
                    //   icon: Icons.confirmation_number_outlined,
                    //   activeIcon: Icons.confirmation_number,
                    //   label: 'Tickets',
                    //   screen: TicketListScreen(),
                    // ),
                    // const SizedBox(height: 8),
                    // _modernDrawerTile(
                    //   context,
                    //   icon: Icons.confirmation_number_outlined,
                    //   activeIcon: Icons.confirmation_number,
                    //   label: 'Ticket Types',
                    //   screen: TicketTypeListScreen(),
                    // ),
                    // const SizedBox(height: 8),
                    // _modernDrawerTile(
                    //   context,
                    //   icon: Icons.rate_review_outlined,
                    //   activeIcon: Icons.rate_review,
                    //   label: 'Reviews',
                    //   screen: ReviewListScreen(),
                    // ),
                    // const SizedBox(height: 8),
                    // _modernDrawerTile(
                    //   context,
                    //   icon: Icons.people_outlined,
                    //   activeIcon: Icons.people,
                    //   label: 'Users',
                    //   screen: UsersListScreen(),
                    // ),
                    // const SizedBox(height: 8),
                    // _modernDrawerTile(
                    //   context,
                    //   icon: Icons.business, // Business/company style icon
                    //   activeIcon: Icons.apartment, // Active state icon
                    //   label: 'Organizers',
                    //   screen: OrganizerListScreen(),
                    // ),
                    // const SizedBox(height: 8),
                    // _modernDrawerTile(
                    //   context,
                    //   icon: Icons.category_outlined,
                    //   activeIcon: Icons.category,
                    //   label: 'Categories',
                    //   screen: CategoryListScreen(),
                    // ),
                    // const SizedBox(height: 8),
                    // _modernDrawerTile(
                    //   context,
                    //   icon: Icons.view_list_outlined,
                    //   activeIcon: Icons.view_list,
                    //   label: 'Subcategories',
                    //   screen: SubcategoryListScreen(),
                    // ),
                    // const SizedBox(height: 8),
                    // _modernDrawerTile(
                    //   context,
                    //   icon: Icons.flag_outlined,
                    //   activeIcon: Icons.flag,
                    //   label: 'Countries',
                    //   screen: CountryListScreen(),
                    // ),
                    // const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.location_city_outlined,
                      activeIcon: Icons.location_city_rounded,
                      label: 'Cities',
                      screen: CityListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.person_outline,
                      activeIcon: Icons.person_rounded,
                      label: 'Actors',
                      screen: ActorListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.category_outlined,
                      activeIcon: Icons.category_rounded,
                      label: 'Categories',
                      screen: CategoryListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.movie_creation_outlined,
                      activeIcon: Icons.movie_creation_rounded,
                      label: 'Directors',
                      screen: DirectorListScreen(),
                    ),
                    const SizedBox(height: 8),
                    _modernDrawerTile(
                      context,
                      icon: Icons.business_outlined,
                      activeIcon: Icons.business_rounded,
                      label: 'Production Companies',
                      screen: ProductionCompanyListScreen(),
                    ),

                    // Add more tiles here in the future
                  ],
                ),
              ),
            ),
          ),

          // Bottom section
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _modernLogoutTile(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _modernDrawerTile(
  BuildContext context, {
  required IconData icon,
  required IconData activeIcon,
  required String label,
  required Widget screen,
}) {
  final currentRoute = ModalRoute.of(context)?.settings.name;
  final screenRoute = screen.runtimeType.toString();

  // Get the current screen type from the route
  bool isSelected = false;

  if (label == 'Business Report') {
    isSelected = currentRoute == 'BusinessReportScreen';
  } else if (label == 'Categories') {
    isSelected =
        currentRoute == 'CategoryListScreen' ||
        currentRoute == 'CategoryDetailsScreen';
  } else if (label == 'Cities') {
    isSelected =
        currentRoute == 'CityListScreen' || currentRoute == 'CityDetailsScreen';
  } else if (label == 'Actors') {
    isSelected =
        currentRoute == 'ActorListScreen' || currentRoute == 'ActorDetailsScreen';
  } else if (label == 'Categories') {
    isSelected =
        currentRoute == 'CategoryListScreen' || currentRoute == 'CategoryDetailsScreen';
  } else if (label == 'Directors') {
    isSelected =
        currentRoute == 'DirectorListScreen' || currentRoute == 'DirectorDetailsScreen';
  } else if (label == 'Production Companies') {
    isSelected =
        currentRoute == 'ProductionCompanyListScreen' || currentRoute == 'ProductionCompanyDetailsScreen';
  } else if (label == 'Countries') {
    isSelected =
        currentRoute == 'CountryListScreen' ||
        currentRoute == 'CountryDetailsScreen';
  } else if (label == 'Subcategories') {
    isSelected =
        currentRoute == 'SubcategoryListScreen' ||
        currentRoute == 'SubcategoryDetailsScreen';
  } else if (label == 'Organizers') {
    isSelected =
        currentRoute == 'OrganizerListScreen' ||
        currentRoute == 'OrganizerDetailsScreen';
  } else if (label == 'Ticket Types') {
    isSelected =
        currentRoute == 'TicketTypeListScreen' ||
        currentRoute == 'TicketTypeDetailsScreen';
  } else if (label == 'Users') {
    isSelected =
        currentRoute == 'UsersListScreen' ||
        currentRoute == 'UsersDetailsScreen' ||
        currentRoute == 'UsersEditScreen';
  } else if (label == 'Festivals') {
    isSelected =
        currentRoute == 'FestivalListScreen' ||
        currentRoute == 'FestivalDetailsScreen' ||
        currentRoute == 'FestivalUpsertScreen';
  } else if (label == 'Reviews') {
    isSelected =
        currentRoute == 'ReviewListScreen' ||
        currentRoute == 'ReviewDetailsScreen';
  } else if (label == 'Tickets') {
    isSelected =
        currentRoute == 'TicketListScreen' ||
        currentRoute == 'TicketDetailsScreen';
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 3),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => screen,
              settings: RouteSettings(name: screenRoute),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: isSelected
                ? Border.all(color: Colors.white.withOpacity(0.4), width: 1.5)
                : null,
            boxShadow: isSelected ? [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                  size: 24,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7B61B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFF7B61B).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFFF7B61B),
                    size: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _modernLogoutTile(BuildContext context) {
  return Container(
    width: double.infinity,
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          _showLogoutDialog(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE53E3E).withOpacity(0.15),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE53E3E),
              width: 1.5,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Color(0xFFE53E3E),
                size: 24,
              ),
              SizedBox(width: 18),
              Expanded(
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xFFE53E3E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Icon(
                Icons.exit_to_app_rounded,
                color: Color(0xFFE53E3E),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE53E3E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE53E3E),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Text(
              'Confirm Logout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout from your CineVibe account?',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFFE53E3E).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Logout',
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
}


