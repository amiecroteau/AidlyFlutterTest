import 'package:flutter/material.dart';

import 'package:aidly/theme.dart';
import 'package:aidly/_routing/routes.dart' as router;
import 'package:aidly/_routing/routeNames.dart';

import 'views/landing.dart';

class App extends StatelessWidget {
  // UserModel model;
  App();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Aidly',
        debugShowCheckedModeBanner: false,
        theme: buildThemeData(),
        onGenerateRoute: router.generateRoute,
        initialRoute: landingViewRoute,
        routes: {
          '/': (context) => LandingPage(),
          // '/register': (context) => RegisterPage(),
          // '/registerThankYou': (context) => registerThankYouPage(),
          // '/expertise': (context) => ExpertisePage(),
          // '/interests': (context) => InterestsPage(),
          // '/profile': (context) => ProfilePage(),
          // '/home': (context) => HomePage(),
        });
  }
}
