import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/home/home_dashboard.dart';
import 'widgets/glass_container.dart';
import 'screens/admin/admin_dashboard.dart';

void main() {
  runApp(const MyApp());
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _courseController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _courseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canRegister {
    final name = _nameController.text.trim();
    final course = _courseController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text;
    return name.isNotEmpty && course.isNotEmpty && email.isNotEmpty && pass.isNotEmpty;
  }

  InputDecoration _roundedInputDecoration({required String hint, required Widget icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: icon),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      filled: true,
      fillColor: Colors.white.withOpacity(0.18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.20), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.35), width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF63C1E3), Color(0xFF1E2931)],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(color: Colors.white.withOpacity(0)),
          ),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 70),
                Image.asset('assets/image/LogoWhite.png', width: 64, height: 64, semanticLabel: 'GABAY Logo'),
                const SizedBox(height: 20),
                const Text('GABAY: Smart Campus Navigation System', style: TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 50),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: GlassContainer(
                      radius: 28,
                      padding: EdgeInsets.zero,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          28,
                          20,
                          (MediaQuery.of(context).viewInsets.bottom > 0)
                              ? MediaQuery.of(context).viewInsets.bottom
                              : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Register',
                                style: TextStyle(color: Colors.white, fontSize: 24, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 60),
                            TextField(
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              controller: _nameController,
                              onChanged: (_) => setState(() {}),
                              decoration: _roundedInputDecoration(
                                hint: 'Full name',
                                icon: SvgPicture.asset('assets/icon/account.svg', width: 22, height: 22, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextField(
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              controller: _courseController,
                              onChanged: (_) => setState(() {}),
                              decoration: _roundedInputDecoration(
                                hint: 'Course',
                                icon: const Icon(Icons.school_outlined, color: Colors.white, size: 22),
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextField(
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (_) => setState(() {}),
                              decoration: _roundedInputDecoration(
                                hint: 'Email',
                                icon: SvgPicture.asset('assets/icon/email.svg', width: 16, height: 16, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextField(
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              controller: _passwordController,
                              obscureText: true,
                              onChanged: (_) => setState(() {}),
                              decoration: _roundedInputDecoration(
                                hint: 'Password',
                                icon: SvgPicture.asset('assets/icon/password.svg', width: 22, height: 22, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 40),
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _canRegister
                                    ? () {
                                        final name = _nameController.text.trim();
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => HomeDashboard(userName: name.isNotEmpty ? name : 'Guest'),
                                          ),
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF63C1E3),
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                child: const Text('Register'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Have an account?', style: TextStyle(color: Colors.white70)),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text('Login', style: TextStyle(color: Colors.blue)),
                                ),
                              ],
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
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GABAY',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const MyHomePage(title: 'GABAY'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF63C1E3),
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              const Spacer(flex: 2),
              Image.asset(
                'assets/image/LogoWhite.png',
                width: 160,
                height: 160,
                semanticLabel: 'GABAY Logo',
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'GABAY: Smart Campus Navigation System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: GlassContainer(
                  radius: 32,
                  padding: EdgeInsets.zero,
                  child: SizedBox(
                    width: 260,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SignUpScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Get Started'),
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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool rememberMe = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _canLogin {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();
    final cpass = _confirmPasswordController.text.trim();
    return email.isNotEmpty && pass.isNotEmpty && cpass.isNotEmpty && pass == cpass;
  }

  InputDecoration _roundedInputDecoration({required String hint, required Widget icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: icon),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      filled: true,
      fillColor: Colors.white.withOpacity(0.18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.20), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.35), width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF63C1E3), Color(0xFF1E2931)],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
            child: Container(color: Colors.white.withOpacity(0)),
          ),
          SafeArea(
            top: true,
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 70),
                Image.asset('assets/image/LogoWhite.png', width: 64, height: 64, semanticLabel: 'GABAY Logo'),
                const SizedBox(height: 20),
                const Text(
                  'GABAY: Smart Campus Navigation System',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 50),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: GlassContainer(
                      radius: 28,
                      padding: EdgeInsets.zero,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          28,
                          20,
                          (MediaQuery.of(context).viewInsets.bottom > 0)
                              ? MediaQuery.of(context).viewInsets.bottom
                              : 0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Login!',
                                style: TextStyle(color: Colors.white, fontSize: 24, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 60),
                            TextField(
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (_) => setState(() {}),
                              decoration: _roundedInputDecoration(
                                hint: 'Email',
                                icon: SvgPicture.asset('assets/icon/email.svg', width: 16, height: 16, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              controller: _passwordController,
                              obscureText: true,
                              onChanged: (_) => setState(() {}),
                              decoration: _roundedInputDecoration(
                                hint: 'Password',
                                icon: SvgPicture.asset('assets/icon/password.svg', width: 22, height: 22, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              style: const TextStyle(color: Colors.white),
                              cursorColor: Colors.white,
                              controller: _confirmPasswordController,
                              obscureText: true,
                              onChanged: (_) => setState(() {}),
                              decoration: _roundedInputDecoration(
                                hint: 'Confirm Password',
                                icon: SvgPicture.asset('assets/icon/password.svg', width: 22, height: 22, color: Colors.white),
                              ).copyWith(
                                errorText: (_confirmPasswordController.text.isNotEmpty &&
                                        _passwordController.text.trim() != _confirmPasswordController.text.trim())
                                    ? 'Passwords do not match'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (v) => setState(() => rememberMe = v ?? false),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const Text('Remember me', style: TextStyle(color: Colors.white)),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Forgot password tapped')),
                                    );
                                  },
                                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                                  child: const Text('Forgot password?'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _canLogin
                                    ? () {
                                        final email = _emailController.text.trim();
                                        final String name = (email.contains('@') && email.split('@').first.isNotEmpty)
                                            ? email.split('@').first
                                            : 'Guest';
                                        final bool isAdmin = (email.toLowerCase() == 'admin@seait.edu');
                                        if (isAdmin) {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => const AdminDashboard(),
                                            ),
                                          );
                                        } else {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => HomeDashboard(userName: name),
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF63C1E3),
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                child: const Text('Login'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Don\'t have an account?', style: TextStyle(color: Colors.white70)),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                                  child: const Text('Register'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Powered by Gabay 2025',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ), // end inner Column
                      ), // end SingleChildScrollView
                    ), // end GlassContainer
                  ), // end Padding
                ), // end Expanded
              ], // end Column children
            ), // end Column
          ), // end SafeArea
        ], // end Stack children
      ), // end Stack
    ); // end Scaffold
  }
}
