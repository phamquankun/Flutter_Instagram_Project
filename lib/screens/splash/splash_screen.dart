import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram/blocs/blocs.dart';
import 'package:flutter_instagram/screens/screens.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  static const String routeName = '/splash';

  static Route route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (_) => SplashScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            // Go to the Login Screen.
            Navigator.of(context).pushNamed(OnboardScreen.routeName);
          } else if (state.status == AuthStatus.authenticated) {
            // Go to the Nav Screen.
            Navigator.of(context).pushNamed(NavScreen.routeName);
          }
        },
        child: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),

        // child: Scaffold(
        //   body: Container(
        //     padding: EdgeInsets.only(top: 150),
        //     child: Lottie.asset('assets/lottie/login.json'),
        // ),
      ),
    );
  }
}
