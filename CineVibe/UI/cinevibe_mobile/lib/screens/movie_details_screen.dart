import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinevibe_mobile/model/movie.dart';
import 'package:cinevibe_mobile/model/screening.dart';
import 'package:cinevibe_mobile/providers/screening_provider.dart';
import 'package:cinevibe_mobile/screens/seat_selection_screen.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';

class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool _isLoadingScreenings = false;
  List<Screening> _screenings = [];
  late ScreeningProvider _screeningProvider;
  Map<String, List<Screening>> _groupedScreenings = {};
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    _screeningProvider = Provider.of<ScreeningProvider>(context, listen: false);
    _loadScreenings();
    _initializeYoutubePlayer();
  }

  void _initializeYoutubePlayer() {
    if (widget.movie.trailer != null && widget.movie.trailer!.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(widget.movie.trailer!);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
            controlsVisibleAtStart: true,
            hideControls: false,
            isLive: false,
            forceHD: false,
            showLiveFullscreenButton: false,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _loadScreenings() async {
    setState(() {
      _isLoadingScreenings = true;
    });

    try {
      final result = await _screeningProvider.get(
        filter: {
          'movieId': widget.movie.id,
          'isActive': true,
          'page': 0,
          'pageSize': 100,
          'includeTotalCount': false,
        },
      );

      if (mounted) {
        setState(() {
          _screenings = result.items ?? [];
          _groupScreeningsByDate();
          _isLoadingScreenings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingScreenings = false;
        });
        print("Failed to load screenings: $e");
      }
    }
  }

  void _groupScreeningsByDate() {
    _groupedScreenings.clear();
    for (var screening in _screenings) {
      final dateKey = DateFormat('yyyy-MM-dd').format(screening.startTime);
      if (!_groupedScreenings.containsKey(dateKey)) {
        _groupedScreenings[dateKey] = [];
      }
      _groupedScreenings[dateKey]!.add(screening);
    }

    // Sort screenings within each date
    _groupedScreenings.forEach((key, screenings) {
      screenings.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar with Poster/Trailer
          _buildSliverAppBar(),
          
          // Movie Details Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMovieInfo(),
                const SizedBox(height: 24),
                _buildScreeningsSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final hasTrailer = _youtubeController != null;
    
    return SliverAppBar(
      expandedHeight: 200, // Reduced height for widescreen trailers
      pinned: true,
      backgroundColor: const Color(0xFF004AAD),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // YouTube Video Player Area
            if (hasTrailer)
              Container(
                color: Colors.black,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9, // Standard widescreen ratio
                    child: YoutubePlayer(
                      controller: _youtubeController!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: const Color(0xFFE50914),
                      progressColors: const ProgressBarColors(
                        playedColor: Color(0xFFE50914),
                        handleColor: Color(0xFFE50914),
                      ),
                      onReady: () {
                        // Player is ready - video won't auto-start
                      },
                      onEnded: (data) {
                        // Video ended
                      },
                      bottomActions: [
                        CurrentPosition(),
                        ProgressBar(
                          isExpanded: true,
                          colors: const ProgressBarColors(
                            playedColor: Color(0xFFE50914),
                            handleColor: Color(0xFFE50914),
                          ),
                        ),
                        RemainingDuration(),
                        const PlaybackSpeedButton(),
                      ],
                    ),
                  ),
                ),
              )
            else
              // No trailer - show poster
              if (widget.movie.poster != null)
                Image.memory(
                  base64Decode(widget.movie.poster!),
                  fit: BoxFit.cover,
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF004AAD).withOpacity(0.3),
                        const Color(0xFF1E40AF).withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.movie_outlined,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
            
            // Gradient Overlay at bottom (only if no trailer)
            if (!hasTrailer)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieInfo() {
    final hasTrailer = _youtubeController != null;
    final hasPoster = widget.movie.poster != null;
    
    return Container(
      margin: const EdgeInsets.all(20),
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
          // Title and Poster Row (if trailer exists)
          if (hasTrailer && hasPoster)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    base64Decode(widget.movie.poster!),
                    width: 100,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                // Title and Tags
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movie.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Tags Row below title
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (widget.movie.genreName != null && widget.movie.genreName!.isNotEmpty)
                            _buildTag(widget.movie.genreName!, const Color(0xFF004AAD)),
                          if (widget.movie.categoryName != null && widget.movie.categoryName!.isNotEmpty)
                            _buildTag(widget.movie.categoryName!, const Color(0xFFF7B61B)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            // Just Title (if no trailer)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.movie.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                // Tags Row below title
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (widget.movie.genreName != null && widget.movie.genreName!.isNotEmpty)
                      _buildTag(widget.movie.genreName!, const Color(0xFF004AAD)),
                    if (widget.movie.categoryName != null && widget.movie.categoryName!.isNotEmpty)
                      _buildTag(widget.movie.categoryName!, const Color(0xFFF7B61B)),
                  ],
                ),
              ],
            ),
          const SizedBox(height: 20),
          
          // Info Grid
          _buildInfoRow(Icons.calendar_today_outlined, 'Release Date', 
              DateFormat('MMM d, yyyy').format(widget.movie.releaseDate)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, 'Duration', '${widget.movie.duration} minutes'),
          const SizedBox(height: 12),
          if (widget.movie.directorName != null && widget.movie.directorName!.isNotEmpty)
            _buildInfoRow(Icons.person_outline, 'Director', widget.movie.directorName!),
          
          // Description
          if (widget.movie.description != null && widget.movie.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Synopsis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.movie.description!,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ],

          // Actors
          if (widget.movie.actors != null && widget.movie.actors!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Cast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.movie.actors!.map((actor) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${actor.firstName} ${actor.lastName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Production Companies
          if (widget.movie.productionCompanies != null && widget.movie.productionCompanies!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Production',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.movie.productionCompanies!.map((company) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    company.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScreeningsSection() {
    // Check if movie is upcoming (category 2)
    final isUpcoming = widget.movie.categoryId == 2;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.event_seat,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isUpcoming ? 'Availability' : 'Showtimes',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Upcoming Message or Screenings List
          if (isUpcoming)
            _buildUpcomingMessage()
          else if (_isLoadingScreenings)
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004AAD)),
              ),
            )
          else if (_groupedScreenings.isEmpty)
            _buildNoScreenings()
          else
            _buildScreeningsList(),
        ],
      ),
    );
  }

  Widget _buildUpcomingMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF004AAD).withOpacity(0.05),
            const Color(0xFF1E40AF).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF004AAD).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004AAD).withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.upcoming_outlined,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Coming Soon to Theaters!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'This movie will be available soon.\nStay tuned for showtimes!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Release: ${DateFormat('MMM d, yyyy').format(widget.movie.releaseDate)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoScreenings() {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF004AAD).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy,
              size: 48,
              color: Color(0xFF004AAD),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Showtimes Available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are currently no scheduled screenings for this movie.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningsList() {
    final sortedDates = _groupedScreenings.keys.toList()..sort();
    
    return Column(
      children: sortedDates.map((dateKey) {
        final screenings = _groupedScreenings[dateKey]!;
        final date = DateTime.parse(dateKey);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Header
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: const Color(0xFF004AAD),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Time Chips
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: screenings.map((screening) {
                    return _buildTimeChip(screening);
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeChip(Screening screening) {
    final isPast = screening.startTime.isBefore(DateTime.now());
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isPast ? null : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SeatSelectionScreen(screening: screening),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: isPast ? null : const LinearGradient(
              colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
            ),
            color: isPast ? Colors.grey[300] : null,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isPast ? null : [
              BoxShadow(
                color: const Color(0xFF004AAD).withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                DateFormat('HH:mm').format(screening.startTime),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPast ? Colors.grey[600] : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                screening.screeningTypeName,
                style: TextStyle(
                  fontSize: 11,
                  color: isPast ? Colors.grey[600] : Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${screening.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isPast ? Colors.grey[600] : const Color(0xFFF7B61B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final screeningDate = DateTime(date.year, date.month, date.day);
    
    if (screeningDate == today) {
      return 'Today, ${DateFormat('MMM d').format(date)}';
    } else if (screeningDate == tomorrow) {
      return 'Tomorrow, ${DateFormat('MMM d').format(date)}';
    } else {
      return DateFormat('EEEE, MMM d').format(date);
    }
  }
}

