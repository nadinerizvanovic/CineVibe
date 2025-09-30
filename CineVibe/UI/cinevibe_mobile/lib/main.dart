import 'package:cinevibe_mobile/layouts/master_screen.dart';
import 'package:cinevibe_mobile/providers/auth_provider.dart';
import 'package:cinevibe_mobile/providers/city_provider.dart';
import 'package:cinevibe_mobile/providers/gender_provider.dart';
import 'package:cinevibe_mobile/providers/review_provider.dart';
import 'package:cinevibe_mobile/providers/ticket_provider.dart';
import 'package:cinevibe_mobile/providers/user_provider.dart';
import 'package:cinevibe_mobile/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  // await dotenv.load(fileName: ".env");

  // stripe.Stripe.publishableKey = dotenv.env["STRIPE_PUBLISHABLE_KEY"] ?? "";
  // stripe.Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  // stripe.Stripe.urlScheme = 'flutterstripe';
  // await stripe.Stripe.instance.applySettings();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider()),
        ChangeNotifierProvider<ReviewProvider>(create: (_) => ReviewProvider()),
        ChangeNotifierProvider<TicketProvider>(create: (_) => TicketProvider()),
        ChangeNotifierProvider<CityProvider>(create: (_) => CityProvider()),
        ChangeNotifierProvider<GenderProvider>(create: (_) => GenderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineVibe Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004AAD),
          primary: const Color(0xFF004AAD),
          secondary: const Color(0xFFF7B61B),
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  
  // Modern animation controllers
  late AnimationController _mainAnimationController;
  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late AnimationController _backgroundAnimationController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _backgroundOpacityAnimation;
  late Animation<double> _formOpacityAnimation;
  late Animation<Offset> _formSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main animation controller
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Form animation controller
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Background animation controller
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Setup animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: Curves.easeOutCubic),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainAnimationController, curve: Curves.elasticOut),
    );
    
    _logoRotationAnimation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeInOut),
    );
    
    _backgroundOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundAnimationController, curve: Curves.easeInOut),
    );
    
    _formOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _formAnimationController, curve: Curves.easeOutCubic),
    );
    
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations with staggered timing
    _backgroundAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _mainAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _logoAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _formAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background with gradient overlay
          AnimatedBuilder(
            animation: _backgroundOpacityAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _backgroundOpacityAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/1.png'),
                      fit: BoxFit.cover,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF004AAD).withOpacity(0.8),
                        const Color(0xFF1E40AF).withOpacity(0.6),
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Floating particles animation
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlesPainter(_backgroundAnimationController.value),
                size: Size.infinite,
              );
            },
          ),
          
          // Main content
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Modern logo with glassmorphism
                          AnimatedBuilder(
                            animation: _logoAnimationController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _logoRotationAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.20),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 0,
                                        blurRadius: 32,
                                        offset: const Offset(0, 12),
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.1),
                                        spreadRadius: 0,
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Image.asset(
                                    'assets/images/logo_small.png',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 40),

                          // Modern welcome text with gradient
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color.fromARGB(255, 221, 137, 11), Color(0xFFF7B61B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.8,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Sign in to access your movies",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 48),

                          // Modern glassmorphism login form
                          SlideTransition(
                            position: _formSlideAnimation,
                            child: FadeTransition(
                              opacity: _formOpacityAnimation,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 0,
                                      blurRadius: 32,
                                      offset: const Offset(0, 12),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.05),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    // Username field with modern styling
                                    _buildModernTextField(
                                      controller: usernameController,
                                      label: "Username",
                                      prefixIcon: Icons.person_outline_rounded,
                                      hintText: "Enter your username",
                                    ),
                                    const SizedBox(height: 24),

                                    // Password field with modern styling
                                    _buildModernTextField(
                                      controller: passwordController,
                                      label: "Password",
                                      prefixIcon: Icons.lock_outline_rounded,
                                      hintText: "Enter your password",
                                      obscureText: !_isPasswordVisible,
                                      suffixIcon: _isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      onSuffixIconPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 36),

                                    // Modern login button with gradient
                                    _buildModernButton(
                                      text: "Sign In",
                                      onPressed: _isLoading ? null : _handleLogin,
                                      isLoading: _isLoading,
                                    ),
                                    const SizedBox(height: 24),

                                    // Modern divider
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
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
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Text(
                                            "or",
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.7),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
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
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),

                                    // Modern register button
                                    _buildModernOutlinedButton(
                                      text: "Create Account",
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const RegisterScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
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
        ],
      ),
    );
  }

  // Modern text field builder
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    IconData? prefixIcon,
    IconData? suffixIcon,
    String? hintText,
    bool obscureText = false,
    VoidCallback? onSuffixIconPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(
                    prefixIcon,
                    color: Colors.white.withOpacity(0.7),
                    size: 22,
                  ),
                )
              : null,
          suffixIcon: suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16, left: 12),
                  child: IconButton(
                    icon: Icon(
                      suffixIcon,
                      color: Colors.white.withOpacity(0.7),
                      size: 22,
                    ),
                    onPressed: onSuffixIconPressed,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
        cursorColor: const Color(0xFFF7B61B),
      ),
    );
  }

  // Modern button builder
  Widget _buildModernButton({
    required String text,
    required VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004AAD), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004AAD).withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // Modern outlined button builder
  Widget _buildModernOutlinedButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final username = usernameController.text;
      final password = passwordController.text;

      // Set basic auth for subsequent requests
      AuthProvider.username = username;
      AuthProvider.password = password;

      // Authenticate and set current user
      final userProvider = UserProvider();
      final user = await userProvider.authenticate(username, password);

      if (user != null) {
        // Check if user has standard user role (roleId = 2)
        bool hasStandardUserRole = user.roles.any((role) => role.id == 2);

        print(
          "User roles: ${user.roles.map((r) => '${r.name} (ID: ${r.id})').join(', ')}",
        );
        print("Has standard user role: $hasStandardUserRole");

        if (hasStandardUserRole) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MasterScreen(
                  child: SizedBox.shrink(),
                  title: 'CineVibe',
                ),
                settings: const RouteSettings(name: 'MasterScreen'),
              ),
            );
          }
        } else {
          if (mounted) {
            _showAccessDeniedDialog();
          }
        }
      } else {
        if (mounted) {
          _showErrorDialog("Invalid username or password.");
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
      }
    } catch (e) {
      print(e);
      if (mounted) {
        _showErrorDialog("An unexpected error occurred. Please try again.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
            Text("Login Failed"),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF004AAD),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Color(0xFFE53E3E)),
            SizedBox(width: 8),
            Text("Access Denied"),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You do not have standard user privileges.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text(
              "This application is restricted to standard users only. Please contact your system administrator if you believe you should have access.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear the form and reset state
              usernameController.clear();
              passwordController.clear();
              // Clear authentication credentials
              AuthProvider.username = '';
              AuthProvider.password = '';
              setState(() {
                _isLoading = false;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF004AAD),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

// Custom painter for floating particles animation
class ParticlesPainter extends CustomPainter {
  final double animationValue;
  
  ParticlesPainter(this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final random = math.Random(42); // Fixed seed for consistent particles
    
    for (int i = 0; i < 20; i++) {
      final x = (random.nextDouble() * size.width) + (animationValue * 50 * math.sin(i * 0.5));
      final y = (random.nextDouble() * size.height) + (animationValue * 30 * math.cos(i * 0.3));
      final radius = 2 + (random.nextDouble() * 3) + (animationValue * 2);
      
      // Create floating effect
      final offsetY = math.sin(animationValue * 2 * math.pi + i * 0.5) * 10;
      
      canvas.drawCircle(
        Offset(x, y + offsetY),
        radius,
        paint..color = Colors.white.withOpacity(0.1 - (i * 0.003)),
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
