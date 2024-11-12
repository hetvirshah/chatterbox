import 'package:chatterjii/features/auth/authcubit.dart';

import 'package:chatterjii/app/routes.dart';
import 'package:chatterjii/ui/allusers.dart';

import 'package:chatterjii/ui/messagelist.dart';

import 'package:chatterjii/utils/notificationUtility.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int counter = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      if (mounted) {
        NotificationUtility.setUpNotificationService(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await Hive.openBox('counter');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacementNamed(Routes.auth);
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 74, 84, 137),
                  Color.fromARGB(255, 14, 37, 165)
                ],
                begin: Alignment.topLeft,
                end: Alignment.topRight,
              ),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(175),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  toolbarHeight: 175,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello , ${state.user.displayName}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTabButton(context, 'Messages', 0),
                        _buildTabButton(context, 'All Users', 1)
                      ],
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        context.read<AuthCubit>().signOut();
                      },
                    ),
                  ],
                ),
              ),
              body: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [MessagesList(), UsersScreen()],
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildTabButton(BuildContext context, String text, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: _selectedIndex == index
                  ? Colors.white
                  : Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
    );
  }
}
