import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'screens/home/home_dashboard.dart';

void main() {
  runApp(const MyApp());
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
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
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
                      backgroundColor: const Color(0xFFD9E2E8),
                      foregroundColor: const Color(0xFF1E2931),
                      elevation: 2,
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
      prefixIcon: Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: icon),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFF1E1E1E), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: const BorderSide(color: Color(0xFF1E1E1E), width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF63C1E3),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Top header with logo and description
            Image.asset('assets/image/LogoWhite.png', width: 64, height: 64, semanticLabel: 'GABAY Logo'),
            const SizedBox(height: 12),
            const Text(
              'GABAY: Smart Campus Navigation System',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),
            // White rounded container sticks to bottom and fills remaining space
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    28,
                    20,
                    // Add extra bottom padding when keyboard is open
                    (MediaQuery.of(context).viewInsets.bottom > 0)
                        ? MediaQuery.of(context).viewInsets.bottom + 20
                        : 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Hello!',
                        style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 80),
                    TextField(
                      controller: _usernameController,
                      decoration: _roundedInputDecoration(
                        hint: 'Username',
                        icon: SvgPicture.asset('assets/icon/account.svg', width: 22, height: 22),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _roundedInputDecoration(
                        hint: 'Email',
                        icon: SvgPicture.asset('assets/icon/email.svg', width: 16, height: 16),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: _roundedInputDecoration(
                        hint: 'Password',
                        icon: SvgPicture.asset('assets/icon/password.svg', width: 22, height: 22),
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
                          child: Text('I agree to the terms and conditions', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: agree
                            ? () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const HomeDashboard(),
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
                        child: const Text('Sign Up'),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Align(
                      alignment: Alignment.center,
                      child: Text('Or'),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/image/google.png', width: 36, height: 36),
                        const SizedBox(width: 36),
                        Image.asset('assets/image/facebook.png', width: 56, height: 56),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Login with your Social Media accounts',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ],
                ), // end inner Column
              ), // end SingleChildScrollView
            ), // end Container
          ), // end Expanded
        ], // end Column children
      ), // end Column
    ), // end SafeArea
  ); // end Scaffold
 }
}

