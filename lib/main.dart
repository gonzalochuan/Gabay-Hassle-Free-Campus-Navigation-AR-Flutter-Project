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
                                hint: 'Username',
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
                                  child: const Text('Login'),
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
  bool agree = false;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            // Top header with logo and description
            Image.asset('assets/image/LogoWhite.png', width: 64, height: 64, semanticLabel: 'GABAY Logo'),
            const SizedBox(height: 20),
            const Text(
              'GABAY: Smart Campus Navigation System',
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
            const SizedBox(height: 50),
            // Glassmorphic container sticks to bottom and fills remaining space
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
                      // Add extra bottom padding when keyboard is open
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
                            'Hello!',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 60),
                        TextField(
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      controller: _usernameController,
                      decoration: _roundedInputDecoration(
                        hint: 'Username',
                        icon: SvgPicture.asset('assets/icon/account.svg', width: 22, height: 22, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
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
                      decoration: _roundedInputDecoration(
                        hint: 'Password',
                        icon: SvgPicture.asset('assets/icon/password.svg', width: 22, height: 22, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Checkbox(
                          value: agree,
                          onChanged: (v) => setState(() => agree = v ?? false),
                          visualDensity: VisualDensity.compact,
                        ),
                        const Expanded(
                          child: Text('I agree to the terms and conditions', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: agree
                            ? () {
                                final name = _usernameController.text.trim();
                                final email = _emailController.text.trim();
                                final bool isAdmin = (email.toLowerCase() == 'admin@seait.edu') || (name.toLowerCase() == 'admin');
                                if (isAdmin) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const AdminDashboard(),
                                    ),
                                  );
                                } else {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => HomeDashboard(userName: name.isNotEmpty ? name : 'Guest'),
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
                        const Text('No account?', style: TextStyle(color: Colors.white70)),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
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

