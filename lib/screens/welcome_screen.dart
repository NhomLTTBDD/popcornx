import 'package:baitapthuchanh/screens/signin_screen.dart';
import 'package:baitapthuchanh/screens/signup_screen.dart';
import 'package:baitapthuchanh/widgets/custom_scaffold.dart';
import 'package:baitapthuchanh/widgets/welcom_button.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            flex: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Popcornx',
                          style: TextStyle(
                            fontSize: 45.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                children: [
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign in',
                      onTap: const SignInScreen(),
                      color: Colors.transparent,
                      textColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: WelcomeButton(
                      buttonText: 'Sign up',
                      onTap: const SignUpScreen(),
                      color: Colors.white,
                      textColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
