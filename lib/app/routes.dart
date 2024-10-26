import 'dart:developer';

import 'package:chatterjii/ui/authscreen.dart';
import 'package:chatterjii/ui/chatscreen.dart';
import 'package:chatterjii/ui/homescreen.dart';
import 'package:chatterjii/ui/messagelist.dart';
import 'package:chatterjii/ui/onboarding/onboarding.dart';
import 'package:flutter/material.dart';

class Routes {
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const home = '/home';
  static const chats = '/chats ';
  static const latest = '/latest';
  static String currentRoute = auth;

  static Route<dynamic>? onGenerateRouted(RouteSettings routeSettings) {
    currentRoute = routeSettings.name ?? '';
    log(name: 'Current Route', currentRoute);
    switch (routeSettings.name) {
      case auth:
        return MaterialPageRoute(
          builder: (_) => AuthScreen(),
        );
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => OnboardingPage(
            pages: [
              OnboardingPageModel(
                title: 'Fast and Secure',
                description: 'real time chat application',
                image: 'assets/image.png',
                bgColor: Colors.indigo,
              ),
              OnboardingPageModel(
                title: 'Connect with friends.',
                description: 'Connect with your friends anytime anywhere',
                image: 'assets/image.png',
                bgColor: const Color(0xff1eb090),
              ),
            ],
          ),
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(),
        );
      case chats:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => ChatsList(
            peerId: args['peerId'],
            peerName: args['peerName'],
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );

      case latest:
        return MaterialPageRoute(
          builder: (_) => MessagesList(),
        );
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold());
    }
  }
}
