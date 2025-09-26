import 'package:cinevibe_desktop/providers/auth_provider.dart';
import 'package:cinevibe_desktop/providers/city_provider.dart';
import 'package:cinevibe_desktop/providers/actor_provider.dart';
import 'package:cinevibe_desktop/providers/category_provider.dart';
import 'package:cinevibe_desktop/providers/gender_provider.dart';
import 'package:cinevibe_desktop/providers/genre_provider.dart';
import 'package:cinevibe_desktop/providers/director_provider.dart';
import 'package:cinevibe_desktop/providers/production_company_provider.dart';
import 'package:cinevibe_desktop/providers/screening_type_provider.dart';
import 'package:cinevibe_desktop/providers/user_provider.dart';
import 'package:cinevibe_desktop/providers/role_provider.dart';
import 'package:cinevibe_desktop/providers/ticket_provider.dart';
import 'package:cinevibe_desktop/providers/hall_provider.dart';
import 'package:cinevibe_desktop/providers/review_provider.dart';
import 'package:cinevibe_desktop/providers/product_provider.dart';
import 'package:cinevibe_desktop/providers/movie_provider.dart';
import 'package:cinevibe_desktop/screens/city_list_screen.dart';
import 'package:cinevibe_desktop/utils/base_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize window manager
  await windowManager.ensureInitialized();
  
  // Set initial window size and properties
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 850), // Width: 1200, Height: 800
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    windowButtonVisibility: true,
  );
  
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  
  //await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CityProvider>(
          create: (context) => CityProvider(),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider<GenderProvider>(
          create: (context) => GenderProvider(),
        ),
        ChangeNotifierProvider<GenreProvider>(
          create: (context) => GenreProvider(),
        ),
        ChangeNotifierProvider<ActorProvider>(
          create: (context) => ActorProvider(),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (context) => CategoryProvider(),
        ),
        ChangeNotifierProvider<DirectorProvider>(
          create: (context) => DirectorProvider(),
        ),
        ChangeNotifierProvider<ProductionCompanyProvider>(
          create: (context) => ProductionCompanyProvider(),
        ),
        ChangeNotifierProvider<ScreeningTypeProvider>(
          create: (context) => ScreeningTypeProvider(),
        ),
        ChangeNotifierProvider<RoleProvider>(
          create: (context) => RoleProvider(),
        ),
        ChangeNotifierProvider<TicketProvider>(
          create: (context) => TicketProvider(),
        ),
        ChangeNotifierProvider<HallProvider>(
          create: (context) => HallProvider(),
        ),
        ChangeNotifierProvider<ReviewProvider>(
          create: (context) => ReviewProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (context) => ProductProvider(),
        ),
        ChangeNotifierProvider<MovieProvider>(
          create: (context) => MovieProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineVibe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF004AAD), // Blue
          primary: const Color(0xFF004AAD), // Yellow

        ),
        useMaterial3: true,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/login_background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Modern centered login card
          Center(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 400),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF004AAD).withOpacity(0.08),
                              spreadRadius: 0,
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              spreadRadius: 0,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(36.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Modern logo section
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF004AAD).withOpacity(0.1),
                                      const Color(0xFFF7B61B).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF004AAD).withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Image.asset(
                                  "assets/images/logo_large.png",
                                  height: 72,
                                  width: 112,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Modern welcome section
                              Column(
                                children: [
                                  Text(
                                    "Welcome Back",
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1E293B),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Sign in to access your dashboard",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 36),

                              // Form section with modern spacing
                              Column(
                                children: [
                                  // Username field
                                  customTextField(
                                    label: "Username",
                                    controller: usernameController,
                                    prefixIcon: Icons.person_outline_rounded,
                                    hintText: "Enter your username",
                                  ),
                                  const SizedBox(height: 20),

                                  // Password field
                                  customTextField(
                                    label: "Password",
                                    controller: passwordController,
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
                                  const SizedBox(height: 28),

                                  // Modern login button
                                  customElevatedButton(
                                    text: "Sign In",
                                    onPressed: _isLoading ? null : _handleLogin,
                                    width: double.infinity,
                                    height: 52,
                                    isLoading: _isLoading,
                                    backgroundColor: const Color(0xFF004AAD),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
      final userProvider = context.read<UserProvider>();
      final user = await userProvider.authenticate(username, password);

      if (user != null) {
        // Check if user has admin role (roleId = 1)
        bool hasAdminRole = user.roles.any((role) => role.id == 1);

        print(
          "User roles: ${user.roles.map((r) => '${r.name} (ID: ${r.id})').join(', ')}",
        );
        print("Has admin role: $hasAdminRole");

        if (hasAdminRole) {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CityListScreen(),
                settings: const RouteSettings(name: 'CityListScreen'),
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
              foregroundColor: const Color(0xFF6A1B9A),
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
              "You do not have administrator privileges.",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            Text(
              "This application is restricted to administrators only. Please contact your system administrator if you believe you should have access.",
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
              foregroundColor: const Color(0xFF6A1B9A),
            ),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
