import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/home_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/profile_screen.dart';


class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const signIn = '/signin';
  static const signUp = '/signup';
  static const home = '/home';
  static const chatbot = '/chatbot';
  static const profile = '/profile';

  static Map<String, WidgetBuilder> get routesMap => {
        splash: (_) => const SplashScreen(),
        onboarding: (_) => const OnboardingScreen(),
        signIn: (_) => const SignInScreen(),
        signUp: (_) => const SignUpScreen(),
        home: (_) => const HomeScreen(),
        chatbot: (_) => const ChatbotScreen(),
        profile: (_) => const ProfileScreen(),
      };
}
