import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_movie/screens/signup_screen.dart';
import 'package:app_movie/theme/theme.dart';
import 'package:app_movie/widgets/custom_scaffold.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:flutter/material.dart';

import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  // 1. Khai báo controller cho Email và Password
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberPassword = true;

  // Giải phóng bộ nhớ khi thoát màn hình để tránh rò rỉ (leak) bộ nhớ
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      // Email
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      // Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        obscuringCharacter: '*',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      // Remember me & Forget Password
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              // Chuyển đến màn hình quên mật khẩu
                            },
                            child: Text(
                              'Forget password?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      // Nút Sign In
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            // 1. Kiểm tra tính hợp lệ của Form (Email/Password không để trống)
                            if (_formSignInKey.currentState!.validate()) {
                              try {
                                // 2. Gọi lệnh ĐĂNG NHẬP của Firebase
                                await FirebaseAuth.instance.signInWithEmailAndPassword(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );

                                // 3. Nếu đăng nhập thành công
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Đăng nhập thành công!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );

                                  // 4. Chuyển hướng ngay vào trang Home
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                  );
                                }
                              } on FirebaseAuthException catch (e) {
                                // 5. Xử lý các lỗi đăng nhập cụ thể
                                String errorMessage = "Email hoặc mật khẩu không chính xác.";

                                if (e.code == 'user-not-found') {
                                  errorMessage = "Tài khoản này chưa được đăng ký.";
                                } else if (e.code == 'wrong-password') {
                                  errorMessage = "Mật khẩu không chính xác.";
                                } else if (e.code == 'invalid-email') {
                                  errorMessage = "Định dạng Email không hợp lệ.";
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
                                );
                              } catch (e) {
                                print("Lỗi hệ thống: $e");
                              }
                            }
                          },
                          child: const Text('Sign in'),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(thickness: 0.7, color: Colors.grey.withOpacity(0.5))),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('Sign in with', style: TextStyle(color: Colors.black45)),
                          ),
                          Expanded(child: Divider(thickness: 0.7, color: Colors.grey.withOpacity(0.5))),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      // Social Brands
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Brand(Brands.facebook),
                          Brand(Brands.google),
                          const Icon(IonIcons.logo_apple, color: Colors.black, size: 35),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      // Don't have an account -> Sign Up
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (e) => const SignUpScreen()),
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
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
    );
  }
}