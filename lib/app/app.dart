import 'package:chatterjii/features/Messages/MessageCubit.dart';
import 'package:chatterjii/features/Messages/Messagerepo.dart';
import 'package:chatterjii/features/Messages/latestCubit.dart';
import 'package:chatterjii/features/Messages/sendCubit.dart';
import 'package:chatterjii/features/auth/authcubit.dart';
import 'package:chatterjii/features/auth/authrepo.dart';
import 'package:chatterjii/features/auth/userscubit.dart';
import 'package:chatterjii/app/routes.dart';
import 'package:chatterjii/features/notification/notificationCubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final AppLifecycleListener _listener;

  late AppLifecycleState? _state;

  @override
  void initState() {
    super.initState();
    _state = SchedulerBinding.instance.lifecycleState;
    _listener = AppLifecycleListener(
      onResume: () async {
        var appDir = await getApplicationDocumentsDirectory();
        Hive.init(appDir.path);
      },
      onPause: () async {
        await Hive.box('counter').close();
      },
    );
    if (_state != null) {
      return;
    }
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(AuthRepository()),
          ),
          BlocProvider(
            create: (context) => MessageCubit(MessageRepository()),
          ),
          BlocProvider(
            create: (context) => UserCubit(),
          ),
          BlocProvider(
            create: (context) => LatestMessageCubit(MessageRepository()),
          ),
          BlocProvider(
            create: (context) => SendMessageCubit(
                MessageRepository(), LatestMessageCubit(MessageRepository())),
          ),
          BlocProvider(create: (context) => NotificationCubit()),
        ],
        child: MaterialApp(
          title: 'chatterjii',
          theme: ThemeData(),
          initialRoute: Routes.auth,
          onGenerateRoute: Routes.onGenerateRouted,
        ));
  }
}
