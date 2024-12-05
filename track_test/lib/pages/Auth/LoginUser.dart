import 'package:flutter/material.dart';
import 'package:track_test/pages/Auth/RegisterUser.dart';
import 'package:track_test/pages/HomePage.dart';
import 'package:track_test/services/AuthServices.dart';

class LoginUser extends StatefulWidget {
  const LoginUser({super.key, required this.message});
  final String message;

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  bool isPasswordHidden = true;
  bool isLoading = false;

  final AuthService authService = AuthService();
  final formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";

  @override
  void initState() {
    super.initState();
    if (widget.message.isNotEmpty) {
      Future.delayed(Duration.zero, () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.message),
          backgroundColor: Colors.blue,
        ));
      });
    }
  }

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      final isLoggedIn = await authService.LoginUser(email, password);

      setState(() {
        isLoading = false;
      });

      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(authService.errorLogin),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Widget buildTextField({
    required String label,
    required String hintText,
    required bool obscureText,
    required TextInputType keyboardType,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        labelText: label,
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              const Icon(Icons.login, size: 80, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Login to continue",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    buildTextField(
                      label: "Email Address",
                      hintText: "example@gmail.com",
                      obscureText: false,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => email = value,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Email is required" : null,
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      label: "Password",
                      hintText: "*******",
                      obscureText: isPasswordHidden,
                      keyboardType: TextInputType.text,
                      onChanged: (value) => password = value,
                      validator: (value) =>
                          value == null || value.isEmpty ? "Password is required" : null,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordHidden = !isPasswordHidden;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterUser()),
                  );
                },
                child: const Text(
                  "Don't have an account? Create one",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
